provider "google" {
  project = local.project_id
  region = var.primary_region
}
provider "google-beta" {
  project = local.project_id
  region = var.primary_region
}
provider "local" {
  # Configuration options
}

locals {
  # us_location = "US"
  project_id          = "${var.project_prefix}-${var.country}-${var.env}"
  project_number      = data.google_project.project.number
  sa_infra_np_jenk = "sa-viq-st-${var.country}-infra-np-jenk-${var.env=="d" || var.env=="t" ? "dt" : "s" }@viq-st-${var.country}-infra-np-s.iam.gserviceaccount.com"
  sa_app_np_jenk = "sa-viq-st-na-app-np-jenk-${var.env=="d" || var.env=="t" ? "dt" : "s" }@viq-st-na-infra-np-s.iam.gserviceaccount.com"
}

data "google_project" "project" {
  project_id = local.project_id
}

resource "google_compute_project_metadata" "default" {
  project = local.project_id
  metadata = {
    block-project-ssh-keys = "TRUE"
    enable-oslogin         = "TRUE"
  }
}
