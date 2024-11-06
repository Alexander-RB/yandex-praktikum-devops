resource "yandex_compute_instance" "vm" {
  count = length(var.vm_suffixes)
  name = "charpter5-std-029-26-${element(var.vm_suffixes, count.index)}"
  platform_id = var.platform_id
  zone = var.zone

  # Конфигурация ресурсов:
  resources {
    cores  = 2
    memory = 2
  }
    
  # Прерываемая ВМ
  scheduling_policy {
    preemptible = var.scheduling_policy
  }

  # Загрузочный диск:
  boot_disk {
    initialize_params {
      image_id = var.image_id
      size = var.size
    }
  }

  # Сетевой интерфейс:
  network_interface {
    subnet_id = var.subnet_id
    nat = var.nat
  }

  # Метаданные машины:
  # здесь можно указать скрипт, который запустится при создании ВМ
  # или список SSH-ключей для доступа на ВМ
  metadata = {
    user-data = "${file("./modules/tf-yc-instance/cloud-config.yaml")}"
  }
}

data "template_file" "ansible_hosts" {
  template = "${file("inventory.template")}"
  vars = {
    frontend_public_ip = yandex_compute_instance.vm[0].network_interface.0.nat_ip_address
    backend_public_ip = yandex_compute_instance.vm[1].network_interface.0.nat_ip_address
  }
}

resource "null_resource" "dev-hosts" {
  triggers = {
    template_rendered = "${data.template_file.ansible_hosts.rendered}"
  }
  provisioner "local-exec" {
    command = "echo '${data.template_file.ansible_hosts.rendered}' > ../ansible/inventory/yandexcloud.yaml"
  }
}