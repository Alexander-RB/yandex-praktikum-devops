variable "vm_suffixes" {
  default = ["frontend", "backend"]
  type = list
  description = "List of VMs suffix-names"
}

variable zone {
  description = ""
  type        = string
  default     = "ru-central1-a"
}

variable platform_id {
  description = ""
  type        = string
  default     = "standard-v3"
}

variable scheduling_policy {
  description = ""
  type        = string
  default     = "false"
}

variable size {
  description = "Размер диска"
  type        = number
  default     = "35"
}

variable image_id {
  description = ""
  type = string
  default = "fd80qm01ah03dkqb14lc"
}

variable nat {
  type = bool
  default = "true"
}

variable "subnet_id" {
  type = string
  nullable = false
}