variable "storage_instance_names" {
  type    = list(string)
  default = ["monitor01", "osd01", "osd02", "osd03"]
}

resource "openstack_blockstorage_volume_v3" "root_volumes_ceph" {
  for_each = toset(var.storage_instance_names)

  name              = "${each.key}-root-volume"
  size              = 10  # Root volume size remains 10GB for all
  description       = "10GB root volume for ${each.key}"
  availability_zone = "nova"
  image_id          = data.openstack_images_image_v2.debian12.id
}

# Create storage volumes only for OSD nodes (exclude monitor01)
resource "openstack_blockstorage_volume_v3" "storage_volumes" {
  for_each = toset([for name in var.storage_instance_names : name if name != "monitor01"])

  name              = "${each.key}-storage-volume"
  size              = 120  # Adjusted to 120GB for OSD nodes
  description       = "120GB volume for ${each.key}"
  availability_zone = "nova"
}

resource "openstack_compute_instance_v2" "storage_instances" {
  for_each = toset(var.storage_instance_names)

  name        = "${var.REGION}-${each.key}"
  flavor_id   = "3"
  key_pair    = var.SSH_KEYPAIR
  security_groups = [openstack_networking_secgroup_v2.security_group.name]

  network {
    name = "private"
  }

  # Root volume (required for all instances)
  block_device {
    uuid                  = openstack_blockstorage_volume_v3.root_volumes_ceph[each.key].id
    source_type           = "volume"
    destination_type      = "volume"
    boot_index            = 0
    delete_on_termination = true
  }

  # Conditionally add storage volume only for OSD nodes
  dynamic "block_device" {
    for_each = each.key != "monitor01" ? [1] : []
    content {
      uuid                  = openstack_blockstorage_volume_v3.storage_volumes[each.key].id
      source_type           = "volume"
      destination_type      = "volume"
      boot_index            = 1
      delete_on_termination = true
    }
  }

  lifecycle {
    ignore_changes = [key_pair]
  }
}

# (The rest of your configuration remains unchanged...)

resource "openstack_networking_floatingip_v2" "ceph_floating_ips" {
  for_each = toset(var.storage_instance_names)

  pool = "public"
}

data "openstack_networking_port_v2" "k8s_ports" {
  for_each = toset(var.storage_instance_names)

  fixed_ip = openstack_compute_instance_v2.storage_instances[each.key].access_ip_v4
}

resource "openstack_networking_floatingip_associate_v2" "fip_assoc_ceph" {
  for_each = toset(var.storage_instance_names)

  floating_ip = openstack_networking_floatingip_v2.ceph_floating_ips[each.key].address
  port_id     = data.openstack_networking_port_v2.k8s_ports[each.key].id
}

output "floating_ips_ceph" {
  value = [for fip in openstack_networking_floatingip_v2.ceph_floating_ips : fip.address]
}

output "private_ips_ceph" {
  value = [for instance in openstack_compute_instance_v2.storage_instances : instance.network[0].fixed_ip_v4]
}