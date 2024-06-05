resource "google_monitoring_monitored_project" "monitoring_scope" {
  provider      = google-beta
  metrics_scope = "viq-st-${var.country}-ops-${var.env}"
  name          = "viq-st-${var.country}-${var.env}"
  depends_on = [
    module.viq_services,
  ]
}
