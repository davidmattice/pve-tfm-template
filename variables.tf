variable "pve_endpoint" {
    description = "Endpoint URL for PVE environment"
    type        = string
}

variable "pve_user" {
    description = "User name for Terraform Updates"
    type        = string
}

variable "pve_template_id" {
    description = "This is the ID of this tempalte.  Must be unique for each template."
    type        = string
}

variable "distro" {
    description = "This is the distro name that will be used in the template name"
    type        = string
}

variable "distro_name" {
    description = "This is the name of the version to use from this distro"
    type        = string
}

variable "distro_url" {
    description = "This is the full path URL to the ISO image to be pulled down"
    type        = string
}

variable "storage_volume" {
    description = "Storage Volume to put images and teplates"
    type        = string
    default     = "local-lvm"
}