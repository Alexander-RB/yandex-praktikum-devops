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
  default     = "b1g3jddf4nv5e9okle7p"
}

variable folder_id {
  description = "ID of folder"
  type        = string
  default     = "b1ghdaqc09rnivs9mndi"
}

variable zone {
  description = "Zone"
  type        = string
  default     = "ru-central1-a"
}

variable image_id {
  description = ""
  type = string
  default = "fd80qm01ah03dkqb14lc"
}