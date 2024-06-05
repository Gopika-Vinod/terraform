resource "google_bigquery_dataset_iam_member" "google_bigquery_dataset_iam_additive" {
  for_each   = toset(var.members)
  dataset_id = var.dataset_id
  role       = var.role
  project    = var.project_id
  member     = each.key
}