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
      host = "swagger.decentri.fi"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "defitrack-swagger"
              port {
                number = 8080
              }
            }
          }
        }
      }
    }
    rule {
      host = "grafana.decentri.fi"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "prometheus-grafana"
              port {
                number = 80
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
