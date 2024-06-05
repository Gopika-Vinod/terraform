module "cloudsql_psc_vpc_internal_ip_range_reserve" {
  source        = "terraform-google-modules/address/google"
  version       = "3.1.3"
  region        = var.primary_region
  project_id    = local.project_id
  global        = true
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = var.private_service_access_cidr_prefix
  subnetwork    = module.vpc.network_self_link
  names         = [
    "psc-${local.project_id}-cloudsql"
  ] #var.private_service_access_names
  addresses     = var.private_service_access_cidr_ip
}

resource "google_service_networking_connection" "psc_vpc_private_service_access" {
  network                 = module.vpc.network_self_link
  service                 = "servicenetworking.googleapis.com"
   reserved_peering_ranges = [
    "psc-${local.project_id}-cloudsql"
  ]
  depends_on = [
    module.cloudsql_psc_vpc_internal_ip_range_reserve
  ]
}

