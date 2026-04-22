# Cloud Tasks queue — thin wrapper around `google_cloud_tasks_queue`.
#
# Each queue corresponds to one kind of durable fire-and-forget work the
# backend enqueues. The backend posts back to an internal endpoint over
# HTTPS with an OIDC token (configured on the task itself, not on the
# queue) — see `app/core/cloud_tasks.py` for the enqueue path.
#
# Retry semantics are per-queue, tuned here. The Python dispatcher does
# NOT set per-task retry hints; Cloud Tasks uses these defaults.

resource "google_cloud_tasks_queue" "this" {
  project  = var.project_id
  location = var.region
  name     = var.name

  rate_limits {
    max_dispatches_per_second = var.max_dispatches_per_second
    max_concurrent_dispatches = var.max_concurrent_dispatches
  }

  retry_config {
    max_attempts  = var.max_attempts
    min_backoff   = var.min_backoff
    max_backoff   = var.max_backoff
    max_doublings = 16
  }
}
