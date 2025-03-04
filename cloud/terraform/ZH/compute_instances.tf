# Combined compute instances configuration
variable "compute_instances" {
  type = map(object({
    flavor_id = string
  }))
  default = {
    "Node01" = { flavor_id = "4" },  # m1.large
    "Node02" = { flavor_id = "4" },  # m1.large
    "Node03" = { flavor_id = "3" }   # m1.medium
  }
}

resource "openstack_blockstorage_volume_v3" "root_volumes_compute" {
  for_each = var.compute_instances

  name              = "${var.REGION}-${each.key}-root-volume"
  size              = 130
  description       = "130GB root volume for ${var.REGION}-${each.key}"
  availability_zone = "nova"
  image_id          = data.openstack_images_image_v2.debian12.id
}

resource "openstack_compute_instance_v2" "compute_instances" {
  for_each = var.compute_instances

  name        = "${var.REGION}-${each.key}"
  flavor_id   = each.value.flavor_id
  key_pair    = var.SSH_KEYPAIR
  security_groups = [openstack_networking_secgroup_v2.security_group.name]

  network {
    name = "private"
  }

  block_device {
    uuid                  = openstack_blockstorage_volume_v3.root_volumes_compute[each.key].id
    source_type           = "volume"
    destination_type      = "volume"
    boot_index            = 0
    delete_on_termination = true
  }

  lifecycle {
    ignore_changes = [key_pair]
  }
}

# Networking resources for all instances
resource "openstack_networking_floatingip_v2" "nodes_floating_ips" {
  for_each = var.compute_instances
  pool     = "public"
}

data "openstack_networking_port_v2" "nodes_ports" {
  for_each = var.compute_instances
  fixed_ip = openstack_compute_instance_v2.compute_instances[each.key].access_ip_v4
}

resource "openstack_networking_floatingip_associate_v2" "fip_assoc" {
  for_each    = var.compute_instances
  floating_ip = openstack_networking_floatingip_v2.nodes_floating_ips[each.key].address
  port_id     = data.openstack_networking_port_v2.nodes_ports[each.key].id
}

# Combined outputs
output "nodes_floating_ips_nodes" {
  value = { for k, v in openstack_networking_floatingip_v2.nodes_floating_ips : k => v.address }
}

output "private_ips_nodes" {
  value = { for k, v in openstack_compute_instance_v2.compute_instances : k => v.network[0].fixed_ip_v4 }
}
