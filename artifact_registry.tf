###################################################
############ Artifact Registry Reposistory ########
###################################################
resource "google_artifact_registry_repository" "ar_viq_fs" {
  provider      = google-beta
  location      = var.artifact_location
  project       = local.project_id
  repository_id = "ar-${local.project_id}"
  description   = "Artifact registry to store docker images for viq"
  format        = "DOCKER"
}

# #######################################
# ############# IAM Bindings ############
# #######################################

module "artifact-registry-repository-iam-bindings" {
  source   = "terraform-google-modules/iam/google//modules/artifact_registry_iam"
  version = "7.6.0"
  project      = local.project_id
  repositories = [
    "ar-${local.project_id}"
  ]
  location     = var.artifact_location
  mode         = "additive"
  bindings = {
    "roles/run.serviceAgent" = [
      # Google Cloud Run Service Agent
      "serviceAccount:service-${local.project_number}@serverless-robot-prod.iam.gserviceaccount.com"
    ]
  }
}


