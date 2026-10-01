variable "prefix" {
  description = "Prefix applied to all lab host names."
  type        = string
  default     = "gazpacho"
}

variable "network_id" {
  description = "Routed management network used for all lab hosts."
  type        = string
}

variable "security_group_id" {
  description = "Existing security group for lab VM ports; the admin manages its SSH and intra-lab rules."
  type        = string
}

# make it arm64 for arm deployment.
variable "image_name" {
  description = "Glance image used to boot all lab hosts."
  type        = string
  default     = "ubuntu-noble-24.04-amd64"
}

variable "keypair_name" {
  description = "Existing OpenStack keypair authorised for SSH access."
  type        = string
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
  description = "Nova availability zone for all lab hosts. Set null to let Nova schedule them without an explicit zone."
  type        = string
  default     = "nova"
  nullable    = true
}
