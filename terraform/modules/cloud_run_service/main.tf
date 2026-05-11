# NOTE: At production scale, consider adding a Cloud SQL Auth Proxy sidecar or
# PgBouncer for connection pooling. Each Cloud Run instance opens up to pool_max
# DB connections; without a pooler, scaling beyond ~5 instances can exhaust
# Cloud SQL's default connection limit (~100 on db-custom-1-3840).
resource "google_cloud_run_v2_service" "this" {
  name                 = var.name
  location             = var.region
  project              = var.project_id
  ingress              = var.ingress
  custom_audiences     = var.custom_audiences
  deletion_protection  = var.deletion_protection
  invoker_iam_disabled = var.invoker_member == "allUsers"
  labels               = var.labels

  template {
    service_account                  = var.service_account_email
    timeout                          = "${var.timeout_seconds}s"
    max_instance_request_concurrency = var.concurrency

    scaling {
      min_instance_count = var.min_instances
      max_instance_count = var.max_instances
    }

    dynamic "vpc_access" {
      for_each = var.network_id == null ? [] : [1]
      content {
        network_interfaces {
          network    = var.network_id
          subnetwork = var.subnetwork_id
        }
        # PRIVATE_RANGES_ONLY keeps public egress (Vertex, Firebase, Stripe,
        # Gemini, Upstash) on the normal internet gateway and routes only
        # RFC1918 traffic through the VPC. Caller sets `network_id` +
        # `subnetwork_id` only when a private-IP service is actually on the
        # VPC; otherwise the VPC block is omitted entirely.
        egress = var.vpc_egress
      }
    }

    dynamic "volumes" {
      for_each = length(var.cloud_sql_instances) > 0 ? [1] : []
      content {
        name = "cloudsql"
        cloud_sql_instance {
          instances = var.cloud_sql_instances
        }
      }
    }

    containers {
      image = var.image

      dynamic "volume_mounts" {
        for_each = length(var.cloud_sql_instances) > 0 ? [1] : []
        content {
          name       = "cloudsql"
          mount_path = "/cloudsql"
        }
      }

      ports {
        container_port = var.port
      }

      resources {
        limits   = var.resource_limits
        cpu_idle = var.cpu_idle
      }

      dynamic "env" {
        for_each = var.plain_env
        content {
          name  = env.key
          value = env.value
        }
      }

      dynamic "env" {
        for_each = var.secret_env
        content {
          name = env.key
          value_source {
            secret_key_ref {
              secret  = env.value
              version = var.secret_version
            }
          }
        }
      }
    }
  }

  traffic {
    percent = var.traffic_percent_latest
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
  }
}

resource "google_cloud_run_v2_service_iam_member" "invoker" {
  count    = var.invoker_member == null || var.invoker_member == "allUsers" ? 0 : 1
  project  = var.project_id
  location = var.region
  name     = google_cloud_run_v2_service.this.name
  role     = "roles/run.invoker"
  member   = var.invoker_member
}
