# Log-based metrics + alert policies for backend failure events.
#
# The backend emits structured log lines with `event=<name>` at each
# failure site. These metrics count those events; the paired alert
# policies fire when the count exceeds a tolerance threshold over a
# rolling window. Cloud Logging's "user-defined metric" free tier covers
# these at ~zero cost.
#
# When PR 3 adds Cloud Tasks, two more metrics land here:
#   * cloud_tasks_retry — filter on `jsonPayload.event="task.retry"`.
#   * cloud_tasks_dlq   — filter on `jsonPayload.event="task.dead_lettered"`.

module "writing_evaluation_failures" {
  source = "../modules/log_based_metric"

  project_id   = var.project_id
  environment  = var.environment
  name         = "ditto_${var.environment}_writing_evaluation_failures"
  description  = "Count of writing rubric evaluations that failed (Gemini error, malformed payload, learner mismatch)."
  filter       = <<-EOT
    resource.type="cloud_run_revision"
    resource.labels.service_name="ditto-backend-${var.environment}"
    jsonPayload.event="writing_evaluation.failed"
  EOT
  display_name_prefix    = "Writing Evaluation Failures"
  condition_display_name = "writing_evaluation.failed rate > 3 in 10min"
  alert_threshold        = 3
  notification_channels  = [google_monitoring_notification_channel.email.id]
}

module "stripe_webhook_failures" {
  source = "../modules/log_based_metric"

  project_id   = var.project_id
  environment  = var.environment
  name         = "ditto_${var.environment}_stripe_webhook_failures"
  description  = "Count of Stripe webhook events that errored out during processing. Stripe retries automatically; a sustained failure rate points to a DB outage, Stripe API incident, or a handler bug."
  filter       = <<-EOT
    resource.type="cloud_run_revision"
    resource.labels.service_name="ditto-backend-${var.environment}"
    jsonPayload.event="stripe.webhook.failed"
  EOT
  display_name_prefix    = "Stripe Webhook Processing Failures"
  condition_display_name = "stripe.webhook.failed rate > 3 in 10min"
  alert_threshold        = 3
  notification_channels  = [google_monitoring_notification_channel.email.id]
}
