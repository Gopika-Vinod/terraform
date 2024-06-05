module "viq_svpc_conn_1" {
  source     = "terraform-google-modules/network/google//modules/vpc-serverless-connector-beta"
  version = "7.1.0"
  project_id = local.project_id
  vpc_connectors = [
    {
      name            = "svpc-conn-${var.primary_region}-1"
      region          = var.primary_region
      subnet_name     = "sb-${local.project_id}-cloudrun01-${var.primary_region}"
      host_project_id = local.project_id
      machine_type  = "e2-standard-4"
      min_instances =  2
      max_instances =  3
      max_throughput= 300
    },
    {
      name            = "svpc-conn-${var.primary_region}-2"
      region          = var.primary_region
      subnet_name     = "sb-${local.project_id}-cloudfunction01-${var.primary_region}"
      host_project_id = local.project_id
      machine_type  = "e2-standard-4"
      min_instances =  2
      max_instances =  3
      max_throughput= 300
    }
  ]
  depends_on = [
    module.viq_services,
    module.vpc,
  ]
}





