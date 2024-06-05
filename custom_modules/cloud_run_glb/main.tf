resource "google_compute_region_network_endpoint_group" "cloudrun_neg" {
   for_each = toset([for k,v in var.url_map: v.name])
  name                  = "neg-${var.project_id}-cloudrun-${each.value}"
  description           = "Network Endpoint Group for Cloud Run Service: ${each.value}"
  network_endpoint_type = "SERVERLESS"
  region                = var.neg_region
  project               = var.project_id
  cloud_run {
    service = each.value
  }
}


resource "google_compute_managed_ssl_certificate" "google_managed_ssl_cert" {
  provider = google-beta
  project  = var.project_id
  name     = "${replace(var.lb_domain_name, ".", "-")}-ssl-cert"
  managed {
    domains = [
      var.lb_domain_name
    ]
  }
}

resource "google_compute_global_address" "lb_global_ip_address" {
  provider   = google-beta
  project    = var.project_id
  name       = "${var.lb_name}-${var.project_id}-vpc-static-ip"
  ip_version = "IPV4"
}


resource "google_compute_backend_service" "backend_cloudrun_neg" {
  provider = google-beta
  for_each = toset([for k,v in var.url_map: v.name])
  # for_each = {
  #   for k,m in var.url_map: "${m.name}${m.path}" => m
  # }
  project                         = var.project_id
  # name                            = "backend-${each.value.name}"
  name                            = "backend-${each.value}"
  load_balancing_scheme           = "EXTERNAL_MANAGED"  ###Global external HTTP(S) load balancer
  protocol                        = "HTTPS"
  description                     = null
  connection_draining_timeout_sec = null
  # enable_cdn                      = each.value.enable_cdn
  enable_cdn = contains(var.enable_cdn_services, each.value)? true: false
  
  custom_request_headers          = []
  custom_response_headers         = []
  security_policy                 = var.security_policy
  cdn_policy {
    cache_mode = "CACHE_ALL_STATIC"
    cache_key_policy {
      include_host     = true
      include_protocol = true
    }
  }

  backend  {
    group = "projects/${var.project_id}/regions/${var.neg_region}/networkEndpointGroups/neg-${var.project_id}-cloudrun-${each.value}"
  }
  log_config {
    enable      = true
    sample_rate = "1.0"
  }
  depends_on = [
    google_compute_region_network_endpoint_group.cloudrun_neg
  ]
}

resource "google_compute_ssl_policy" "ssl_policy" {
  name            = "${var.lb_name}-ssl-policy"
  profile         = "MODERN"
  description     = "SSL Policy For VIQ"
  project = var.project_id
  min_tls_version = "TLS_1_2"
}

resource "google_compute_target_https_proxy" "target_proxy" {
  project = var.project_id
  name    = "${var.lb_name}-https-proxy"
  url_map = google_compute_url_map.url_map.self_link
  ssl_policy = google_compute_ssl_policy.ssl_policy.id
  ssl_certificates = [
    google_compute_managed_ssl_certificate.google_managed_ssl_cert.self_link
  ]
  quic_override    = null
}

resource "google_compute_target_http_proxy" "target_proxy_test" {
  project = var.project_id
  name    = "${var.lb_name}-https-proxy-test"
  url_map = google_compute_url_map.url_map.self_link
}

resource "google_compute_global_forwarding_rule" "forwarding_rule" {
  provider              = google-beta
  project               = var.project_id
  name                  = "${var.lb_name}-fw-rule-https"
  target                = google_compute_target_https_proxy.target_proxy.self_link
  # ip_address            = module.cloud_nat_external_static_ip_reserve.addresses[1]
  ip_address = google_compute_global_address.lb_global_ip_address.id
  port_range            = "443"
  load_balancing_scheme = "EXTERNAL_MANAGED"
}


resource "google_compute_url_map" "url_map" {
  name            = "${var.lb_name}"
  description     = "Url Map for ${var.lb_name}"
  project = var.project_id
  default_service = google_compute_backend_service.backend_cloudrun_neg[var.default_service].self_link
  host_rule {
    hosts        = [var.lb_domain_name]
    path_matcher = "allpaths"
  }

  path_matcher {
    name            = "allpaths"
    default_service = google_compute_backend_service.backend_cloudrun_neg[var.default_service].self_link
    dynamic "path_rule" {
      for_each = {
        for k,m in var.url_map: "${k}-${m.name}" => m
      }
      content{
        paths   = [path_rule.value.path]
        service = "projects/${var.project_id}/global/backendServices/backend-${path_rule.value.name}"
      }
    }
  }
}