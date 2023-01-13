variable "infra" {
  description = "infra microservices"
  type        = list(string)
  default     = [
    "erc20", "ens", "balance", "abi", "price", "api-gw", "statistics", "events"
  ]
}

resource "kubernetes_deployment" "defitrack-infra" {
  count = length(var.infra)
  metadata {
    name   = "defitrack-${var.infra[count.index]}"
    labels = {
      app : "defitrack-${var.infra[count.index]}"
    }
  }
  spec {
    replicas = "1"
    selector {
      match_labels = {
        app : "defitrack-${var.infra[count.index]}"
      }
    }
    strategy {
      type = "RollingUpdate"
    }
    template {
      metadata {
        labels = {
          app : "defitrack-${var.infra[count.index]}"
        }
      }
      spec {
        volume {
          name = "config-volume"
          config_map {
            name = "defitrack-${var.infra[count.index]}"
          }
        }
        container {
          image             = "${var.base-image}:${var.infra[count.index]}-production"
          name              = "defitrack-${var.infra[count.index]}"
          image_pull_policy = "Always"
          volume_mount {
            mount_path = "/application/config"
            name       = "config-volume"
          }
          env {
            name  = "SPRING_PROFILES_ACTIVE"
            value = "kubernetes"
          }
          env {
            name = "SPRING_CONFIG_LOCATION"
            value = "/application/config/application.properties"
          }
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