output "template" {
  value = proxmox_virtual_environment_vm.template
}

output "nodes" {
  value = data.proxmox_virtual_environment_nodes.pve
}

output "dns" {
  value = data.proxmox_virtual_environment_dns.pve_node
}
