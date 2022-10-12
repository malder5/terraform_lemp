terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.61.0"
    }
  }
}
provider "yandex" {
  service_account_key_file = file("key.json")
  folder_id                = var.folder_id
  cloud_id                 = var.cloud_id
  zone                     = var.zone
}
resource "yandex_lb_target_group" "my-target-group" {
  name = "my-target-group"

  target {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    address   = yandex_compute_instance.vm-1.network_interface.0.ip_address
  }

  target {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    address   = yandex_compute_instance.vm-2.network_interface.0.ip_address
  }

}

resource "yandex_lb_network_load_balancer" "balancer" {
  name = "my-network-load-balancer"

  listener {
    name = "my-listener"
    port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = "${yandex_lb_target_group.my-target-group.id}"

    healthcheck {
      name = "http"
      http_options {
        port = 80
        path = "/"
      }
    }
  }
}

data "yandex_compute_image" "ubuntu-image" {
  family = "ubuntu-2204-lts"
}

data "yandex_compute_image" "lemp" {
  family = "lemp"
}
#
resource "yandex_compute_instance" "vm-1" {
  name                      = "vm-1"
  allow_stopping_for_update = true
  resources {
    cores         = 2
    memory        = 2
    core_fraction = 5
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.lemp.id
      type     = "network-ssd"
      size     = 3
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = {
    ssh-keys           = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
    serial-port-enable = 1
  }
}

data "yandex_compute_image" "lamp" {
  family = "lamp"
}
#
resource "yandex_compute_instance" "vm-2" {
  name                      = "vm-2"
  allow_stopping_for_update = true
  resources {
    cores         = 2
    memory        = 2
    core_fraction = 5
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.lamp.id
      type     = "network-ssd"
      size     = 3
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = {
    ssh-keys           = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
    serial-port-enable = 1
  }
}

resource "yandex_vpc_network" "network-1" {
  name = "network1"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1"
  zone           = var.zone
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

