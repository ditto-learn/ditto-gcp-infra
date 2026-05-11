variable "project_id" {
  type = string
}

variable "name" {
  type = string
}

variable "region" {
  type = string
}

variable "image" {
  type = string
}

variable "port" {
  type = number
}

variable "service_account_email" {
  type = string
}

variable "ingress" {
  type    = string
  default = "INGRESS_TRAFFIC_ALL"

  validation {
    condition = contains([
      "INGRESS_TRAFFIC_ALL",
      "INGRESS_TRAFFIC_INTERNAL_ONLY",
      "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER",
    ], var.ingress)
    error_message = "ingress must be a valid Cloud Run ingress enum value."
  }
}

variable "invoker_member" {
  type    = string
  default = null
}

variable "cloud_sql_instances" {
  type    = list(string)
  default = []
}

variable "custom_audiences" {
  type    = list(string)
  default = []
}

variable "plain_env" {
  type    = map(string)
  default = {}
}

variable "secret_env" {
  type    = map(string)
  default = {}
}

variable "min_instances" {
  type    = number
  default = 0
}

variable "max_instances" {
  type    = number
  default = 4
}

variable "timeout_seconds" {
  type    = number
  default = 60
}

variable "concurrency" {
  type    = number
  default = 80
}

variable "resource_limits" {
  type = map(string)
  default = {
    cpu    = "1"
    memory = "512Mi"
  }
}

variable "cpu_idle" {
  type        = bool
  default     = true
  description = "Whether Cloud Run allocates CPU only while processing requests. Set false for services that must finish in-process background work after a response."
}

variable "network_id" {
  type    = string
  default = null
}

variable "subnetwork_id" {
  type    = string
  default = null
}

variable "vpc_egress" {
  type        = string
  default     = "PRIVATE_RANGES_ONLY"
  description = "How Cloud Run routes outbound traffic when a VPC is attached. PRIVATE_RANGES_ONLY keeps public APIs on the internet gateway and routes only RFC1918 traffic through the VPC. Set to ALL_TRAFFIC only if you need every request to egress through the VPC."

  validation {
    condition     = contains(["ALL_TRAFFIC", "PRIVATE_RANGES_ONLY"], var.vpc_egress)
    error_message = "vpc_egress must be ALL_TRAFFIC or PRIVATE_RANGES_ONLY."
  }
}

variable "labels" {
  type    = map(string)
  default = {}
}

variable "deletion_protection" {
  type    = bool
  default = false
}

variable "secret_version" {
  type = string

  validation {
    condition     = can(regex("^[1-9][0-9]*$", var.secret_version))
    error_message = "secret_version must be a positive numeric secret version."
  }
}

variable "traffic_percent_latest" {
  type        = number
  default     = 100
  description = "Percentage of traffic to route to the latest revision. Set < 100 for canary deployments."

  validation {
    condition     = var.traffic_percent_latest >= 0 && var.traffic_percent_latest <= 100
    error_message = "traffic_percent_latest must be between 0 and 100."
  }
}
