# Template for yandex compute cloud
terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = "0.86.0"
    }
  }
}

provider "yandex" {
  token = "t1.9euelZqJzs7Jjp2Zj83LlIuSmI6Yyu3rnpWai5XIismYjc3JmJbKz8-al5bl8_dNVEtf-e9EHgo9_N3z9w0DSV_570QeCj38.gI2D0mfS3kM02RcnxsXs0w_KlXW_upimRL1GQvHM3boSzzmk_i96fV3SRZ054vy7FfLxdKZ8RNmZR2t1jMMVAg"
  cloud_id = "b1g085gjne6qvhdpm5pc"
  folder_id = "b1gm8oivbl6s4adhu350"
  zone = "ru-cantral1-a"
}

# Create network
resource "yandex_vpc_network" "homework14network" {
  name = "homework14network"
}

# Create subnet
resource "yandex_vpc_subnet" "homework14subnet" {
  name           = "homework14subnet"
  zone           = "ru-central1-a"
  network_id     = "${yandex_vpc_network.homework14network.id}"
  v4_cidr_blocks = ["10.131.0.0/24"]
}

# Create instance
resource "yandex_compute_instance" "hw14instance" {
  name        = "study14-2"
  platform_id = "standard-v3"
  zone        = "ru-central1-a"
  allow_stopping_for_update = true
  description = "Study14-2"
  hostname = "study14-2"

  resources {
    cores  = 2
    memory = 1
    core_fraction = 50
  }

  boot_disk {
    initialize_params {
      image_id = "fd8snjpoq85qqv0mk9gi"
      size = 15
    }
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.homework14subnet.id}"
    nat = true
  }
  metadata = {
    user-data = "${file("./user-init.yml")}"
  }
}