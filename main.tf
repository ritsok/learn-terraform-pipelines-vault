terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.8.0"
    }
  }

  required_version = ">= 1.1.0"
}

data "tfe_outputs" "cluster" {
  organization = var.organization
  workspace    = var.cluster_workspace
}

data "tfe_outputs" "consul" {
  organization = var.organization
  workspace    = var.consul_workspace
}


# Retrieve GKE cluster information
provider "google" {
  project = data.tfe_outputs.cluster.values.project_id
  region  = data.tfe_outputs.cluster.values.region
}

data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${data.tfe_outputs.cluster.values.host}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = data.tfe_outputs.cluster.values.cluster_ca_certificate

}

provider "helm" {
  kubernetes {
    host                   = data.tfe_outputs.cluster.values.host
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = data.tfe_outputs.cluster.values.cluster_ca_certificate
  }
}
