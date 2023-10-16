resource "kubernetes_deployment" "decentrifi-frontend" {
  metadata {
    name   = "decentrifi-frontend"
    labels = {
      app : "decentrifi-frontend"
    }
  }

  spec {
    replicas = "1"
    selector {
      match_labels = {
        app : "decentrifi-frontend"
      }
    }
    strategy {
      type = "RollingUpdate"
    }
    template {
      metadata {
        labels = {
          app : "decentrifi-frontend"
        }
      }
      spec {
        container {
          image             = "${var.base-image}:frontend-v2-production"
          name              = "decentrifi-frontend"
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

resource "kubernetes_service" "defitrack-frontend-service" {

  metadata {
    name = "decentrifi-frontend"
  }

  spec {
    selector = {
      app = "decentrifi-frontend"
    }

    port {
      name        = "http"
      port        = 80
      target_port = 80
      protocol    = "TCP"
    }
  }
}