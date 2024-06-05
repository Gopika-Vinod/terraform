module "cloud_nat_external_static_ip_reserve" {
  source           = "terraform-google-modules/address/google"
  version          = "3.1.3"
  project_id       = local.project_id
  region           = var.primary_region
  address_type     = "EXTERNAL"
  names            = ["nat-${local.project_id}-vpc-static-ip"]
  enable_cloud_dns = false
  depends_on = [
    module.viq_services,
  ]
}
