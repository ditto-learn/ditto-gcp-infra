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

variable "network_id" {
  type    = string
  default = null
}

variable "subnetwork_id" {
  type    = string
  default = null
}
