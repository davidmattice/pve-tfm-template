
locals {
  datastore_name = var.datastore_name
  pve_host_name = var.pve_host_name == "" ? data.proxmox_virtual_environment_nodes.pve.names[0] : var.pve_host_name  
}
# Get a list of Proxmox Virtual Environment nodes from the server the provider connected to
data "proxmox_virtual_environment_nodes" "pve" {}

# Pull the list of datastores from the first node in the list of Proxmox Virtual Environment nodes (they should all be the same)
data "proxmox_virtual_environment_datastores" "pve" {
  node_name = data.proxmox_virtual_environment_nodes.pve.names[0]
}

# Get the DNS configuration for the node the will go pn
data "proxmox_virtual_environment_dns" "pve_node" {
  node_name = local.pve_host_name
}

# Pull down the ISO for this image
resource "proxmox_virtual_environment_file" "image" {
  content_type = "iso"
  datastore_id = element(data.proxmox_virtual_environment_datastores.pve.datastore_ids, index(data.proxmox_virtual_environment_datastores.pve.datastore_ids, "local"))
  node_name    = data.proxmox_virtual_environment_datastores.pve.node_name

  source_file {
    path = var.distro_url
    file_name = format("%s-%s-%s-%s.img", var.distro, var.distro_name, var.pve_template_version_tag, var.pve_template_id)
  }
}

resource "proxmox_virtual_environment_vm" "template" {
  agent {
    enabled = true
  }

  bios        = var.bios_type

  cpu {
    cores = 1
    numa  = true
  }

  description = format("%s-%s-%s", var.distro, var.distro_name, var.pve_template_version_tag)

  disk {
    datastore_id = element(data.proxmox_virtual_environment_datastores.pve.datastore_ids, index(data.proxmox_virtual_environment_datastores.pve.datastore_ids, local.datastore_name))
    file_id      = proxmox_virtual_environment_file.image.id
    interface    = "scsi0"
    discard      = "on"
    cache        = "writeback"
    ssd          = true
    size         = var.boot_disk_size
  }

  # Included only if bios_type is "ovmf"
  dynamic "efi_disk" {
    for_each = var.bios_type == "ovmf" ? [1] : []
    content {
      datastore_id = element(data.proxmox_virtual_environment_datastores.pve.datastore_ids, index(data.proxmox_virtual_environment_datastores.pve.datastore_ids, local.datastore_name))
      file_format  = "raw"
      type         = "4m"
    }
  }

  #initialization {
  #  datastore_id = element(data.proxmox_virtual_environment_datastores.pve.datastore_ids, index(data.proxmox_virtual_environment_datastores.pve.datastore_ids, local.datastore_name))
  #  #interface    = "scsi4"

  #  dns {
  #    server = "1.1.1.1"
  #  }

  #  ip_config {
  #    ipv4 {
  #      address = "dhcp"
  #    }
  #  }
  #}   

  # Machine type can be one of "q35" (2009) or "i440fx" (1996)
  machine = "q35"

  # Amount of memory needed
  memory {
    dedicated = 512
  }

  # Node name to be assigned
  name    = format("%s-%s", var.distro, var.distro_name)

  # Setup one base network device
  network_device {
    mtu    = 1450
    queues = 2
  }

  node_name = local.pve_host_name

  # Linux Kernel 2.6 or higher
  operating_system {
    type = "l26"
  }


  # Recommended for cloud-init based systems
  serial_device {}

  # Should this VM be started
  started = false

  # Some description information
  smbios {
    manufacturer = "Terraform"
    product      = "Terraform Provider Proxmox"
    version      = var.pve_template_version
  }

  # Combined list of tags
  tags = concat(["terraform", "template", var.distro, var.distro_name, var.pve_template_version, var.pve_template_id], var.additional_tags)

  # Ensure this is a template in Proxmox
  template = true

  # Set the VM ID
  vm_id = var.pve_template_id
}
