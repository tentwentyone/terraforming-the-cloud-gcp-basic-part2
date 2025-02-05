
# 3.2 Habilitar o external-dns
data "google_service_account" "dns_admin" {
  project    = var.project_id
  account_id = var.dns_admin_serviceaccount
}

## Aqui usamos o provider `kubernetes` para criar o namespace
## Notem que usámos diferentes providers para criar recursos de kubernetes apenas por motivos académicos
resource "kubernetes_namespace" "external_dns" {
  metadata {
    name = "external-dns"
  }
}

## Vamos usar o helm provider para instanciar o chart do `external-dns`
resource "helm_release" "external_dns" {
  name             = "external-dns"
  repository       = "https://kubernetes-sigs.github.io/external-dns"
  chart            = "external-dns"
  version          = "1.15.0"
  namespace        = kubernetes_namespace.external_dns.metadata[0].name ## dependencia implicita
  wait_for_jobs    = true
  create_namespace = false

  values = [
    <<YAML
  serviceAccount:
    create: true
    annotations:
      iam.gke.io/gcp-service-account: ${data.google_service_account.dns_admin.email}
    name: external-dns

  sources:
    - ingress
    - service

  extraArgs:
    - --google-zone-visibility=public

  podLabels:
    app: external-dns

  resources:
    requests:
      memory: 50Mi
      cpu: 10m
    limits:
      memory: 200Mi

  domainFilters:
  - ${var.fqdn}

  txtOwnerId: ${var.project_id}/external-dns
  policy: sync
  registry: txt
  provider: google
  YAML
  ]
}
