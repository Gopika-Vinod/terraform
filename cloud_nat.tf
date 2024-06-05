module "cloud_nat" {
  source                              = "terraform-google-modules/cloud-nat/google"
  version                             = "4.0.0"
  name                                = "ngw-${local.project_id}-vpc-${var.primary_region}"
  project_id                          = local.project_id
  region                              = var.primary_region
  router                              = module.cloud_router_nat.router.name
  min_ports_per_vm                    = 64
  source_subnetwork_ip_ranges_to_nat  = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  enable_endpoint_independent_mapping = false
  nat_ips                             = module.cloud_nat_external_static_ip_reserve.self_links
}