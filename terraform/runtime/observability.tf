# Log-based metrics + alert policies for backend failure events.
#
# The backend emits structured log lines with `event=<name>` at each
# failure site. These metrics count those events; the paired alert
# policies fire when the count exceeds a tolerance threshold over a
# rolling window. Cloud Logging's "user-defined metric" free tier covers
# these at ~zero cost.
#
module "writing_evaluation_failures" {
  source = "../modules/log_based_metric"

  project_id             = var.project_id
  environment            = var.environment
  name                   = "ditto_${var.environment}_writing_evaluation_failures"
  description            = "Count of writing rubric evaluations that failed (Gemini error, malformed payload, learner mismatch)."
  filter                 = <<-EOT
    resource.type="cloud_run_revision"
    resource.labels.service_name="ditto-backend-${var.environment}"
    jsonPayload.event="writing_evaluation.failed"
  EOT
  display_name_prefix    = "Writing Evaluation Failures"
  condition_display_name = "writing_evaluation.failed rate > 3 in 10min"
  alert_threshold        = 3
  notification_channels  = [google_monitoring_notification_channel.email.id]
}

module "writing_evaluation_sweeper_reenqueues" {
  source = "../modules/log_based_metric"

  project_id             = var.project_id
  environment            = var.environment
  name                   = "ditto_${var.environment}_writing_evaluation_sweeper_reenqueues"
  description            = "Count of writing evaluations re-enqueued by the stale-task sweeper. Any sustained count means enqueue or task delivery is unhealthy."
  filter                 = <<-EOT
    resource.type="cloud_run_revision"
    resource.labels.service_name="ditto-backend-${var.environment}"
    jsonPayload.event="writing_evaluation.sweep_reenqueued"
  EOT
  display_name_prefix    = "Writing Evaluation Sweeper Re-enqueues"
  condition_display_name = "writing_evaluation.sweep_reenqueued rate > 2 in 10min"
  alert_threshold        = 2
  notification_channels  = [google_monitoring_notification_channel.email.id]
}

module "email_send_failures" {
  source = "../modules/log_based_metric"

  project_id             = var.project_id
  environment            = var.environment
  name                   = "ditto_${var.environment}_email_send_failures"
  description            = "Count of permanent or retryable transactional-email send failures surfaced by the Cloud Tasks handler."
  filter                 = <<-EOT
    resource.type="cloud_run_revision"
    resource.labels.service_name="ditto-backend-${var.environment}"
    (
      jsonPayload.event="email.send.retryable_failed"
      OR jsonPayload.event="email.send.permanent_failed"
    )
  EOT
  display_name_prefix    = "Transactional Email Send Failures"
  condition_display_name = "email.send failures > 3 in 10min"
  alert_threshold        = 3
  notification_channels  = [google_monitoring_notification_channel.email.id]
}

module "stripe_webhook_failures" {
  source = "../modules/log_based_metric"

  project_id             = var.project_id
  environment            = var.environment
  name                   = "ditto_${var.environment}_stripe_webhook_failures"
  description            = "Count of Stripe webhook events that errored out during processing. Stripe retries automatically; a sustained failure rate points to a DB outage, Stripe API incident, or a handler bug."
  filter                 = <<-EOT
    resource.type="cloud_run_revision"
    resource.labels.service_name="ditto-backend-${var.environment}"
    jsonPayload.event="stripe.webhook.failed"
  EOT
  display_name_prefix    = "Stripe Webhook Processing Failures"
  condition_display_name = "stripe.webhook.failed rate > 3 in 10min"
  alert_threshold        = 3
  notification_channels  = [google_monitoring_notification_channel.email.id]
}
