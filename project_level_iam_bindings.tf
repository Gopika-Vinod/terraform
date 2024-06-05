module "viq_project_level_iam_bindings" {
  source   = "terraform-google-modules/iam/google//modules/projects_iam"
  version = "7.6.0"
  projects = [local.project_id]
  mode     = "additive"

  bindings = var.viq_project_level_iam_bindings
  depends_on = [
    module.viq_services,
  ]
}
