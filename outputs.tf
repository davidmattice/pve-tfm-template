output "template" {
  value = proxmox_virtual_environment_vm.template
}

output "nodes" {
  value = data.proxmox_virtual_environment_nodes.pve
}

output "datastores" {
  value = data.proxmox_virtual_environment_datastores
}

output "dns" {
  value = data.proxmox_virtual_environment_dns.pve_node
}

output "image" {
  value = proxmox_virtual_environment_file.image
}