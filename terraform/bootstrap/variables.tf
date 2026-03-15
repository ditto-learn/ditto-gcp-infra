variable "project_id" {
  type        = string
  description = "GCP project ID that owns the state buckets."
}

variable "region" {
  type        = string
  default     = "europe-west2"
  description = "GCS bucket location."
}
