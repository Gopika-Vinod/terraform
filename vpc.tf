#######################################
################ VPC ##################      
#######################################
module "vpc" {
  source           = "terraform-google-modules/network/google"
  version          = "7.1.0"
  project_id       = local.project_id
  network_name     = "${local.project_id}-vpc-${lower(var.location)}"
  routing_mode     ="GLOBAL"
  description      = "Terraform Managed VPC"
  subnets          = var.vpc_subnets
  secondary_ranges = var.vpc_secondary_ranges
  depends_on = [
    module.viq_services,
  ]
}