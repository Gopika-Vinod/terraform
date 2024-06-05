# Internal Static IP Reserve 
module "internal_static_ip_reserve" {
  source       = "terraform-google-modules/address/google"
  version      = "3.1.3"
  project_id   = local.project_id
  region       = var.primary_region
  subnetwork   = module.vpc.subnets["${var.primary_region}/sb-${local.project_id}-compute-${var.primary_region}"]["id"]
  address_type = "INTERNAL"
  names = [
    "${local.project_id}-cloudsql-proxy-static-ip",
    "${local.project_id}-redis-vm-static-ip",
  ]
  enable_cloud_dns = false
  depends_on = [
    module.viq_services,
  ]
}
