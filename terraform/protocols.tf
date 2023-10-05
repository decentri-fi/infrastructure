variable "protocols" {
  description = "Protocols that have their own service"
  type        = list(string)
  default     = [
    "olympusdao", "aave", "adamant", "apeswap", "aelin", "beefy", "compound", "balancer", "bancor", "beethovenx",
    "dfyn", "hop", "idex", "iron-bank", "kyberswap", "maplefinance", "mstable", "quickswap",
    "stargate", "sushiswap", "uniswap", "polycat", "convex", "curve", "dinoswap", "ribbon", "set", "wepiggy",
    "makerdao", "polygon-protocol", "looksrare", "dodo", "pooltogether", "velodrome", "lido", "qidao",
    "swapfish",
    "chainlink",
    "tokemak",
    "aura",
    "solidlizard",
    "camelot",
    "tornadocash",
    "blur",
    "cowswap",
    "gmx",
    "aerodrome",
    "alienbase",
    "stakefish",
    "baseswap",
    "autoearn",
    "moonwell",
    "arpa",
    "ovix",
    "gains",
    "radiant",
    "swell"
  ]
}

variable "networks" {
  description = "networks that have their own service"
  type        = list(string)
  default     = [
    "arbitrum", "ethereum", "optimism", "polygon", "polygon-zkevm", "base"
  ]
}

variable "infra" {
  description = "infra microservices"
  type        = list(string)
  default     = [
    "erc20", "ens", "balance", "price", "api-gw", "statistics", "events", "nft", "claimables"
  ]
}

variable "base-image" {
  default = "Base Image to pull from"
  type    = string
}

resource "kubernetes_service" "defitrack-protocol-services" {
  for_each = toset(var.protocols)

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

resource "kubernetes_service" "defitrack-infra-services" {
  for_each = toset(var.infra)

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

resource "kubernetes_ingress_v1" "decentrifi-ingress" {
  metadata {
    name        = "decentrifi-ingress"
    annotations = {
      "nginx.ingress.kubernetes.io/enable-cors" = "true"
    }
  }
  spec {
    ingress_class_name = "nginx"
    rule {
      host = "decentri.fi"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "decentrifi-frontend"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
    rule {
      host = "track.decentri.fi"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "decentrifi-track"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
    rule {
      host = "claimables.decentri.fi"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "defitrack-claimables"
              port {
                number = 8080
              }
            }
          }
        }
      }
    }
    rule {
      host = "whalespotter.decentri.fi"
      http {
        path {
          path      = "/profit-calculator"
          path_type = "Prefix"
          backend {
            service {
              name = "whalespotter-profit-calculator"
              port {
                number = 8080
              }
            }
          }
        }

        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "whalespotter-web"
              port {
                number = 8080
              }
            }
          }
        }
      }
    }
    rule {
      host = "api.decentri.fi"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "defitrack-api-gw"
              port {
                number = 8080
              }
            }
          }
        }
      }
    }
  }
  depends_on = [
    kubernetes_deployment.defitrack-infra
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
    replicas = "2"
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
          image             = "${var.base-image}:${var.networks[count.index]}-production"
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

resource "kubernetes_deployment" "defitrack-infra" {
  count = length(var.infra)
  metadata {
    name   = "defitrack-${var.infra[count.index]}"
    labels = {
      app : "defitrack-${var.infra[count.index]}"
    }
    annotations = {
      "prometheus.io/path" : "/actuator/prometheus"
      "prometheus.io/port" : "8080"
      "prometheus.io/scrape" : "true"
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
            name = "defitrack-${var.infra[count.index]}"
          }
        }
        container {
          image             = "${var.base-image}:${var.infra[count.index]}-production"
          name              = "defitrack-${var.infra[count.index]}"
          image_pull_policy = "Always"
          env_from {
            secret_ref {
              name = "newrelic"
            }
          }
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
          env {
            name  = "NEW_RELIC_DISTRIBUTED_TRACING_ENABLED"
            value = "false"
          }
          env {
            name  = "NEW_RELIC_JFR_ENABLED"
            value = "false"
          }
          env {
            name  = "NEW_RELIC_SPAN_EVENTS_ENABLED"
            value = "false"
          }
          env {
            name  = "NEW_RELIC_JMX_ENABLED"
            value = "false"
          }
          env {
            name  = "NEW_RELIC_APP_NAME"
            value = "defitrack-${var.infra[count.index]}"
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

resource "kubernetes_deployment" "defitrack-protocols" {
  count = length(var.protocols)
  metadata {
    name   = "defitrack-${var.protocols[count.index]}"
    labels = {
      app : "defitrack-${var.protocols[count.index]}"
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
        app : "defitrack-${var.protocols[count.index]}"
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
          app : "defitrack-${var.protocols[count.index]}"
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
            name = "defitrack-protocol"
          }
        }
        container {
          image             = "${var.base-image}:unified-protocols-production"
          name              = "defitrack-${var.protocols[count.index]}"
          image_pull_policy = "Always"
          port {
            container_port = 8080
          }
          env {
            name  = "SPRING_PROFILES_ACTIVE"
            value = "kubernetes"
          }
          env {
            name  = "COMPANY"
            value = var.protocols[count.index]
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
  depends_on = [
    kubernetes_deployment.defitrack-networks,
    kubernetes_deployment.defitrack-infra
  ]
  wait_for_rollout = false
}

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
