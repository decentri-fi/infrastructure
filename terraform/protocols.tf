variable "protocols" {
  description = "Protocols that have their own service"
  type        = list(string)
  default     = [
    "olympusdao", "aave", "adamant", "apeswap", "aelin", "beefy", "compound", "balancer", "bancor", "beethovenx",
    "dfyn", "dmm", "hop", "idex", "iron-bank", "kyberswap", "maplefinance", "mstable", "quickswap", "spirit", "spooky",
    "stargate", "sushiswap", "uniswap", "polycat", "convex", "curve", "dinoswap", "ribbon", "set", "wepiggy",
    "makerdao", "polygon-protocol", "looksrare", "dodo", "humandao"

  ]
}

variable "base-image" {
  default = "Base Image to pull from"
  type    = string
}

resource "kubernetes_deployment" "defitrack-protocols" {
  count = length(var.protocols)
  metadata {
    name   = "defitrack-${var.protocols[count.index]}"
    labels = {
      app : "defitrack-${var.protocols[count.index]}"
    }
  }
  spec {
    replicas = "1"
    selector {
      match_labels = {
        app : "defitrack-${var.protocols[count.index]}"
      }
    }
    strategy {
      type = "RollingUpdate"
    }
    template {
      metadata {
        labels = {
          app : "defitrack-${var.protocols[count.index]}"
        }
      }
      spec {
        container {
          image             = "${var.base-image}:${var.protocols[count.index]}-production"
          name              = "defitrack-${var.protocols[count.index]}"
          image_pull_policy = "Always"
          port {
            container_port = 8080
          }
          readiness_probe {
            http_get {
              path = "/actuator/health"
              port = 8080
            }
            initial_delay_seconds = 20
            period_seconds        = 10
            timeout_seconds       = 2
            failure_threshold     = 1
            success_threshold     = 1
          }
          liveness_probe {
            http_get {
              path = "/actuator/health"
              port = 8080
            }
            initial_delay_seconds = 25
            period_seconds        = 20
            timeout_seconds       = 2
            failure_threshold     = 1
          }
        }
        image_pull_secrets {
          name = "personal-docker-registry"
        }
        toleration {
          key      = "node-role.kubernetes.io/master"
          effect   = "NoSchedule"
          operator = "Exists"
        }
      }
    }
  }
}