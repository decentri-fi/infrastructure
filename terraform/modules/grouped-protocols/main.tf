variable "group-name" {}
variable "companies" {
  type = list(string)
}
variable "base-image" {
}

resource "kubernetes_service" "defitrack-grouped-protocol" {
  metadata {
    name   = "defitrack-group-${var.group-name}"
    labels = {
      team = "decentrifi"
    }
  }

  spec {
    selector = {
      app = "defitrack-group-${var.group-name}"
    }

    port {
      name        = "http-traffic"
      port        = 8080
      target_port = 8080
      protocol    = "TCP"
    }
  }
}

resource "kubernetes_deployment" "defitrack-grouped-protocol" {
  metadata {
    name   = "defitrack-group-${var.group-name}"
    labels = {
      app : "defitrack-group-${var.group-name}"
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
        app : "defitrack-group-${var.group-name}"
      }
    }
    strategy {
      type = "RollingUpdate"
      rolling_update {
        max_surge       = 1
        max_unavailable = "25%"
      }
    }
    template {
      metadata {
        labels = {
          app : "defitrack-group-${var.group-name}"
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
            name = "defitrack-grouped-protocol"
          }
        }
        container {
          image             = "${var.base-image}:unified-protocols-production"
          name              = "defitrack-group-${var.group-name}"
          image_pull_policy = "Always"
          port {
            container_port = 8080
          }
          env {
            name  = "SPRING_PROFILES_ACTIVE"
            value = "kubernetes"
          }
          env {
            name  = "COMPANIES"
            value = join(",", var.companies)
          }
          env {
            name  = "SPRING_CONFIG_LOCATION"
            value = "/application/config/application.properties"
          }
          volume_mount {
            mount_path = "/application/config"
            name       = "config-volume"
          }
          readiness_probe {
            http_get {
              path = "/actuator/health/readiness"
              port = 8080
            }
            period_seconds        = 5
            timeout_seconds       = 2
            failure_threshold     = 1
            success_threshold     = 1
          }
          startup_probe {
            http_get {
              path = "/actuator/health/liveness"
              port = 8080
            }
            failure_threshold = 360
            period_seconds    = 30
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
  wait_for_rollout = false
}
