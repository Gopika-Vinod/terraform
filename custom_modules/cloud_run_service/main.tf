resource "google_cloud_run_service" "main_with_lifecycle" {
  count = var.project_id != "viq-st-na-s" && var.project_id != "viq-st-eu-s" ? 1 : 0
  provider                   = google-beta
  project                    = var.project_id
  name                       = var.service_name
  location                   = var.location
  autogenerate_revision_name = true

  dynamic "traffic" {
    for_each = var.traffic_split
    content {
      percent         = lookup(traffic.value, "percent", 100)
      latest_revision = lookup(traffic.value, "latest_revision", null)
      revision_name   = lookup(traffic.value, "latest_revision") ? null : lookup(traffic.value, "revision_name")
      tag             = lookup(traffic.value, "tag", null)
    }
  }

  metadata {
    labels      = var.service_labels
    annotations = var.service_annotations
  }

  template {
    metadata {
      annotations = var.template_annotations
      labels      = var.template_labels
    }
    spec {
      containers {
        args    = var.argument
        image   = var.image
        command = var.container_command

        dynamic "env" {
          for_each = var.env_vars
          content {
            name  = env.value["name"]
            value = env.value["value"]
          }
        }

        ports {
          name           = var.ports["name"]
          container_port = var.ports["port"]
        }

        resources {
          limits   = var.limits
          requests = var.requests
        }

        dynamic "volume_mounts" {
          for_each = var.volume_mounts
          content {
            name       = volume_mounts.value["name"]
            mount_path = volume_mounts.value["mount_path"]
          }
        }

        dynamic "startup_probe" {
          for_each = var.startup_probe != null ? [var.startup_probe] : []
          content {
            initial_delay_seconds = startup_probe.value["initial_delay_seconds"]
            timeout_seconds       = startup_probe.value["timeout_seconds"]
            period_seconds        = startup_probe.value["period_seconds"]
            failure_threshold     = startup_probe.value["failure_threshold"]

            dynamic "http_get" {
              for_each = startup_probe.value["http_get"] != null ? [startup_probe.value["http_get"]] : []
              content {
                path = http_get.value["path"]
                dynamic "http_headers" {
                  for_each = http_get.value["http_headers"] != null ? [http_get.value["http_headers"]] : []
                  content {
                    name  = http_headers.value["name"]
                    value = http_headers.value["value"]
                  }
                }
              }
            }

            dynamic "tcp_socket" {
              for_each = startup_probe.value["tcp_socket"] != null ? [startup_probe.value["tcp_socket"]] : []
              content {
                port = tcp_socket.value["port"]
              }
            }

            dynamic "grpc" {
              for_each = startup_probe.value["grpc"] != null ? [startup_probe.value["grpc"]] : []
              content {
                port    = grpc.value["port"]
                service = grpc.value["service"]
              }
            }
          }
        }

        dynamic "liveness_probe" {
          for_each = var.liveness_probe != null ? [var.liveness_probe] : []
          content {
            initial_delay_seconds = liveness_probe.value["initial_delay_seconds"]
            timeout_seconds       = liveness_probe.value["timeout_seconds"]
            period_seconds        = liveness_probe.value["period_seconds"]
            failure_threshold     = liveness_probe.value["failure_threshold"]

            dynamic "http_get" {
              for_each = liveness_probe.value["http_get"] != null ? [liveness_probe.value["http_get"]] : []
              content {
                path = http_get.value["path"]
                dynamic "http_headers" {
                  for_each = http_get.value["http_headers"] != null ? [http_get.value["http_headers"]] : []
                  content {
                    name  = http_headers.value["name"]
                    value = http_headers.value["value"]
                  }
                }
              }
            }

            dynamic "grpc" {
              for_each = liveness_probe.value["grpc"] != null ? [liveness_probe.value["grpc"]] : []
              content {
                port    = grpc.value["port"]
                service = grpc.value["service"]
              }
            }
          }
        }

        dynamic "env" {
          for_each = var.env_secret_vars
          content {
            name = env.value["name"]
            dynamic "value_from" {
              for_each = env.value.value_from
              content {
                secret_key_ref {
                  name = value_from.value.secret_key_ref["name"]
                  key  = value_from.value.secret_key_ref["key"]
                }
              }
            }
          }
        }
      }

      container_concurrency = var.container_concurrency
      timeout_seconds       = var.timeout_seconds
      service_account_name  = var.service_account_email

      dynamic "volumes" {
        for_each = var.volumes
        content {
          name = volumes.value["name"]
          
          secret {
            default_mode = 0
            secret_name = volumes.value["secret"]["secret_name"]
            items {
              mode = 0 
              key  = volumes.value["secret"]["items"]["key"]
              path = volumes.value["secret"]["items"]["path"]
            }
          }
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [
      metadata.0.annotations,
      template[0].spec[0].containers[0].image,
    ]
  }
}

resource "google_cloud_run_service" "main_without_lifecycle" {
  count                      = var.project_id == "viq-st-na-s" || var.project_id == "viq-st-eu-s" ? 1 : 0
  provider                   = google-beta
  project                    = var.project_id
  name                       = var.service_name
  location                   = var.location
  autogenerate_revision_name = true

  dynamic "traffic" {
    for_each = var.traffic_split
    content {
      percent         = lookup(traffic.value, "percent", 100)
      latest_revision = lookup(traffic.value, "latest_revision", null)
      revision_name   = lookup(traffic.value, "latest_revision") ? null : lookup(traffic.value, "revision_name")
      tag             = lookup(traffic.value, "tag", null)
    }
  }

  metadata {
    labels      = var.service_labels
    annotations = var.service_annotations
  }

  template {
    metadata {
      annotations = var.template_annotations
      labels      = var.template_labels
    }
    spec {
      containers {
        args    = var.argument
        image   = var.image
        command = var.container_command

        dynamic "env" {
          for_each = var.env_vars
          content {
            name  = env.value["name"]
            value = env.value["value"]
          }
        }

        ports {
          name           = var.ports["name"]
          container_port = var.ports["port"]
        }

        resources {
          limits   = var.limits
          requests = var.requests
        }

        dynamic "volume_mounts" {
          for_each = var.volume_mounts
          content {
            name       = volume_mounts.value["name"]
            mount_path = volume_mounts.value["mount_path"]
          }
        }

        dynamic "startup_probe" {
          for_each = var.startup_probe != null ? [var.startup_probe] : []
          content {
            initial_delay_seconds = startup_probe.value["initial_delay_seconds"]
            timeout_seconds       = startup_probe.value["timeout_seconds"]
            period_seconds        = startup_probe.value["period_seconds"]
            failure_threshold     = startup_probe.value["failure_threshold"]

            dynamic "http_get" {
              for_each = startup_probe.value["http_get"] != null ? [startup_probe.value["http_get"]] : []
              content {
                path = http_get.value["path"]
                dynamic "http_headers" {
                  for_each = http_get.value["http_headers"] != null ? [http_get.value["http_headers"]] : []
                  content {
                    name  = http_headers.value["name"]
                    value = http_headers.value["value"]
                  }
                }
              }
            }

            dynamic "tcp_socket" {
              for_each = startup_probe.value["tcp_socket"] != null ? [startup_probe.value["tcp_socket"]] : []
              content {
                port = tcp_socket.value["port"]
              }
            }

            dynamic "grpc" {
              for_each = startup_probe.value["grpc"] != null ? [startup_probe.value["grpc"]] : []
              content {
                port    = grpc.value["port"]
                service = grpc.value["service"]
              }
            }
          }
        }

        dynamic "liveness_probe" {
          for_each = var.liveness_probe != null ? [var.liveness_probe] : []
          content {
            initial_delay_seconds = liveness_probe.value["initial_delay_seconds"]
            timeout_seconds       = liveness_probe.value["timeout_seconds"]
            period_seconds        = liveness_probe.value["period_seconds"]
            failure_threshold     = liveness_probe.value["failure_threshold"]

            dynamic "http_get" {
              for_each = liveness_probe.value["http_get"] != null ? [liveness_probe.value["http_get"]] : []
              content {
                path = http_get.value["path"]
                dynamic "http_headers" {
                  for_each = http_get.value["http_headers"] != null ? [http_get.value["http_headers"]] : []
                  content {
                    name  = http_headers.value["name"]
                    value = http_headers.value["value"]
                  }
                }
              }
            }

            dynamic "grpc" {
              for_each = liveness_probe.value["grpc"] != null ? [liveness_probe.value["grpc"]] : []
              content {
                port    = grpc.value["port"]
                service = grpc.value["service"]
              }
            }
          }
        }

        dynamic "env" {
          for_each = var.env_secret_vars
          content {
            name = env.value["name"]
            dynamic "value_from" {
              for_each = env.value.value_from
              content {
                secret_key_ref {
                  name = value_from.value.secret_key_ref["name"]
                  key  = value_from.value.secret_key_ref["key"]
                }
              }
            }
          }
        }
      }

      container_concurrency = var.container_concurrency
      timeout_seconds       = var.timeout_seconds
      service_account_name  = var.service_account_email

      dynamic "volumes" {
        for_each = var.volumes
        content {
          name = volumes.value["name"]
          
          secret {
            default_mode = 0
            secret_name = volumes.value["secret"]["secret_name"]
            items {
              mode = 0 
              key  = volumes.value["secret"]["items"]["key"]
              path = volumes.value["secret"]["items"]["path"]
            }
          }
        }
      }
    }
  }
}
resource "google_cloud_run_service_iam_binding" "default" {
  count    = var.project_id != "viq-st-na-s" && var.project_id != "viq-st-eu-s" ? 1 : 0
  project  = var.project_id
  location = google_cloud_run_service.main_with_lifecycle[0].location
  service  = google_cloud_run_service.main_with_lifecycle[0].name
  role     = "roles/run.invoker"
  members  = local.members
}



resource "google_cloud_run_service_iam_binding" "default_without_lifecycle" {
  count    = var.project_id == "viq-st-na-s" || var.project_id == "viq-st-eu-s" ? 1 : 0
  provider = google-beta

  project  = var.project_id
  location = google_cloud_run_service.main_without_lifecycle[0].location
  service  = google_cloud_run_service.main_without_lifecycle[0].name

  role     = "roles/run.invoker"
  members  = local.members
}




locals {
  members = var.allow_unauthenticated ? concat(var.members, ["allUsers"]) : var.members
}