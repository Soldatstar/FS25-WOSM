

# OPNsense Instance
resource "openstack_blockstorage_volume_v3" "opnsense_root" {
  name              = "opnsense-root-volume"
  size              = 20  
  description       = "OPNSense root volume"
  availability_zone = "nova"
  snapshot_id       = data.openstack_blockstorage_snapshot_v3.opnsense_snapshot.id

      lifecycle {
    ignore_changes = [snapshot_id]  
  }

}

resource "openstack_compute_instance_v2" "opnsense" {
  name              = "${var.REGION}-opnsense"
  flavor_id         = "3" 
  key_pair          = var.SSH_KEYPAIR
    security_groups   = [
    openstack_networking_secgroup_v2.default_secgroup.name,
  ]

  # Connection to existing private network (for public access)
  network {
    name = "private"
  }

  # Connection to new no-DHCP network
  network {
    name = openstack_networking_network_v2.private_network.name
    fixed_ip_v4 = "192.168.0.1"
  
  }

  block_device {
    uuid                  = openstack_blockstorage_volume_v3.opnsense_root.id
    source_type           = "volume"
    destination_type      = "volume"
    boot_index            = 0
    delete_on_termination = true
  }

  lifecycle {
    ignore_changes = [key_pair]
  }
}

# Floating IP Configuration
resource "openstack_networking_floatingip_v2" "opnsense_fip" {
  pool = "public"
}

# Network port data source for floating IP association
data "openstack_networking_port_v2" "opnsense_port" {
  fixed_ip = openstack_compute_instance_v2.opnsense.access_ip_v4
}

resource "openstack_networking_floatingip_associate_v2" "fip_assoc_opnsense" {
  floating_ip = openstack_networking_floatingip_v2.opnsense_fip.address
  port_id     = data.openstack_networking_port_v2.opnsense_port.id
}

# Outputs
output "opnsense_floating_ip" {
  value = openstack_networking_floatingip_v2.opnsense_fip.address
}

output "opnsense_private_ips" {
  value = openstack_compute_instance_v2.opnsense.network[*].fixed_ip_v4
}