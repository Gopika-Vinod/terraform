resource "google_service_usage_consumer_quota_override" "query_usage_per_day_quota" {
  provider       = google-beta
  project        = local.project_id
  service        = "bigquery.googleapis.com"
  metric         = urlencode("bigquery.googleapis.com/quota/query/usage")
  limit          = urlencode("/d/project")
  override_value = "314572800"
  force          = true
}

resource "google_service_usage_consumer_quota_override" "query_usage_per_day_per_user_quota" {
  provider       = google-beta
  project        = local.project_id
  service        = "bigquery.googleapis.com"
  metric         = urlencode("bigquery.googleapis.com/quota/query/usage")
  limit          = urlencode("/d/project/user")
  override_value = "314572800"
  force          = true
}