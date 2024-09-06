terraform {
  required_providers {
    harvester = {
      source = "harvester/harvester"
    }
  }
}

provider "harvester" {
  # Configuration options
  kubeconfig = "${path.root}/kubeconfig.yaml"
}

resource "harvester_image" "ubuntu" {
  name         = "ubuntu"
  display_name = "ubuntu"
  namespace    = "default"
  source_type  = "download"
  url          = "https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img"
}

resource "harvester_network" "mgmt-vlan1" {
  name                 = "mgmt-vlan1"
  namespace            = "default"
  vlan_id              = 1
  route_mode           = "auto"
  route_dhcp_server_ip = ""
  cluster_network_name = "mgmt"
}

variable "test-vm-ip" {
  type    = string
  default = "192.168.100.11/24"
}

resource "harvester_cloudinit_secret" "cloud-config-default" {
  name      = "cloud-config-default"
  namespace = "default"
  user_data = templatefile("${path.root}/cloud_config.tpl", {})
  network_data = templatefile("${path.root}/network_data.tpl", {
    ip = var.test-vm-ip
  })
}

resource "harvester_virtualmachine" "test-vm" {
  depends_on = [
    harvester_image.ubuntu,
    harvester_network.mgmt-vlan1
  ]

  name      = "test-vm"
  namespace = "default"
  cpu       = 2
  memory    = "2Gi"

  cloudinit {
    user_data_secret_name = "cloud-config-default"
    network_data_secret_name = "cloud-config-default"
  }

  network_interface {
    name         = "test-nic"
    network_name = "default/mgmt-vlan1"
  }

  disk {
    name        = "test-disk"
    size        = "10Gi"
    image       = "ubuntu"
    auto_delete = true
  }
}
