module "viq_services" {
  source        = "terraform-google-modules/project-factory/google//modules/project_services"
  version       = "14.2.1"
  project_id    = local.project_id
  activate_apis = [
    "serviceusage.googleapis.com",
    "iam.googleapis.com",
    "monitoring.googleapis.com",
    "logging.googleapis.com",
    "bigquery.googleapis.com",
    "bigquerystorage.googleapis.com",
    "storage.googleapis.com",
    "compute.googleapis.com",
    "dataflow.googleapis.com",
    "container.googleapis.com",
    "secretmanager.googleapis.com",
    "sqladmin.googleapis.com",
    "servicenetworking.googleapis.com",
    "bigquerydatatransfer.googleapis.com",
    "storage-component.googleapis.com",
    "pubsub.googleapis.com",
    "osconfig.googleapis.com",
    "containeranalysis.googleapis.com",
    "dataproc.googleapis.com",
    "vpcaccess.googleapis.com",
    "composer.googleapis.com",
    "eventarc.googleapis.com",
  ]
}