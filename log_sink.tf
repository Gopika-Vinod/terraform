module "admin_activity_audit_log_export_sink" {
  source                 = "terraform-google-modules/log-export/google"
  version                = "7.6.0"
  destination_uri        = module.admin_activity_audit_log_export_sink_dataset.destination_uri
  log_sink_name          = "sink-${local.project_id}-admin-activity-logs"
  filter                 = "logName=\"projects/${local.project_id}/logs/cloudaudit.googleapis.com%2Factivity\""
  parent_resource_id     = local.project_id
  parent_resource_type   = "project"
  unique_writer_identity = true
  depends_on = [
    module.viq_services,
  ]
}

module "admin_activity_audit_log_export_sink_dataset" {
  source                   = "terraform-google-modules/log-export/google//modules/bigquery"
  version                  = "7.6.0"
  project_id               = var.ops_project_id
  location                 = var.location
  dataset_name             = "${replace(local.project_id, "-", "_")}_admin_activity_logs"
  log_sink_writer_identity = module.admin_activity_audit_log_export_sink.writer_identity
  depends_on = [
    module.viq_services,
  ]
}

module "bigquery_data_access_audit_log_export_sink" {
  source                 = "terraform-google-modules/log-export/google"
  version                = "7.6.0"
  destination_uri        = module.bigquery_data_access_audit_log_export_sink_dataset.destination_uri
  log_sink_name          = "sink-${local.project_id}-bigquery-data-access-logs"
  filter                 = "resource.type = (\"bigquery_project\" OR \"bigquery_dataset\")"
  parent_resource_id     = local.project_id
  parent_resource_type   = "project"
  unique_writer_identity = true
}

module "bigquery_data_access_audit_log_export_sink_dataset" {
  source                   = "terraform-google-modules/log-export/google//modules/bigquery"
  version                  = "7.6.0"
  project_id               = var.ops_project_id
  location                 = var.location
  dataset_name             = "${replace(local.project_id, "-", "_")}_bigquery_data_access_logs"
  log_sink_writer_identity = module.bigquery_data_access_audit_log_export_sink.writer_identity
  depends_on = [
    module.viq_services,
  ]
}

