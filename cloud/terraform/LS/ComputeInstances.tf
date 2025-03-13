
# Compute instances configuration
variable "compute_instances" {
  type = map(object({
    flavor_id = string
    network   = string  
  }))
  default = {
    "MediaServer" = {
      flavor_id = "4",
      network   = "private"
    },
    "MonitoringServer" = {
      flavor_id = "3",
      network   = "mgmt"
    },
    "WebServer" = {
      flavor_id = "3",
      network   = "dmz"
    }
  }
}

# Create ports on the correct network for each instance
locals {
  network_map = {
    "private" = openstack_networking_network_v2.private_network.id
    "mgmt"    = openstack_networking_network_v2.mgmt_network.id
    "dmz"     = openstack_networking_network_v2.dmz_network.id
  }
}

resource "openstack_networking_port_v2" "compute_ports" {
  for_each = var.compute_instances

  name                  = "${var.REGION}-${each.key}-port"
  network_id            = local.network_map[each.value.network]
  port_security_enabled = false
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

resource "openstack_compute_instance_v2" "compute_instances" {
  for_each = var.compute_instances

  name        = "${var.REGION}-${each.key}"
  flavor_id   = each.value.flavor_id
  key_pair    = var.SSH_KEYPAIR

  # Public network, floating IP
  network {
    name = "private"  
  }

  # Dedicated network interface, main infrastructure network
  network {
    port = openstack_networking_port_v2.compute_ports[each.key].id
  }

  # Root volume configuration
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

# Floating IPs for compute instances
resource "openstack_networking_floatingip_v2" "nodes_floating_ips" {
  for_each = var.compute_instances
  pool     = "public"
}

# Floating IP association (simplified)
resource "openstack_compute_floatingip_associate_v2" "fip_assoc" {
  for_each    = var.compute_instances
  floating_ip = openstack_networking_floatingip_v2.nodes_floating_ips[each.key].address
  instance_id = openstack_compute_instance_v2.compute_instances[each.key].id
}

# Updated outputs
output "nodes_floating_ips_nodes" {
  value = { for k, v in openstack_networking_floatingip_v2.nodes_floating_ips : k => v.address }
}

output "private_ips_nodes" {
  value = { for k, v in openstack_compute_instance_v2.compute_instances : k => v.network[1].fixed_ip_v4 }
}