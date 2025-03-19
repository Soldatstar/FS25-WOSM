# EdgeRouter.tf - Updated for Transfer Network Connections

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

# ======================================
# Transfer Network Ports
# ======================================
resource "openstack_networking_port_v2" "opnsense_transfer_private" {
  name                  = "${var.REGION}-opnsense-transfer-private"
  network_id            = openstack_networking_network_v2.transfer_private.id
  port_security_enabled = false
  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.transfer_private_subnet.id
    ip_address = "192.168.100.1"  # Gateway IP for transfer-private
  }
}

resource "openstack_networking_port_v2" "opnsense_transfer_mgmt" {
  name                  = "${var.REGION}-opnsense-transfer-mgmt"
  network_id            = openstack_networking_network_v2.transfer_mgmt.id
  port_security_enabled = false
  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.transfer_mgmt_subnet.id
    ip_address = "192.168.101.1"  # Gateway IP for transfer-mgmt
  }
}

resource "openstack_networking_port_v2" "opnsense_transfer_dmz" {
  name                  = "${var.REGION}-opnsense-transfer-dmz"
  network_id            = openstack_networking_network_v2.transfer_dmz.id
  port_security_enabled = false
  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.transfer_dmz_subnet.id
    ip_address = "192.168.102.1"  # Gateway IP for transfer-dmz
  }
}

# ======================================
# OPNsense Instance Configuration
# ======================================
resource "openstack_compute_instance_v2" "opnsense" {
  name              = "${var.REGION}-opnsense"
  flavor_id         = "3" 
  key_pair          = var.SSH_KEYPAIR
  security_groups   = [openstack_networking_secgroup_v2.default_secgroup.name]

  # Public network interface (external)
  network {
    name = "private"  # This should be your public/external network
  }

  # Transfer network interfaces
  network {
    port = openstack_networking_port_v2.opnsense_transfer_private.id
  }

  network {
    port = openstack_networking_port_v2.opnsense_transfer_mgmt.id
  }

  network {
    port = openstack_networking_port_v2.opnsense_transfer_dmz.id
  }

  # Root volume configuration
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

# ======================================
# Floating IP Configuration (Unchanged)
# ======================================
resource "openstack_networking_floatingip_v2" "opnsense_fip" {
  pool = "public"
}

resource "openstack_compute_floatingip_associate_v2" "fip_assoc_opnsense" {
  floating_ip = openstack_networking_floatingip_v2.opnsense_fip.address
  instance_id = openstack_compute_instance_v2.opnsense.id
}

# ======================================
# Updated Outputs
# ======================================
output "opnsense_floating_ip" {
  value = openstack_networking_floatingip_v2.opnsense_fip.address
}

output "opnsense_transfer_ips" {
  value = {
    transfer_private = "192.168.100.1"
    transfer_mgmt    = "192.168.101.1"
    transfer_dmz     = "192.168.102.1"
  }
}