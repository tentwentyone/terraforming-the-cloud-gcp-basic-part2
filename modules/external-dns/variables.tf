variable "project_id" {
  description = "The project id to work with"
  type        = string
}

variable "fqdn" {
  description = "The fully qualified domain name of the project."
  type = string
  default = ""
}

variable "dns_admin_serviceaccount" {
  description = "The serviceaccount that will be used to implement the workload-identity"
  type = string
}