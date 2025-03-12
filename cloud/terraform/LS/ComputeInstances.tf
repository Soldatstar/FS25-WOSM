# Combined compute instances configuration
variable "compute_instances" {
  type = map(object({
    flavor_id = string
  }))
  default = {
    "Node01" = { flavor_id = "4" },  # m1.large
    "Node02" = { flavor_id = "4" },  # m1.large
  }
}

resource "openstack_blockstorage_volume_v3" "root_volumes_compute" {
  for_each = var.compute_instances

  name              = "${var.REGION}-${each.key}-root-volume"
  size              = 50  
  description       = "50GB root volume for ${var.REGION}-${each.key}"
  availability_zone = "nova"
  image_id          = data.openstack_images_image_v2.debian12.id
  volume_type       = "ceph-ssd"
}

/* resource "openstack_blockstorage_volume_v3" "additional_volumes_compute" {
  for_each = var.compute_instances

  name              = "${var.REGION}-${each.key}-data-volume"
  size              = 100
  description       = "100GB additional volume for ${var.REGION}-${each.key}"
  availability_zone = "nova"
}
 */
resource "openstack_compute_instance_v2" "compute_instances" {
  for_each = var.compute_instances

  name        = "${var.REGION}-${each.key}"
  flavor_id   = each.value.flavor_id
  key_pair    = var.SSH_KEYPAIR
  #security_groups = [openstack_networking_secgroup_v2.security_group.name]

  network {
    name = openstack_networking_network_v2.private_network.name
  }

  # Root volume (boot device)
  block_device {
    uuid                  = openstack_blockstorage_volume_v3.root_volumes_compute[each.key].id
    source_type           = "volume"
    destination_type      = "volume"
    boot_index            = 0
    delete_on_termination = true
  }

/*   # Additional data volume
  block_device {
    uuid                  = openstack_blockstorage_volume_v3.additional_volumes_compute[each.key].id
    source_type           = "volume"
    destination_type      = "volume"
    boot_index            = 1
    delete_on_termination = true  # Set to false if you want to persist the volume after instance deletion
  } */

  lifecycle {
    ignore_changes = [key_pair]
  }
}

