variable "instance_names" {
  type    = list(string)
  default = ["Node01","Node02","Node03"]
}

resource "openstack_blockstorage_volume_v3" "root_volumes_compute" {
  for_each = toset(var.instance_names)

  name              = "${var.REGION}-${each.key}-root-volume"
  size              = 40  
  description       = "40GB root volume for ${var.REGION}-${each.key}"
  availability_zone = "nova"
  image_id          = data.openstack_images_image_v2.debian12.id  # Use the dynamic image ID
}


resource "openstack_compute_instance_v2" "compute_instances" {
  for_each = toset(var.instance_names)

  name        = "${var.REGION}-${each.key}"
  flavor_id   = "3" # m1.medium
  key_pair    = var.SSH_KEYPAIR
  security_groups = [
    openstack_networking_secgroup_v2.security_group.name
  ]

  network {
    name = "private"  # Private network
  }

  block_device {
    uuid                  = openstack_blockstorage_volume_v3.root_volumes_compute[each.key].id
    source_type           = "volume"
    destination_type      = "volume"
    boot_index            = 0
    delete_on_termination = true
  }

  lifecycle {
    ignore_changes = [
      key_pair,  # Ignore changes to the key_pair attribute
    ]
  }


  
}

resource "openstack_networking_floatingip_v2" "nodes_floating_ips" {
  for_each = toset(var.instance_names)

  pool = "public"
}

data "openstack_networking_port_v2" "nodes_ports" {
  for_each = toset(var.instance_names)

  fixed_ip = openstack_compute_instance_v2.compute_instances[each.key].access_ip_v4
}

resource "openstack_networking_floatingip_associate_v2" "fip_Hassoc" {
  for_each = toset(var.instance_names)

  floating_ip = openstack_networking_floatingip_v2.nodes_floating_ips[each.key].address
  port_id     = data.openstack_networking_port_v2.nodes_ports[each.key].id
}

output "nodes_floating_ips_nodes" {
  value = [for fip in openstack_networking_floatingip_v2.nodes_floating_ips : fip.address]
}

output "private_ips_nodes" {
  value = [for instance in openstack_compute_instance_v2.compute_instances : instance.network[0].fixed_ip_v4]
}