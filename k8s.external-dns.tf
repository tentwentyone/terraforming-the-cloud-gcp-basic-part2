## 3.2 Habilitar o external-dns
# module "external_dns" {
#   source                   = "./modules/external-dns"
#   project_id               = var.project_id
#   fqdn                     = module.dns.fqdn
#   dns_admin_serviceaccount = var.dns_admin_serviceaccount

#   depends_on = [
#     module.gke,
#     module.dns
#   ]
# }
