terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "HS25-WOSM"

    workspaces {
      name = "LS-SwitchEngines"
    }
  }
  


  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "2.0.0"
    }
  }
}
provider "openstack" {
  auth_url    = "https://keystone.cloud.switch.ch:5000/v3"  # OS_AUTH_URL
  region      = var.REGION                                  # OS_REGION_NAME
  tenant_name = "wosm_fs25_6ls_03"                          # OS_PROJECT_NAME
  user_name   = var.USER_EMAIL                              # OS_USERNAME
  password    = var.OPENSTACK_KEY                           # OS_PASSWORD
  domain_name = "Default"                                   # OS_USER_DOMAIN_NAME
}

