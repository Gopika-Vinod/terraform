# Cloud SQL Pxoxy VM Service Account
module "sa_viq_cloudsql_proxy" {
  source     = "terraform-google-modules/service-accounts/google"
  version    = "4.2.1"
  project_id = local.project_id
  prefix     = "sa-${local.project_id}"
  names = [
    "sql-proxy"
  ]
  project_roles = [
    "${local.project_id}=>roles/cloudsql.client",
    "${local.project_id}=>roles/logging.logWriter",
    "${local.project_id}=>roles/monitoring.metricWriter",
  ]
  depends_on = [
    module.viq_services,
  ]
}
# Composer Service Account
module "sa_viq_composer" {
  source     = "terraform-google-modules/service-accounts/google"
  version    = "4.2.1"
  project_id = local.project_id
  prefix     = "sa-${local.project_id}"
  names = [
    "composer"
  ]
  project_roles = [

    "${local.project_id}=>roles/bigquery.dataEditor",
    "${local.project_id}=>roles/bigquery.jobUser",
    "${local.project_id}=>roles/bigquery.readSessionUser",
    "${local.project_id}=>roles/dataproc.editor",
    "${local.project_id}=>roles/composer.worker",
    "${local.project_id}=>roles/composer.ServiceAgentV2Ext",
    "${local.project_id}=>roles/dataflow.developer",
    "${local.project_id}=>roles/logging.logWriter",
    "${local.project_id}=>roles/storage.objectAdmin",
    "${local.project_id}=>organizations/463373134989/roles/CustomRole85" #custom storage bucket viewer
  ]
  depends_on = [
    module.viq_services,
  ]
}

# Cloud Run Service Account
module "sa_viq_cloud_run" {
  source     = "terraform-google-modules/service-accounts/google"
  version    = "4.2.1"
  project_id = local.project_id
  prefix     = "sa-${local.project_id}"
  names = [
    "cloud-run"
  ]
  project_roles = [
    "${local.project_id}=>roles/bigquery.jobUser",
    "${local.project_id}=>roles/bigquery.dataEditor",
    "${local.project_id}=>roles/pubsub.subscriber",
    "${local.project_id}=>roles/storage.objectViewer",
  ]
  depends_on = [
    module.viq_services,
  ]
}


# Dataflow Service Account
module "sa_viq_dataflow" {
  source     = "terraform-google-modules/service-accounts/google"
  version    = "4.2.1"
  project_id = local.project_id
  prefix     = "sa-${local.project_id}"
  names = [
    "dataflow"
  ]
  project_roles = [
    "${local.project_id}=>roles/bigquery.dataEditor",
    "${local.project_id}=>roles/dataflow.developer",
    "${local.project_id}=>roles/bigquery.jobUser",
    "${local.project_id}=>roles/logging.logWriter",
    "${local.project_id}=>roles/monitoring.metricWriter",
    "${local.project_id}=>roles/pubsub.publisher",
    "${local.project_id}=>roles/pubsub.viewer",
    "${local.project_id}=>roles/pubsub.subscriber",
    "${local.project_id}=>roles/storage.objectAdmin",
    "${local.project_id}=>organizations/463373134989/roles/CustomRole85", #custom storage bucket viewer
    "${local.project_id}=>roles/cloudfunctions.invoker",
    "${local.project_id}=>roles/redis.viewer",
  ]
  depends_on = [
    module.viq_services,
  ]
}

# Dataproc Service Account
module "sa_viq_dataproc" {
  source     = "terraform-google-modules/service-accounts/google"
  version    = "4.2.1"
  project_id = local.project_id
  prefix     = "sa-${local.project_id}"
  names = [
    "dataproc"
  ]
  project_roles = [
    "${local.project_id}=>roles/bigquery.dataEditor",
    "${local.project_id}=>roles/dataproc.worker",
    "${local.project_id}=>roles/bigquery.jobUser",
    "${local.project_id}=>roles/bigquery.readSessionUser",
    "${local.project_id}=>roles/dataproc.editor",
    "${local.project_id}=>roles/storage.objectAdmin",
    "${local.project_id}=>organizations/463373134989/roles/CustomRole85" #custom storage bucket viewer
  ]
  depends_on = [
    module.viq_services,
  ]
}

module "sa_viq_dataproc_phs" {
  source     = "terraform-google-modules/service-accounts/google"
  version    = "4.2.1"
  project_id = local.project_id
  prefix     = "sa-${local.project_id}"
  names = [
    "dataproc-phs"
  ]
  project_roles = [
    "${local.project_id}=>roles/dataproc.worker",
  ]
  depends_on = [
    module.viq_services,
  ]
}

# Looker Service Account
module "sa_viq_looker" {
  source     = "terraform-google-modules/service-accounts/google"
  version    = "4.2.1"
  project_id = local.project_id
  prefix     = "sa-${local.project_id}"
  names = [
    "looker"
  ]
  project_roles = [
    "${local.project_id}=>roles/bigquery.jobUser",
  ]
  depends_on = [
    module.viq_services,
  ]
}
# Cloud Function Service Account
module "sa_viq_cloudfunction" {
  source     = "terraform-google-modules/service-accounts/google"
  version    = "4.2.1"
  project_id = local.project_id
  prefix     = "sa-${local.project_id}"
  names = [
    "cloudfunction"
  ]
  project_roles = [
    "${local.project_id}=>roles/bigquery.jobUser",
    "${local.project_id}=>roles/bigquery.dataEditor",
    "${local.project_id}=>roles/clouddeploy.developer",
    "${local.project_id}=>roles/cloudfunctions.developer",
    "${local.project_id}=>roles/cloudfunctions.invoker",
    "${local.project_id}=>roles/cloudfunctions.serviceAgent",
    "${local.project_id}=>roles/pubsub.serviceAgent",
    "${local.project_id}=>roles/run.developer",
    "${local.project_id}=>roles/run.invoker",
    "${local.project_id}=>roles/run.serviceAgent",
    # "${local.project_id}=>roles/storage.admin",
    "${local.project_id}=>roles/pubsub.publisher",
    "${local.project_id}=>roles/workloadmanager.serviceAgent",

  ]
  depends_on = [
    module.viq_services,
  ]
}


########################################
######## Service Account Level IAM #####
########################################

module "sa_viq_iam_bindings" {
  source           = "terraform-google-modules/iam/google//modules/service_accounts_iam"
  version          = "7.6.0"
  service_accounts = [
    "sa-${local.project_id}-sql-proxy@${local.project_id}.iam.gserviceaccount.com",
    "sa-${local.project_id}-composer@${local.project_id}.iam.gserviceaccount.com",
    "sa-${local.project_id}-cloud-run@${local.project_id}.iam.gserviceaccount.com",
    "sa-${local.project_id}-dataflow@${local.project_id}.iam.gserviceaccount.com",
    "sa-${local.project_id}-dataproc@${local.project_id}.iam.gserviceaccount.com",
    "sa-${local.project_id}-dataproc-phs@${local.project_id}.iam.gserviceaccount.com",
    "sa-${local.project_id}-looker@${local.project_id}.iam.gserviceaccount.com",
    "sa-${local.project_id}-cloudfunction@${local.project_id}.iam.gserviceaccount.com"
  ]
  project  = local.project_id
  mode     = "additive"
  bindings = {
    "roles/iam.serviceAccountUser" = [
      "group:gcds-viq-st-lead@zebra.com",
      "serviceAccount:${local.sa_infra_np_jenk}",
      "serviceAccount:${local.sa_app_np_jenk}",
      "serviceAccount:sa-${local.project_id}-composer@${local.project_id}.iam.gserviceaccount.com",
    ]
  }
  depends_on = [
    module.sa_viq_cloudsql_proxy,
    module.sa_viq_composer,
    module.sa_viq_cloud_run,
    module.sa_viq_dataflow,
    module.sa_viq_dataproc,
    module.sa_viq_dataproc_phs,
    module.sa_viq_looker,
    module.sa_viq_cloudfunction,
  ]
}
# Redis VM Service Account
# module "sa_viq_redis_vm" {
#   source     = "terraform-google-modules/service-accounts/google"
#   version    = "4.2.1"
#   project_id = local.project_id
#   prefix     = "sa-${local.project_id}"
#   names = [
#     "redis-vm"
#   ]
#   project_roles = [
#   ]
#   depends_on = [
#     module.viq_services,
#   ]
# }
# Sisense Service Account
module "sa_viq_sisense" {
  source     = "terraform-google-modules/service-accounts/google"
  version    = "4.2.1"
  project_id = local.project_id
  prefix     = "sa-${local.project_id}"
  names = [
    "sisense"
  ]
  project_roles = [
  "${local.project_id}=>roles/bigquery.dataViewer",
	"${local.project_id}=>roles/bigquery.jobUser",
	"${local.project_id}=>roles/bigquery.metadataViewer",
  ]
  depends_on = [
    module.viq_services,
  ]
}
# module "sa_viq_jirabigquery" {
#   source     = "terraform-google-modules/service-accounts/google"
#   version    = "4.2.1"
#   project_id = local.project_id
#   prefix     = "sa-${local.project_id}"
#   names = [
#     "jirabigquery"
#   ]
#   project_roles = [
#     local.project_id == "viq-st-na-t" ? "roles/bigquery.user" :null,
#   ]
#   depends_on = [
#     module.viq_services,
#   ]
# }



 