# Log-based metric + alert policy, paired.
#
# Each instance pairs:
#   * a `google_logging_metric` that counts log entries matching `filter`,
#   * a `google_monitoring_alert_policy` that fires when the count over
#     `alert_window` exceeds `alert_threshold`.
#
# The backend emits structured `event=<name>` log lines at the failure
# sites this module watches. See `ditto-backend/app/core/logging.py` for
# the JSON shape — every field in the log entry surfaces as a filterable
# key in Cloud Logging, so filters here can be tight.

resource "google_logging_metric" "this" {
  project     = var.project_id
  name        = var.name
  description = var.description
  filter      = var.filter

  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
  }
}

resource "google_monitoring_alert_policy" "this" {
  project      = var.project_id
  display_name = "${var.display_name_prefix} (${var.environment})"
  combiner     = "OR"

  conditions {
    display_name = var.condition_display_name

    condition_threshold {
      filter          = "resource.type = \"cloud_run_revision\" AND metric.type = \"logging.googleapis.com/user/${google_logging_metric.this.name}\""
      comparison      = "COMPARISON_GT"
      threshold_value = var.alert_threshold
      duration        = var.alert_window

      aggregations {
        alignment_period   = var.alert_window
        per_series_aligner = "ALIGN_RATE"
      }
    }
  }

  notification_channels = var.notification_channels

  alert_strategy {
    auto_close = "604800s"
  }
}
