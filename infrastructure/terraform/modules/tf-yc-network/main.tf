data "yandex_vpc_network" "default" {
  name = "default"
 }

data "yandex_vpc_subnet" "default" {
  for_each = toset(data.yandex_vpc_network.default.subnet_ids)
  subnet_id = "${each.value}"
}