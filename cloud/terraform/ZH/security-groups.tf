# Security Group for Private Network (allows all traffic)
resource "openstack_networking_secgroup_v2" "private_secgroup" {
  name        = "private_secgroup"
  description = "Security group allowing all traffic for the private network"
}

# Allow all ingress traffic for IPv4
resource "openstack_networking_secgroup_rule_v2" "private_ingress_ipv4" {
  direction         = "ingress"
  ethertype         = "IPv4"
  security_group_id = openstack_networking_secgroup_v2.private_secgroup.id
  remote_ip_prefix  = "0.0.0.0/0"
}


# Allow all ingress traffic for IPv6
resource "openstack_networking_secgroup_rule_v2" "private_ingress_ipv6" {
  direction         = "ingress"
  ethertype         = "IPv6"
  security_group_id = openstack_networking_secgroup_v2.private_secgroup.id
  remote_ip_prefix  = "::/0"
}

# Default Security Group (allows SSH, HTTP, HTTPS)
resource "openstack_networking_secgroup_v2" "default_secgroup" {
  name        = "default_secgroup"
  description = "Security group allowing SSH, HTTP, and HTTPS"
}

# Allow SSH (port 22) for IPv4
resource "openstack_networking_secgroup_rule_v2" "default_ssh_ipv4" {
  direction         = "ingress"
  ethertype         = "IPv4"
  security_group_id = openstack_networking_secgroup_v2.default_secgroup.id
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
}

# Allow SSH (port 22) for IPv6
resource "openstack_networking_secgroup_rule_v2" "default_ssh_ipv6" {
  direction         = "ingress"
  ethertype         = "IPv6"
  security_group_id = openstack_networking_secgroup_v2.default_secgroup.id
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "::/0"
}

# Allow HTTP (port 80) for IPv4
resource "openstack_networking_secgroup_rule_v2" "default_http_ipv4" {
  direction         = "ingress"
  ethertype         = "IPv4"
  security_group_id = openstack_networking_secgroup_v2.default_secgroup.id
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
}

# Allow HTTP (port 80) for IPv6
resource "openstack_networking_secgroup_rule_v2" "default_http_ipv6" {
  direction         = "ingress"
  ethertype         = "IPv6"
  security_group_id = openstack_networking_secgroup_v2.default_secgroup.id
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "::/0"
}

# Allow HTTPS (port 443) for IPv4
resource "openstack_networking_secgroup_rule_v2" "default_https_ipv4" {
  direction         = "ingress"
  ethertype         = "IPv4"
  security_group_id = openstack_networking_secgroup_v2.default_secgroup.id
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  remote_ip_prefix  = "0.0.0.0/0"
}

# Allow HTTPS (port 443) for IPv6
resource "openstack_networking_secgroup_rule_v2" "default_https_ipv6" {
  direction         = "ingress"
  ethertype         = "IPv6"
  security_group_id = openstack_networking_secgroup_v2.default_secgroup.id
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  remote_ip_prefix  = "::/0"
}

# ALLOW UDP on 51820 for WireGuard
resource "openstack_networking_secgroup_rule_v2" "wireguard_udp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  security_group_id = openstack_networking_secgroup_v2.default_secgroup.id
  protocol          = "udp"
  port_range_min    = 51820
  port_range_max    = 51820
  remote_ip_prefix  = "0.0.0.0/0"
}