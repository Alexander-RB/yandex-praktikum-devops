variable token {
  description = "IAM token for Yandex Cloud"
  type        = string
  sensitive = true
}

variable access_key {
  description = "access_key for Yandex Cloud"
  type        = string
  sensitive = true
}

variable secret_key {
  description = "secret_key for Yandex Cloud"
  type        = string
  sensitive = true
}

variable cloud_id {
  description = "ID of cloud"
  type        = string
  sensitive = true
}

variable folder_id {
  description = "ID of folder"
  type        = string
  sensitive = true
}

variable zone {
  description = "Zone"
  type        = string
  default     = "ru-central1-b"
}

variable v4_cidr_blocks {
  description = "ipv4 cidr blocks"
  type = string
  default = "10.1.0.0/24"
}

variable platform_id {
  type        = string
  default     = "standard-v3"
}

variable node_memory {
  type        = number
  default     = 4
}

variable node_cores {
  type        = number
  default     = 2
}

variable node_core_fraction {
  type        = number
  default     = 20
}

variable boot_disk_type {
  type        = string
  default     = "network-hdd"
}

variable boot_disk_size {
  type        = number
  default     = 64
}

variable nodes_count {
  type        = number
  default     = 2
}

variable preemptible {
  type = bool
  default = true
}

variable "k8s_version" {
  type        = string
  default     = "1.27"
}