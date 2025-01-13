## DNS management
locals {
  fqdn     = trim(local.dns_name, ".")
  dns_name = "${var.prefix}.${data.google_dns_managed_zone.workshop_zone.dns_name}"
}


data "google_project" "this" {
  project_id = var.project_id
}

## Esta é a zona da workshop: wshop.company.com
## É nesta zona que iremos criar sub-zonas, uma para cada aluno
data "google_dns_managed_zone" "workshop_zone" {
  name    = var.dns_master_zone_name
  project = data.google_project.this.name
}

# Esta é a zona que irás usar, o nome varia consoante o teu prefixo
# mas será algo tipo my-prefix.wshop.company.com
resource "google_dns_managed_zone" "this" {
  name     = "${var.prefix}-dns"
  dns_name = local.dns_name
  project  = data.google_project.this.name

  # Set this true to delete all records in the zone.
  force_destroy = true
}

# parent zone - NS records for the child zone
# gcloud dns record-sets list -z cloud-demo-zone --project poc-anthos-on-prem
resource "google_dns_record_set" "parent_ns" {
  managed_zone = data.google_dns_managed_zone.workshop_zone.name
  project      = data.google_dns_managed_zone.workshop_zone.project

  name    = local.dns_name
  type    = "NS"
  ttl     = 300
  rrdatas = google_dns_managed_zone.this.name_servers
}
