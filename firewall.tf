############################################
##### VPC Firewall Rules  ##################
############################################
module "vpc_firewall" {
  source                  = "terraform-google-modules/network/google//modules/fabric-net-firewall"
  version                 = "7.1.0"
  project_id              = local.project_id
  network                 = module.vpc.network_name
  internal_ranges_enabled = false
  internal_ranges         = []
  internal_target_tags    = []
  ssh_source_ranges       = []
  ssh_target_tags         = []
  https_target_tags       = []
  https_source_ranges     = []
  http_source_ranges      = []
  custom_rules            = var.common_firewall_rules
}
