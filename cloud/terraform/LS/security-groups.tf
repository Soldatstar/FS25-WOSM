


resource "openstack_networking_secgroup_v2" "security_group" {
  name        = "initial_sec_grp"
  description = "Security group for SSH and all egress traffic"
}

resource "openstack_networking_secgroup_rule_v2" "ICMP" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  security_group_id = openstack_networking_secgroup_v2.security_group.id
  remote_ip_prefix  = "0.0.0.0/0"
}


resource "openstack_networking_secgroup_rule_v2" "ingress_ipv4" {
  direction         = "ingress"
  ethertype         = "IPv4"
  security_group_id = openstack_networking_secgroup_v2.security_group.id
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
}

resource "openstack_networking_secgroup_rule_v2" "ingress_ipv6" {
  direction         = "ingress"
  ethertype         = "IPv6"
  security_group_id = openstack_networking_secgroup_v2.security_group.id
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "::/0"
}

resource "openstack_networking_secgroup_rule_v2" "ceph_osd" {
  direction         = "ingress"
  ethertype         = "IPv4"
  security_group_id = openstack_networking_secgroup_v2.security_group.id
  protocol          = "tcp"
  port_range_min    = 6800
  port_range_max    = 7300
  remote_ip_prefix  = "10.0.0.0/8"
}

resource "openstack_networking_secgroup_rule_v2" "ceph_daemons1" {
  direction         = "ingress"
  ethertype         = "IPv4"
  security_group_id = openstack_networking_secgroup_v2.security_group.id
  protocol          = "tcp"
  port_range_min    = 3300
  port_range_max    = 3300
  remote_ip_prefix  = "10.0.0.0/8"
}

resource "openstack_networking_secgroup_rule_v2" "ceph_daemons2" {
  direction         = "ingress"
  ethertype         = "IPv4"
  security_group_id = openstack_networking_secgroup_v2.security_group.id
  protocol          = "tcp"
  port_range_min    = 6789
  port_range_max    = 6789
  remote_ip_prefix  = "10.0.0.0/8"
}