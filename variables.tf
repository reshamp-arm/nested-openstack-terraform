variable "prefix" {
  description = "Prefix applied to all lab host names."
  type        = string
  default     = "gazpacho"
}

variable "network_id" {
  description = "Routed management network used for all lab hosts."
  type        = string
  default     = "90c0844c-bfaf-48fd-8689-ff36225cba36"
}

variable "security_group_id" {
  description = "Security group shared by the lab hosts and the existing Ansible controller."
  type        = string
  default     = "f722cc6b-8608-4524-b515-1a22a32cb708"
}

variable "image_name" {
  description = "Glance image used to boot all ARM64 lab hosts."
  type        = string
  default     = "ubuntu-noble-24.04-aarch64"
}

variable "keypair_name" {
  description = "Existing OpenStack keypair authorised for SSH access."
  type        = string
  default     = "reshamp-key"
}

variable "seed_flavor" {
  description = "Flavor for the seed host."
  type        = string
  default     = "m1.large"
}

variable "overcloud_flavor" {
  description = "Flavor shared by controller and compute hosts."
  type        = string
  default     = "m1.large"
}

variable "controller_count" {
  description = "Number of controller hosts. Use 1 for this lab; increase later to scale out."
  type        = number
  default     = 1

  validation {
    condition     = var.controller_count >= 1 && floor(var.controller_count) == var.controller_count
    error_message = "controller_count must be a whole number of at least 1."
  }
}

variable "compute_count" {
  description = "Number of compute hosts."
  type        = number
  default     = 2

  validation {
    condition     = var.compute_count >= 0 && floor(var.compute_count) == var.compute_count
    error_message = "compute_count must be a whole number of at least 0."
  }
}

variable "root_volume_size_gb" {
  description = "Boot-volume size for every host in GiB."
  type        = number
  default     = 100
}

variable "availability_zone" {
  description = "Nova availability zone for all ARM64 lab hosts."
  type        = string
  default     = "nova:compute-2.novalocal"
}
