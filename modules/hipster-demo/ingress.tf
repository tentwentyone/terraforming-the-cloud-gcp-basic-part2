# 3.3 - Deploy de ingress
data "kubectl_path_documents" "hipster_ingress" {
  pattern = "${path.module}/k8s/300-hipster-ingress.yaml"
  vars = {
    fqdn = var.fqdn
  }
}

resource "kubectl_manifest" "hipster_ingress" {
  count     = var.ingress_enabled ? length(flatten(toset([for f in fileset(".", data.kubectl_path_documents.hipster_ingress.pattern) : split("\n---\n", file(f))]))) : 0
  yaml_body = element(data.kubectl_path_documents.hipster_ingress.documents, count.index)
  wait      = true

  depends_on = [
    kubectl_manifest.hipster_workloads,
    time_sleep.wait_destroy
  ]
}

## O seguinte é um workaround para garantir que determinados recursos geridos internamente pelo GKE são devidamente apagados antes de eliminarmos o cluster
## caso contrário eles ficam presos impedindo a destruição da VPC
resource "time_sleep" "wait_destroy" {
  count      = var.ingress_enabled ? 1 : 0
  depends_on = [kubectl_manifest.hipster_namespace]

  destroy_duration = "3m"
}