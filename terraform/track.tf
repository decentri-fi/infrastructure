resource "kubernetes_deployment" "decentrifi-track" {
  metadata {
    name   = "decentrifi-track"
    labels = {
      app : "decentrifi-track"
    }
  }

  spec {
    replicas = "1"
    selector {
      match_labels = {
        app : "decentrifi-track"
      }
    }
    strategy {
      type = "RollingUpdate"
    }
    template {
      metadata {
        labels = {
          app : "decentrifi-track"
        }
      }
      spec {
        container {
          image             = "${var.base-image}:decentrifi-track-production"
          name              = "decentrifi-track"
          image_pull_policy = "Always"
          port {
            container_port = 80
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

resource "kubernetes_service" "decentrifi-track-service" {

  metadata {
    name = "decentrifi-track"
  }

  spec {
    selector = {
      app = "decentrifi-track"
    }

    port {
      name        = "http"
      port        = 80
      target_port = 80
      protocol    = "TCP"
    }
  }
}