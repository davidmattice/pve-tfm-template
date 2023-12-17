output "template" {
  description = "Full configuration of the created template."
  value       = proxmox_virtual_environment_vm.template
}

output "nodes" {
  description = "List of PVE nodes in the cluster pointed to by the PROXMOX Endpoint."
  value       = data.proxmox_virtual_environment_nodes.pve
}

output "datastores" {
  description = "List of datastores found on the PVE node."
  value       = data.proxmox_virtual_environment_datastores.pve
}

output "dns" {
  description = "DNS configuration of the PVE node."
  value       = data.proxmox_virtual_environment_dns.pve
}

output "image" {
  description = "Details of the ISO image used to create the template."
  value       = proxmox_virtual_environment_file.image
}