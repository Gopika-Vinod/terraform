
resource "google_bigquery_dataset" "main" {
  friendly_name              = var.dataset_name
  description                = var.description
  location                   = var.location
  delete_contents_on_destroy = var.delete_contents_on_destroy
  project                    = var.project_id
  labels                     = var.dataset_labels
  dataset_id                 = var.dataset_id
  max_time_travel_hours           = "168"
  default_table_expiration_ms = var.default_table_expiration_ms
  dynamic "default_encryption_configuration" {
    for_each = var.encryption_key == null ? [] : [var.encryption_key]
    content {
      kms_key_name = var.encryption_key
    }
  }
  dynamic "access" {
    for_each = var.access
    content {
      # BigQuery API converts IAM to primitive roles in its backend.
      # This causes Terraform to show a diff on every plan that uses IAM equivalent roles.
      # Thus, do the conversion between IAM to primitive role here to prevent the diff.
      role = lookup(local.iam_to_primitive, access.value.role, access.value.role)

      domain         = lookup(access.value, "domain", null)
      group_by_email = lookup(access.value, "group_by_email", null)
      user_by_email  = lookup(access.value, "user_by_email", null)
      special_group  = lookup(access.value, "special_group", null)
    }
  }
  lifecycle {
    ignore_changes = [access]
  }
}

locals {
  iam_to_primitive = {
    "roles/bigquery.dataOwner" : "OWNER"
    "roles/bigquery.dataEditor": "WRITER"
    "roles/bigquery.dataViewer": "READER"
  }
}