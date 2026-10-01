# Nested OpenStack lab infrastructure

This Terraform configuration creates seed, controller, and compute VMs on an existing network. It attaches an existing security group to their ports. Security-group creation and rules are managed by the OpenStack administrator.

## Plan inputs

Source the project's openrc or select an `OS_CLOUD` entry. The admin supplies an Ansible control host, network, keypair, and security group. The group must permit SSH from the control host and the traffic needed between lab VMs (for example, an ingress rule referencing the same group). Attach it to the control host too if that is how its SSH traffic will match the rule.

For example, after creating `project sg group`, the admin can allow IPv4 traffic between ports in that group with:

```sh
openstack security group rule create \
  --ingress \
  --ethertype IPv4 \
  --remote-group 'project sg group' \
  'project sg group'
```

Run this only if the rule does not already exist. The control host also needs `project sg group` on its port for its SSH traffic to match this rule.

Three variables have no default:

| Variable | Value |
| --- | --- |
| `network_id` | UUID of the network for the lab VMs. |
| `security_group_id` | UUID of the existing group to attach to every lab VM port. |
| `keypair_name` | Name of an existing OpenStack keypair for the image's cloud user. |

Override them during planning:

```sh
terraform plan \
  -var='network_id=<management-network-id>' \
  -var='security_group_id=<existing-security-group-id>' \
  -var='keypair_name=<keypair-name>'
```

Other variables such as `image_name`, `availability_zone`, flavors, and host counts have defaults in `variables.tf`; override any of them with another `-var` argument. You can also set inputs through `TF_VAR_*` environment variables. Cloud-init disables SSH password authentication; use the image's cloud user and your keypair.

Review the plan before applying to an existing lab, especially any VM replacement or port security-group changes.
