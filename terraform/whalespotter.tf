resource "kubernetes_service" "whalespotter-web" {

  metadata {
    name      = "whalespotter-web"
  }

  spec {
    selector = {
      app = "whalespotter-web"
    }

    port {
      name = "http"
      port = 8080
      target_port = 8080
      protocol = "TCP"
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_service" "whalespotter-profit-calculator" {

  metadata {
    name      = "whalespotter-profit-calculator"
  }

  spec {
    selector = {
      app = "whalespotter-profit-calculator"
    }

    port {
      name = "http"
      port = 8080
      target_port = 8080
      protocol = "TCP"
    }

    type = "ClusterIP"
  }
}


resource "kubernetes_service" "whalespotter-suggestion-engine" {

  metadata {
    name      = "whalespotter-suggestion-engine"
  }

  spec {
    selector = {
      app = "whalespotter-suggestion-engine"
    }

    port {
      name = "http"
      port = 8080
      target_port = 8080
      protocol = "TCP"
    }

    type = "ClusterIP"
  }
}


resource "kubernetes_deployment" "whalespotter-web" {
  metadata {
    name   = "whalespotter-web"
    labels = {
      app : "whalespotter-web"
    }
  }
  spec {
    replicas = "1"
    selector {
      match_labels = {
        app : "whalespotter-web"
      }
    }
    strategy {
      type = "RollingUpdate"
    }
    template {
      metadata {
        labels = {
          app : "whalespotter-web"
        }
      }
      spec {
        volume {
          name = "config-volume"
          config_map {
            name = "whalespotter-web"
          }
        }
        container {
          image             = "${var.base-image}:whalespotter-web-production"
          name              = "whalespotter-web"
          image_pull_policy = "Always"
          volume_mount {
            mount_path = "/application/config"
            name       = "config-volume"
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

resource "kubernetes_deployment" "whalespotter-profit-calculator" {
  metadata {
    name   = "whalespotter-profit-calculator"
    labels = {
      app : "whalespotter-profit-calculator"
    }
  }
  spec {
    replicas = "1"
    selector {
      match_labels = {
        app : "whalespotter-profit-calculator"
      }
    }
    strategy {
      type = "RollingUpdate"
    }
    template {
      metadata {
        labels = {
          app : "whalespotter-profit-calculator"
        }
      }
      spec {
        volume {
          name = "config-volume"
          config_map {
            name = "whalespotter-profit-calculator"
          }
        }
        container {
          image             = "${var.base-image}:whalespotter-profit-calculator-production"
          name              = "whalespotter-profit-calculator"
          image_pull_policy = "Always"
          volume_mount {
            mount_path = "/application/config"
            name       = "config-volume"
          }
          port {
            container_port = 8080
          }
          readiness_probe {
            http_get {
              path = "/profit-calculator/actuator/health"
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
              path = "/profit-calculator/actuator/health"
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


resource "kubernetes_deployment" "whalespotter-suggestion-engine" {
  metadata {
    name   = "whalespotter-suggestion-engine"
    labels = {
      app : "whalespotter-suggestion-engine"
    }
  }
  spec {
    replicas = "1"
    selector {
      match_labels = {
        app : "whalespotter-suggestion-engine"
      }
    }
    strategy {
      type = "RollingUpdate"
    }
    template {
      metadata {
        labels = {
          app : "whalespotter-suggestion-engine"
        }
      }
      spec {
        volume {
          name = "config-volume"
          config_map {
            name = "whalespotter-web"
          }
        }
        container {
          image             = "${var.base-image}:whalespotter-suggestion-engine-production"
          name              = "whalespotter-suggestion-engine"
          image_pull_policy = "Always"
          volume_mount {
            mount_path = "/application/config"
            name       = "config-volume"
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
