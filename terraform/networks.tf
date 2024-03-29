variable "networks" {
  description = "networks that have their own service"
  type        = list(string)
  default     = [
    "arbitrum", "ethereum", "optimism", "polygon", "polygon-zkevm", "base"
  ]
}

resource "kubernetes_deployment" "defitrack-networks" {
  count = length(var.networks)
  metadata {
    name   = "defitrack-${var.networks[count.index]}"
    labels = {
      app : "defitrack-${var.networks[count.index]}"
    }
    annotations = {
      "prometheus.io/scrape" : "true"
      "prometheus.io/port" : "8080"
      "prometheus.io/path" : "/actuator/prometheus"
    }
  }
  spec {
    replicas = "1"
    selector {
      match_labels = {
        app : "defitrack-${var.networks[count.index]}"
      }
    }
    strategy {
      type = "RollingUpdate"
    }
    template {
      metadata {
        labels = {
          app : "defitrack-${var.networks[count.index]}"
        }
        annotations = {
          "prometheus.io/scrape" : "true"
          "prometheus.io/port" : "8080"
          "prometheus.io/path" : "/actuator/prometheus"
        }
      }
      spec {
        volume {
          name = "config-volume"
          config_map {
            name = "defitrack-${var.networks[count.index]}"
          }
        }
        termination_grace_period_seconds = 30
        container {
          lifecycle {
            pre_stop {
              exec {
                command = ["/bin/sh", "-c", "sleep 10"]
              }
            }
          }
          image             = "${var.base-image}:evm-production"
          name              = "defitrack-${var.networks[count.index]}"
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
            name  = "SPRING_CONFIG_LOCATION"
            value = "/application/config/application.properties"
          }
          port {
            container_port = 8080
          }
          readiness_probe {
            http_get {
              path = "/actuator/health/readiness"
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
              path = "/actuator/health/liveness"
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

resource "kubernetes_service" "defitrack-network-services" {
  for_each = toset(var.networks)

  metadata {
    name   = "defitrack-${each.value}"
    labels = {
      team = "decentrifi"
    }
  }


  spec {
    selector = {
      app = "defitrack-${each.value}"
    }

    port {
      name        = "http-traffic"
      port        = 8080
      target_port = 8080
      protocol    = "TCP"
    }
  }
}
