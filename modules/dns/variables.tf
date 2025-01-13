variable "project_id" {
  description = "The project id to work with"
  type        = string
}

variable "prefix" {
  description = "the prefix to be used"
  type        = string
}

variable "dns_master_zone_name" {
  description = "The DNS master zone name for creating NS records."
  type        = string
}
