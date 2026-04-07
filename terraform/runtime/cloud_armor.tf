resource "google_compute_security_policy" "api" {
  project = var.project_id
  name    = "ditto-api-armor-${var.environment}"

  # Cloud Armor evaluates rules by ascending priority and requires a default
  # action at the maximum int32 priority. Without this allow rule, traffic
  # matching no other rule would be denied.
  rule {
    action   = "allow"
    priority = 2147483647

    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }

    description = "Default allow rule"
  }

  rule {
    action   = "throttle"
    priority = 1000

    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }

    rate_limit_options {
      conform_action = "allow"
      exceed_action  = "deny(429)"

      rate_limit_threshold {
        count        = 300
        interval_sec = 60
      }

      enforce_on_key = "IP"
    }

    description = "Rate limit per IP: 300 req/min"
  }

  adaptive_protection_config {
    layer_7_ddos_defense_config {
      enable = true
    }
  }
}
