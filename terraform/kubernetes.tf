terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes",
    }
    grafana = {
      source = "grafana/grafana"
    }
  }
}

provider "grafana" {
  url  = "https://grafana.decentri.fi/"
  auth = var.grafana-auth
}

variable "grafana-auth" {
  type =  string
}

variable "host" {
  type = string
}

variable "username" {
  type = string
}

variable "token" {
  type = string
}

variable "cluster_ca_certificate" {
  type = string
}

provider "kubernetes" {
  host = var.host

  token = var.token
  cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
}

variable "base-image" {
  type = string
}