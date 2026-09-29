terraform {
  required_version = ">= 1.5.0"

  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 3.4"
    }
  }
}

# Authentication is read from OS_CLOUD / clouds.yaml (or standard OS_* variables).
provider "openstack" {}

data "openstack_images_image_v2" "ubuntu" {
  name        = var.image_name
  most_recent = true
}

locals {
  cloud_init = <<-CLOUD_CONFIG
    #cloud-config
    # Lab-only break-glass access. Do not reuse this cloud-init in a
    # non-disposable environment.
    disable_root: false
    ssh_pwauth: true
    chpasswd:
      expire: false
      list: |
        root:stack
    write_files:
      - path: /etc/ssh/sshd_config.d/99-lab-root-password.conf
        owner: root:root
        permissions: '0600'
        content: |
          PermitRootLogin yes
          PasswordAuthentication yes
    runcmd:
      - [systemctl, restart, ssh.service]
    #package_update: false
    #package_upgrade: false

    packages:
      - python3
      - python3-apt
      - sudo
      - ca-certificates
      - chrony
      - git
  CLOUD_CONFIG

  hosts = merge(
    {
      seed = {
        name   = "${var.prefix}-seed"
        flavor = var.seed_flavor
      }
    },
    {
      for number in range(1, var.controller_count + 1) : "controller-${number}" => {
        name   = format("%s-controller-%02d", var.prefix, number)
        flavor = var.overcloud_flavor
      }
    },
    {
      for number in range(1, var.compute_count + 1) : "compute-${number}" => {
        name   = format("%s-compute-%02d", var.prefix, number)
        flavor = var.overcloud_flavor
      }
    },
  )
}

# All hosts use the routed management network. The L2-only network is not
# attached: Kayobe can build its lab networks as an overlay later.
resource "openstack_networking_port_v2" "host" {
  for_each = local.hosts

  name               = each.value.name
  network_id         = var.network_id
  security_group_ids = [var.security_group_id]
}

resource "openstack_compute_instance_v2" "host" {
  for_each = local.hosts

  name              = each.value.name
  flavor_name       = each.value.flavor
  key_pair          = var.keypair_name
  availability_zone = var.availability_zone
  config_drive      = true
  user_data         = local.cloud_init

  network {
    port = openstack_networking_port_v2.host[each.key].id
  }

  block_device {
    uuid                  = data.openstack_images_image_v2.ubuntu.id
    source_type           = "image"
    destination_type      = "volume"
    volume_size           = var.root_volume_size_gb
    boot_index            = 0
    delete_on_termination = true
  }
}

output "host_addresses" {
  description = "Private addresses to use in your Kayobe inventory."
  value = {
    for host, port in openstack_networking_port_v2.host :
    host => port.all_fixed_ips[0]
  }
}

output "host_names" {
  description = "Hostnames grouped by Kayobe role."
  value = {
    seed        = openstack_compute_instance_v2.host["seed"].name
    controllers = [for number in range(1, var.controller_count + 1) : openstack_compute_instance_v2.host["controller-${number}"].name]
    computes    = [for number in range(1, var.compute_count + 1) : openstack_compute_instance_v2.host["compute-${number}"].name]
  }
}
