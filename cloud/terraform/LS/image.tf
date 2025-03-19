data "openstack_images_image_v2" "debian12" {
  name            = "Debian Bookworm 12 (SWITCHengines)"
  most_recent     = true
  visibility      = "public"
}

data "openstack_blockstorage_snapshot_v3" "opnsense_snapshot" {
  name        = "snapshot for snapshot for EdgeRouter_DHCP_WG_V2" 
  most_recent = true
}

data "openstack_blockstorage_snapshot_v3" "pfsense_snapshot" {
  name        = "snapshot for snapshot for Firewall" 
  most_recent = true
}