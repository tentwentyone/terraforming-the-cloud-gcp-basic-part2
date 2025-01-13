## 3.1. Descomentar para ativar o modulo de DNS
# module "dns" {
#   source               = "./modules/dns"
#   project_id           = var.project_id
#   prefix               = local.prefix
#   dns_master_zone_name = var.dns_master_zone_name
# }

# output "fqdn" {
#   value = trim(module.dns.fqdn, ".")
# }
