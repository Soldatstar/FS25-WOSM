

# ======================================
# pfSense Port Configuration 
# ======================================
# Transfer Network Ports (Bridge Side A)
resource "openstack_networking_port_v2" "pfsense_transfer_private" {
  name                  = "${var.REGION}-pfsense-transfer-private"
  network_id            = openstack_networking_network_v2.transfer_private.id
  port_security_enabled = false
  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.transfer_private_subnet.id
    ip_address = "192.168.100.2"  # Added fixed IP
  }
}

resource "openstack_networking_port_v2" "pfsense_transfer_mgmt" {
  name                  = "${var.REGION}-pfsense-transfer-mgmt"
  network_id            = openstack_networking_network_v2.transfer_mgmt.id
  port_security_enabled = false
  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.transfer_mgmt_subnet.id
    ip_address = "192.168.101.2"  # Added fixed IP
  }
}

resource "openstack_networking_port_v2" "pfsense_transfer_dmz" {
  name                  = "${var.REGION}-pfsense-transfer-dmz"
  network_id            = openstack_networking_network_v2.transfer_dmz.id
  port_security_enabled = false
  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.transfer_dmz_subnet.id
    ip_address = "192.168.102.2"  # Added fixed IP
  }
}

# Internal Network Ports (Bridge Side B)
resource "openstack_networking_port_v2" "pfsense_internal_private" {
  name                  = "${var.REGION}-pfsense-internal-private"
  network_id            = openstack_networking_network_v2.private_network.id
  port_security_enabled = false
  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.private_subnet.id
    ip_address = "192.168.0.254"  # Added fixed IP
  }
}

resource "openstack_networking_port_v2" "pfsense_internal_mgmt" {
  name                  = "${var.REGION}-pfsense-internal-mgmt"
  network_id            = openstack_networking_network_v2.mgmt_network.id
  port_security_enabled = false
  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.mgmt_subnet.id
    ip_address = "192.168.10.254"  # Added fixed IP
  }
}

resource "openstack_networking_port_v2" "pfsense_internal_dmz" {
  name                  = "${var.REGION}-pfsense-internal-dmz"
  network_id            = openstack_networking_network_v2.dmz_network.id
  port_security_enabled = false
  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.dmz_subnet.id
    ip_address = "192.168.20.254"  # Added fixed IP
  }
}


# ======================================
# pfSense Instance Configuration
# ======================================

resource "openstack_blockstorage_volume_v3" "pfsense_root" {
  name              = "pfsense-root-volume"
  size              = 20  
  description       = "pfsense root volume"
  availability_zone = "nova"
  snapshot_id       = data.openstack_blockstorage_snapshot_v3.pfsense_snapshot.id

  lifecycle {
    ignore_changes = [snapshot_id]  
  }
}

resource "openstack_compute_instance_v2" "pfsense" {
  name              = "${var.REGION}-pfsense"
  flavor_id         = "3"  # Medium flavor
  key_pair          = var.SSH_KEYPAIR
  security_groups   = [openstack_networking_secgroup_v2.default_secgroup.name]

  # Bridge Interfaces (Transfer Networks)
    network {
    name = "private"  # Public network for management
  }

  network {
    port = openstack_networking_port_v2.pfsense_transfer_private.id
  }
  network {
    port = openstack_networking_port_v2.pfsense_transfer_mgmt.id
  }
  network {
    port = openstack_networking_port_v2.pfsense_transfer_dmz.id
  }

  # Bridge Interfaces (Internal Networks)
  network {
    port = openstack_networking_port_v2.pfsense_internal_private.id
  }
  network {
    port = openstack_networking_port_v2.pfsense_internal_mgmt.id
  }
  network {
    port = openstack_networking_port_v2.pfsense_internal_dmz.id
  }

  # Management interface (optional)

  block_device {
    uuid                  = openstack_blockstorage_volume_v3.pfsense_root.id
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
# Floating IP Configuration
# ======================================
resource "openstack_networking_floatingip_v2" "pfsense_fip" {
  pool = "public"
}

resource "openstack_compute_floatingip_associate_v2" "fip_assoc_pfsense" {
  floating_ip = openstack_networking_floatingip_v2.pfsense_fip.address
  instance_id = openstack_compute_instance_v2.pfsense.id
}

# ======================================
# Outputs
# ======================================
output "pfsense_floating_ip" {
  value = openstack_networking_floatingip_v2.pfsense_fip.address
}

output "pfsense_bridge_ports" {
  value = {
    transfer_private = openstack_networking_port_v2.pfsense_transfer_private.id
    transfer_mgmt    = openstack_networking_port_v2.pfsense_transfer_mgmt.id
    transfer_dmz     = openstack_networking_port_v2.pfsense_transfer_dmz.id
    internal_private = openstack_networking_port_v2.pfsense_internal_private.id
    internal_mgmt    = openstack_networking_port_v2.pfsense_internal_mgmt.id
    internal_dmz     = openstack_networking_port_v2.pfsense_internal_dmz.id
  }
}