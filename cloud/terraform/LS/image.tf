data "openstack_images_image_v2" "debian12" {
  name            = "Debian Bookworm 12 (SWITCHengines)"
  most_recent     = true
  visibility      = "public"
}

data "openstack_blockstorage_snapshot_v3" "opnsense_snapshot" {
  name        = "snapshot for LS-ER-opnsense11-04-25" 
  most_recent = true
}

data "openstack_blockstorage_snapshot_v3" "pfsense_snapshot" {
  name        = "snapshot for LS-FW-pfsense11-04-25" 
  most_recent = true
}