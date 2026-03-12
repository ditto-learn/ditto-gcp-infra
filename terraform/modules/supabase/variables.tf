variable "organization_id" {
  type = string
}

variable "project_name" {
  type = string
}

variable "database_password" {
  type      = string
  sensitive = true
}

variable "region" {
  type    = string
  default = "eu-west-2"
}

variable "instance_size" {
  type    = string
  default = "micro"
}

variable "site_url" {
  type = string
}

variable "additional_redirect_urls" {
  type    = list(string)
  default = []
}

variable "max_rows" {
  type    = number
  default = 1000
}

variable "nat_allowlist_cidr" {
  type = string
}

variable "additional_allowed_cidrs" {
  type    = list(string)
  default = []
}
