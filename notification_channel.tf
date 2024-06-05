resource "google_monitoring_notification_channel" "datametica_admin" {
  display_name = "Datametica DevOps Team"
  type         = "email"
  project      = var.ops_project_id
  labels = {
    email_address = "CSSDevOpsDatametica@zebra.com"
  }
  depends_on = [
    module.viq_services,
  ]
}

resource "google_monitoring_notification_channel" "GMSS_ST_DEVOPS" {
  display_name = "GMSS ST DEVOPS"
  type         = "email"
  project      = var.ops_project_id
  labels = {
    email_address = "GMSS-ST-DEVOPS@zebra.com"
  }
  depends_on = [
    module.viq_services,
  ]
}

resource "google_monitoring_notification_channel" "GMSS_DEVOPS" {
  display_name = "GMSS  DEVOPS"
  type         = "email"
  project      = var.ops_project_id
  labels = {
    email_address = "gmssdevops@zebra.com"
  }
  depends_on = [
    module.viq_services,
  ]
}