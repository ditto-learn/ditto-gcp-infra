variable "project_id" {
  type = string
}

variable "environment" {
  type = string
}

variable "name" {
  type        = string
  description = "Metric name (user-visible prefix for the Cloud Logging metric). Use `snake_case`, e.g. `writing_evaluation_failures`."
}

variable "description" {
  type = string
}

variable "filter" {
  type        = string
  description = "Cloud Logging filter selecting entries to count. Reference structured fields by `jsonPayload.<key>`, e.g. `jsonPayload.event=\"writing_evaluation.failed\"`."
}

variable "display_name_prefix" {
  type        = string
  description = "Human-readable prefix for the alert policy; the environment is appended automatically."
}

variable "condition_display_name" {
  type = string
}

variable "alert_threshold" {
  type        = number
  description = "Number of events per `alert_window` that triggers the alert."
}

variable "alert_window" {
  type        = string
  default     = "600s"
  description = "Aggregation + duration window (10 minutes by default)."
}

variable "notification_channels" {
  type = list(string)
}
