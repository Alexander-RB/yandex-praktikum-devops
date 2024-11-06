resource "yandex_kubernetes_cluster" "k8s_zonal_cluster" {
 network_id = yandex_vpc_network.k8s-network.id
 master {
   master_location {
     zone      = var.zone
     subnet_id = yandex_vpc_subnet.k8s-subnet.id
   }
   public_ip = true
   security_group_ids = [yandex_vpc_security_group.k8s-public-services.id]
 }
 service_account_id      = yandex_iam_service_account.sa-kubernetes.id
 node_service_account_id = yandex_iam_service_account.sa-kubernetes.id
   depends_on = [
    yandex_resourcemanager_folder_iam_member.editor,
    yandex_resourcemanager_folder_iam_member.k8s-clusters-agent,
    yandex_resourcemanager_folder_iam_member.vpc-public-admin,
    yandex_resourcemanager_folder_iam_member.images-puller,
    yandex_resourcemanager_folder_iam_member.encrypterDecrypter
   ]
   kms_provider {
    key_id = yandex_kms_symmetric_key.kms-key.id
  }
}

resource "yandex_vpc_network" "k8s-network" { 
  depends_on = [
    yandex_iam_service_account.sa-kubernetes
  ]
  name = "k8s-network" 
}

resource "yandex_vpc_subnet" "k8s-subnet" {
  v4_cidr_blocks = [var.v4_cidr_blocks]
  zone           = var.zone
  network_id     = yandex_vpc_network.k8s-network.id
}

resource "yandex_iam_service_account" "sa-kubernetes" {
  name        = "sa-kubernetes"
  description = "Сервисный аккаунт для кластера Kubernetes"
  folder_id = var.folder_id
}

resource "yandex_resourcemanager_folder_iam_member" "editor" {
  # Сервисному аккаунту назначается роль "editor".
  folder_id = var.folder_id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.sa-kubernetes.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "k8s-clusters-agent" {
  # Сервисному аккаунту назначается роль "k8s.clusters.agent".
  folder_id = var.folder_id
  role      = "k8s.clusters.agent"
  member    = "serviceAccount:${yandex_iam_service_account.sa-kubernetes.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "vpc-public-admin" {
  # Сервисному аккаунту назначается роль "vpc.publicAdmin".
  folder_id = var.folder_id
  role      = "vpc.publicAdmin"
  member    = "serviceAccount:${yandex_iam_service_account.sa-kubernetes.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "images-puller" {
  # Сервисному аккаунту назначается роль "container-registry.images.puller".
  folder_id = var.folder_id
  role      = "container-registry.images.puller"
  member    = "serviceAccount:${yandex_iam_service_account.sa-kubernetes.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "encrypterDecrypter" {
  # Сервисному аккаунту назначается роль "kms.keys.encrypterDecrypter".
  folder_id = var.folder_id
  role      = "kms.keys.encrypterDecrypter"
  member    = "serviceAccount:${yandex_iam_service_account.sa-kubernetes.id}"
}

resource "yandex_kms_symmetric_key" "kms-key" {
  # Ключ Yandex Key Management Service для шифрования важной информации, такой как пароли, OAuth-токены и SSH-ключи.
  name              = "kms-key"
  default_algorithm = "AES_128"
  rotation_period   = "8760h" # 1 год.
  depends_on = [
    yandex_iam_service_account.sa-kubernetes
  ]
}

resource "yandex_vpc_security_group" "k8s-public-services" {
  name        = "k8s-public-services"
  description = "Правила группы разрешают подключение к сервисам из интернета. Примените правила только для групп узлов."
  network_id  = yandex_vpc_network.k8s-network.id
    ingress {
    protocol       = "TCP"
    description    = "Правило разрешает подключение к API Kubernetes через порт 6443 из Интернет."
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 6443
  }
  ingress {
    protocol       = "TCP"
    description    = "Правило разрешает подключение к API Kubernetes через порт 443 из Интернет."
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 443
  }
  ingress {
    protocol       = "TCP"
    description    = "Правило разрешает подключение к API Kubernetes через порт 80 из Интернет."
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }
  ingress {
    protocol          = "TCP"
    description       = "Правило разрешает проверки доступности с диапазона адресов балансировщика нагрузки. Нужно для работы отказоустойчивого кластера Managed Service for Kubernetes и сервисов балансировщика."
    predefined_target = "loadbalancer_healthchecks"
    from_port         = 0
    to_port           = 65535
  }
  ingress {
    protocol          = "ANY"
    description       = "Правило разрешает взаимодействие мастер-узел и узел-узел внутри группы безопасности."
    predefined_target = "self_security_group"
    from_port         = 0
    to_port           = 65535
  }
  ingress {
    protocol          = "ANY"
    description       = "Правило разрешает взаимодействие под-под и сервис-сервис. Укажите подсети вашего кластера Managed Service for Kubernetes и сервисов."
    v4_cidr_blocks    = concat(yandex_vpc_subnet.k8s-subnet.v4_cidr_blocks)
    from_port         = 0
    to_port           = 65535
  }
  ingress {
    protocol          = "ICMP"
    description       = "Правило разрешает отладочные ICMP-пакеты из внутренних подсетей."
    v4_cidr_blocks    = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  }
  ingress {
    protocol          = "TCP"
    description       = "Правило разрешает входящий трафик из интернета на диапазон портов NodePort. Добавьте или измените порты на нужные вам."
    v4_cidr_blocks    = ["0.0.0.0/0"]
    from_port         = 30000
    to_port           = 32767
  }
  egress {
    protocol          = "ANY"
    description       = "Правило разрешает весь исходящий трафик. Узлы могут связаться с Yandex Container Registry, Yandex Object Storage, Docker Hub и т. д."
    v4_cidr_blocks    = ["0.0.0.0/0"]
    from_port         = 0
    to_port           = 65535
  }
}

resource "yandex_kubernetes_node_group" "k8s-node-group" {
  cluster_id  = "${yandex_kubernetes_cluster.k8s_zonal_cluster.id}"
  name        = "k8s-node-group"
  version     = var.k8s_version

  instance_template {
    platform_id = var.platform_id

    network_interface {
      nat                = true
      subnet_ids         = ["${yandex_vpc_subnet.k8s-subnet.id}"]
    }

    resources {
      memory = var.node_memory
      cores  = var.node_cores
      core_fraction = var.node_core_fraction
    }

    boot_disk {
      type = var.boot_disk_type
      size = var.boot_disk_size
    }

    scheduling_policy {
      preemptible = var.preemptible
    }
  }

  scale_policy {
    auto_scale {
      min = var.nodes_count
      max = var.nodes_count + 2 
      initial = var.nodes_count
    }
  }

  allocation_policy {
    location {
      zone = var.zone
    }
  }
}