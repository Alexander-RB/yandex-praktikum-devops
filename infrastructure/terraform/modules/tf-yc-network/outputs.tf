locals {
  zone_subnet_id = [for each in data.yandex_vpc_subnet.default : each.subnet_id if each.zone == var.vpc_subnet_zone ]
}

output "yandex_vpc_network" {
  value = data.yandex_vpc_network.default
}

output "yandex_vpc_subnet" {
  value = local.zone_subnet_id[0]
}