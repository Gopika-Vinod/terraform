module "cloud_router_nat" {
  source  = "terraform-google-modules/cloud-router/google"
  version = "5.0.1"
  name    = "cr-nat-${local.project_id}-vpc-${var.primary_region}"
  project = local.project_id
  region  = var.primary_region
  network = module.vpc.network_name
}