data "google_dns_managed_zone" "master" {
  name    = var.master_zone_dns_name
  project = var.project_id
}

resource "google_service_account" "dns_admin" {
  account_id   = "dns-admin"
  display_name = "dns-admin"
  description  = "This ServiceAccount is responsible for managing DNS records."
}
