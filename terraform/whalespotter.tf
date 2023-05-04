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
      node_port = 31117
    }

    type = "NodePort"
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

    type = "NodePort"
  }
}

resource "kubernetes_service" "whalespotter-runner" {

  metadata {
    name      = "whalespotter-runner"
  }

  spec {
    selector = {
      app = "whalespotter-runner"
    }

    port {
      name = "http"
      port = 8080
      target_port = 8080
      protocol = "TCP"
    }
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

resource "kubernetes_deployment" "whalespotter-runner" {
  metadata {
    name   = "whalespotter-runner"
    labels = {
      app : "whalespotter-runner"
    }
  }
  spec {
    replicas = "1"
    selector {
      match_labels = {
        app : "whalespotter-runner"
      }
    }
    strategy {
      type = "RollingUpdate"
    }
    template {
      metadata {
        labels = {
          app : "whalespotter-runner"
        }
      }
      spec {
        volume {
          name = "config-volume"
          config_map {
            name = "whalespotter-runner"
          }
        }
        container {
          image             = "${var.base-image}:whalespotter-runner-production"
          name              = "whalespotter-runner"
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