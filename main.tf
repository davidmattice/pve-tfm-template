
locals {
  storage_volume = var.storage_volume
}
# Get a list of Proxmox Virtual Environment nodes from the server the provider connected to
data "proxmox_virtual_environment_nodes" "pve" {}

# Pull the list of datastores from the first node in the list of Proxmox Virtual Environment nodes (they should all be the same)
data "proxmox_virtual_environment_datastores" "pve" {
  node_name = data.proxmox_virtual_environment_nodes.pve.names[0]
}

# Pull down the ISO for this image
resource "proxmox_virtual_environment_file" "image" {
  content_type = "iso"
  datastore_id = element(data.proxmox_virtual_environment_datastores.pve.datastore_ids, index(data.proxmox_virtual_environment_datastores.pve.datastore_ids, "local"))
  node_name    = data.proxmox_virtual_environment_datastores.pve.node_name

  source_file {
    path = var.distro_url
  }
}

resource "proxmox_virtual_environment_vm" "template" {
  agent {
    enabled = true
  }

  bios        = "ovmf"

  cpu {
    cores = 2
    numa  = true
  }

  description = "Managed by Terraform"

   disk {
    datastore_id = element(data.proxmox_virtual_environment_datastores.pve.datastore_ids, index(data.proxmox_virtual_environment_datastores.pve.datastore_ids, local.storage_volume))
    file_id      = proxmox_virtual_environment_file.image.id
    interface    = "scsi0"
    discard      = "on"
    cache        = "writeback"
    ssd          = true
  }

  smbios {
    manufacturer = "Terraform"
    product      = "Terraform Provider Proxmox"
    version      = "0.0.1"
  }

  startup {
    order      = "3"
    up_delay   = "60"
    down_delay = "60"
  }

  efi_disk {
    datastore_id = element(data.proxmox_virtual_environment_datastores.pve.datastore_ids, index(data.proxmox_virtual_environment_datastores.pve.datastore_ids, local.storage_volume))
    file_format  = "raw"
    type         = "4m"
  }

  initialization {
    datastore_id = element(data.proxmox_virtual_environment_datastores.pve.datastore_ids, index(data.proxmox_virtual_environment_datastores.pve.datastore_ids, local.storage_volume))
    #interface    = "scsi4"

    dns {
      server = "1.1.1.1"
    }

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    #user_data_file_id   = proxmox_virtual_environment_file.user_config.id
    #vendor_data_file_id = proxmox_virtual_environment_file.vendor_config.id
    #meta_data_file_id   = proxmox_virtual_environment_file.meta_config.id
  }   

  machine = "q35"
  name    = format("%s-%s", var.distro, var.distro_name)

  network_device {
    mtu    = 1450
    queues = 2
  }

  network_device {
    vlan_id = 1024
  }

  node_name = data.proxmox_virtual_environment_nodes.pve.names[0]

  operating_system {
    type = "l26"
  }

  #pool_id = proxmox_virtual_environment_pool.example.id

  serial_device {}

  tags = ["terraform", var.distro, var.distro_name]

  template = true

  vm_id = var.pve_template_id
}
