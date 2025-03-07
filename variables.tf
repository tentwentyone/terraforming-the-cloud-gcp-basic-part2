## project related
variable "project_id" {
  description = "The project id to work with"
  type        = string
}

variable "region" {
  description = "region for region-aware resources"
  type        = string
  default     = "europe-west1"
}

variable "gke_location" {
  description = "location for the gke cluster. Will default to region if not specified."
  type        = string
  default     = "europe-west1"
}

variable "dns_admin_serviceaccount" {
  description = "represents the service account that will be used to manage dns records"
  type        = string
  default     = "sa-gke-dns"
}

variable "dns_master_zone_name" {
  description = "The DNS master zone name for creating NS records."
  type        = string
  default     = "dns-lab-01-public"
}

variable "user_prefix" {
  type        = string
  description = "Este campo é obrigatório para definir a vossa unicidade."
  ## Aqui podem verificar a utilização de uma regra de validação para o campo
  validation {
    condition     = can(regex("^[a-z]+$", var.user_prefix))
    error_message = "Valor inválido. Tem que ser lower-case, sem números nem caracteres especiais."
  }
}
