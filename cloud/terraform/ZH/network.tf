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


# Network configuration
resource "openstack_networking_network_v2" "mgmt_network" {
  name           = "no-dhcp-network_mgmt"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "mgmt_subnet" {
  name            = "no-dhcp-subnet_mgmt"
  network_id      = openstack_networking_network_v2.mgmt_network.id
  cidr            = "192.168.10.0/24"
  ip_version      = 4
  enable_dhcp     = false
  no_gateway      = true
}
# Network configuration
resource "openstack_networking_network_v2" "dmz_network" {
  name           = "no-dhcp-network_dmz"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "dmz_subnet" {
  name            = "no-dhcp-subnet_dmz"
  network_id      = openstack_networking_network_v2.dmz_network.id
  cidr            = "192.168.20.0/24"
  ip_version      = 4
  enable_dhcp     = false
  no_gateway      = true
}

# ======================================
# Transfer Networks (Bridge Connections)
# ======================================
# resource "openstack_networking_network_v2" "transfer_private" {
#   name           = "transfer-private"
#   admin_state_up = "true"
# }

# resource "openstack_networking_subnet_v2" "transfer_private_subnet" {
#   name            = "transfer-private-subnet"
#   network_id      = openstack_networking_network_v2.transfer_private.id
#   cidr            = "192.168.100.0/24"
#   ip_version      = 4
#   enable_dhcp     = false
#   no_gateway      = true
# }

# resource "openstack_networking_network_v2" "transfer_mgmt" {
#   name           = "transfer-mgmt"
#   admin_state_up = "true"
# }

# resource "openstack_networking_subnet_v2" "transfer_mgmt_subnet" {
#   name            = "transfer-mgmt-subnet"
#   network_id      = openstack_networking_network_v2.transfer_mgmt.id
#   cidr            = "192.168.101.0/24"
#   ip_version      = 4
#   enable_dhcp     = false
#   no_gateway      = true
# }

# resource "openstack_networking_network_v2" "transfer_dmz" {
#   name           = "transfer-dmz"
#   admin_state_up = "true"
# }

# resource "openstack_networking_subnet_v2" "transfer_dmz_subnet" {
#   name            = "transfer-dmz-subnet"
#   network_id      = openstack_networking_network_v2.transfer_dmz.id
#   cidr            = "192.168.102.0/24"
#   ip_version      = 4
#   enable_dhcp     = false
#   no_gateway      = true
# }
