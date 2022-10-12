output "internal_ip_address_vm_1" {
  value = yandex_compute_instance.vm-1.network_interface.0.ip_address
}

output "external_ip_address_vm_1" {
  value = yandex_compute_instance.vm-1.network_interface.0.nat_ip_address
}

output "internal_ip_address_lamp" {
  value = yandex_compute_instance.vm-2.network_interface.0.ip_address
}

output "external_ip_address_lamp" {
  value = yandex_compute_instance.vm-2.network_interface.0.nat_ip_address
}

#output "access_key" {
#  value     = yandex_iam_service_account_static_access_key.sa-static-key.access_key
#  sensitive = true
#}
#output "secret_key" {
#  value     = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
#  sensitive = true
#}