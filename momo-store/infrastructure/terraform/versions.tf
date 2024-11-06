terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">= 0.87.0"
    }
  }
  required_version = ">= 1.9.0"

  # Описание бэкенда хранения состояния
  backend "s3" {
    endpoints = { 
      s3 = "https://storage.yandexcloud.net" 
      }
    bucket    = "terraform-state-momo-store-std-029-26"
    region    = "ru-central1"
    key       = "terraform.tfstate"

    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
  }
}