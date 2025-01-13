## terraform & providers
terraform {
  required_version = ">= 1.5.7"
  backend "local" {
    path = "terraform.tfstate"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.15"
    }

    kubectl = {
      source  = "alekc/kubectl"
      version = "2.1.3"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.17"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.35"
    }
  }
}

## referenciar um recurso já existente!
## ref: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project
data "google_project" "this" {
  project_id = var.project_id
}

## local resources
locals {
  prefix = var.user_prefix
}

data "google_client_config" "this" {}
provider "kubectl" {
  host                   = module.gke.gke_default_endpoint
  cluster_ca_certificate = base64decode(module.gke.gke_ca_certificate)
  token                  = data.google_client_config.this.access_token
  load_config_file       = false
}

provider "helm" {
  kubernetes {
    host                   = module.gke.gke_default_endpoint
    token                  = data.google_client_config.this.access_token
    cluster_ca_certificate = base64decode(module.gke.gke_ca_certificate)
  }
}

provider "kubernetes" {
  host                   = "https://${module.gke.gke_default_endpoint}"
  token                  = data.google_client_config.this.access_token
  cluster_ca_certificate = base64decode(module.gke.gke_ca_certificate)
}
