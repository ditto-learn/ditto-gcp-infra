variable "project_id" {
  type = string
}

variable "environment" {
  type = string
}

variable "region" {
  type    = string
  default = "europe-west2"

  validation {
    condition     = var.region == "europe-west2"
    error_message = "London-only policy enforced: region must be europe-west2."
  }
}

variable "artifact_repository_id" {
  type    = string
  default = "backend-images"
}

variable "content_bucket_name" {
  type = string
}

variable "network_id" {
  type = string
}

variable "subnetwork_id" {
  type = string
}

variable "container_images" {
  type = object({
    ai       = string
    learning = string
    question = string
  })
}

variable "nextjs_invoker_member" {
  type = string
}

variable "secret_values" {
  type      = map(string)
  sensitive = true
}

variable "cors_origins" {
  type = object({
    ai       = string
    learning = string
    question = string
  })
  default = { ai = "", learning = "", question = "" }
}

variable "cloud_run_custom_audiences" {
  type = object({
    ai       = list(string)
    learning = list(string)
    question = list(string)
  })
  default = { ai = [], learning = [], question = [] }
}
