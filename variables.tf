##############################
# Proxmox Virtual Environment 
##############################
variable "pve_host_name" {
    description = "PVE hostname to create this template on.  Defaults to first host in the Cluster."
    type        = string
    default     = ""
}

##############################
# Template Details
##############################
variable "pve_template_id" {
    description = "This is the ID of this template.  Must be specified and be unique for each template."
    type        = string
}

variable "pve_template_version_tag" {
    description = "This is the version tag to apply to this telplate."
    type        = string
    default     = "not-set"
}

variable "distro_url" {
    description = "This is the full path URL to the ISO image to be pulled down.  This must be set and passed in."
    type        = string
}

variable "distro" {
    description = "This is the distro name that will be used in the template name.  This must be set and passed in."
    type        = string
}

variable "distro_name" {
    description = "This is the name of the version to use from this distro.  This must be set and passed in."
    type        = string
}

variable "datastore_name" {
    description = "Datastore to put images and teplates on"
    type        = string
    default     = "local-lvm"
}

variable "additional_tags" {
    description = "Additional custom tags to add to the template being created"
    type        = list(string)
    default     = []
}

variable "bios_type" {
    description = "Select the bios type for the template and VMs cloned from it.  Must be either \"seabios\" or \"ovmf\"."
    type        = string
    default     = "seabios"
    validation {
      condition = contains(["seabios","ovmf"], var.bios_type)
      error_message = "Bios typ emust be one of \"seabios\" or \"ovmf\""
    }
}

variable "boot_disk_size" {
    description = "Size of the system book disk."
    type        = number
    default     = 8
}