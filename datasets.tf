module "viq_st_bigquery_datasets" {
  source       = "./custom_modules/bigquery_dataset"
  for_each     = toset(var.bigquery_datasets)
  dataset_id   = each.key
  dataset_name = each.key
  project_id   = local.project_id
  location     = var.location
  access       = []
}

module "viq_qa_bq_data_editor_iam_bindings" {
  source     = "./custom_modules/bigquery_iam"
  project_id = local.project_id
  dataset_id = "viq_qa"
  role       = "roles/bigquery.dataEditor"
  members    = [
    "group:gcds-viq-st-alumnux-qa@zebra.com",
    "group:gcds-viq-st-qa@zebra.com"
  ]
  depends_on = [
    module.viq_st_bigquery_datasets,
  ]
}

module "viq_st_bigquery_dataset_viq_temp_tbl" {
  source       = "./custom_modules/bigquery_dataset"
  dataset_id   = "viq_temp_tbl"
  dataset_name = "viq_temp_tbl"
  project_id   = local.project_id
  location     = var.location
  default_table_expiration_ms = 3600000
  access       = []
}