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

# Create ports with fixed IPs defined at the port level
resource "openstack_networking_port_v2" "opnsense_private_port" {
  name                  = "${var.REGION}-opnsense-private-port"
  network_id            = openstack_networking_network_v2.private_network.id
  port_security_enabled = false
  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.private_subnet.id
    ip_address = "192.168.0.1"  # IP defined here, not in instance
  }
}

resource "openstack_networking_port_v2" "opnsense_mgmt_port" {
  name                  = "${var.REGION}-opnsense-mgmt-port"
  network_id            = openstack_networking_network_v2.mgmt_network.id
  port_security_enabled = false
  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.mgmt_subnet.id
    ip_address = "192.168.10.1"  
  }
}

resource "openstack_networking_port_v2" "opnsense_dmz_port" {
  name                  = "${var.REGION}-opnsense-dmz-port"
  network_id            = openstack_networking_network_v2.dmz_network.id
  port_security_enabled = false
  fixed_ip {
    subnet_id =  openstack_networking_subnet_v2.dmz_subnet.id
    ip_address = "192.168.20.1" 
  }
}

resource "openstack_compute_instance_v2" "opnsense" {
  name              = "${var.REGION}-opnsense"
  flavor_id         = "3" 
  key_pair          = var.SSH_KEYPAIR
  security_groups   = [openstack_networking_secgroup_v2.default_secgroup.name]

  # Public network (for floating IP)
  network {
    name = "private"
  }

  # Private network interface
  network {
    port = openstack_networking_port_v2.opnsense_private_port.id
  }

  # Mgmt network interface
  network {
    port = openstack_networking_port_v2.opnsense_mgmt_port.id
  }

  # DMZ network interface
  network {
    port = openstack_networking_port_v2.opnsense_dmz_port.id
  }

  # Root volume (boot device)
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

# Floating IP association (simplified)
#resource "openstack_networking_floatingip_associate_v2" "fip_assoc_opnsense" {
#  floating_ip = openstack_networking_floatingip_v2.opnsense_fip.address
#  instance_id = openstack_compute_instance_v2.opnsense.id
#}

resource "openstack_compute_floatingip_associate_v2" "fip_assoc_opnsense" {
  floating_ip = openstack_networking_floatingip_v2.opnsense_fip.address
  instance_id = openstack_compute_instance_v2.opnsense.id
  
}
# Outputs
output "opnsense_floating_ip" {
  value = openstack_networking_floatingip_v2.opnsense_fip.address
}

output "opnsense_private_ips" {
  value = {
    private = openstack_networking_port_v2.opnsense_private_port.fixed_ip[0].ip_address
    mgmt    = openstack_networking_port_v2.opnsense_mgmt_port.fixed_ip[0].ip_address
    dmz     = openstack_networking_port_v2.opnsense_dmz_port.fixed_ip[0].ip_address
  }
}