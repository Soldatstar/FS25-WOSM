# Network configuration
resource "openstack_networking_network_v2" "private_network" {
  name           = "no-dhcp-network"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "private_subnet" {
  name            = "no-dhcp-subnet"
  network_id      = openstack_networking_network_v2.private_network.id
  cidr            = "192.168.0.0/24"
  ip_version      = 4
  enable_dhcp     = false
  no_gateway      = true
}

/* # Attach the "allow all" security group to the private network port
resource "openstack_networking_port_secgroup_associate_v2" "private_port_secgroup" {
  port_id = openstack_compute_instance_v2.opnsense.network[1].port  # Use the port ID of the private network interface
  security_group_ids = [
    openstack_networking_secgroup_v2.private_secgroup.id
  ]
} */