variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "name" {
  type        = string
  description = "Queue name (flat — the full queue id is projects/<proj>/locations/<region>/queues/<name>)."
}

variable "max_dispatches_per_second" {
  type        = number
  default     = 10
  description = "Cloud Tasks' token-bucket refill rate. Cap outbound request rate from the queue to the backend."
}

variable "max_concurrent_dispatches" {
  type        = number
  default     = 50
  description = "Cloud Tasks' maximum concurrent outbound requests from this queue. Don't exceed what the backend can handle."
}

variable "max_attempts" {
  type        = number
  default     = 5
  description = "Maximum delivery attempts before a task is dead-lettered (i.e. dropped)."
}

variable "min_backoff" {
  type        = string
  default     = "5s"
  description = "Minimum retry delay. Duration string, e.g. \"5s\"."
}

variable "max_backoff" {
  type        = string
  default     = "300s"
  description = "Maximum retry delay. Duration string, e.g. \"300s\"."
}
