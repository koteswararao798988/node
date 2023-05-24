
resource "kubernetes_deployment" "sample_controller" {
  metadata {
    name      = "sample-controller"
    labels = {
      app = "sample-controller"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "sample-controller"
      }
    }

    template {
      metadata {
        labels = {
          app = "sample-controller"
        }
      }

      spec {
        container {
          name  = "sample-controller"
          image = "controller-image:tag"
        }
      }
    }
  }
}

resource "kubernetes_ingress" "sample_ingress" {
  metadata {
    name      = "sample-ingress"

    annotations = {
      "kubernetes.io/ingress.class" = "eks-ingress-class"
    }
  }

  spec {
    rule {
      http {
        path {
          path = "/sample"
          backend {
            service_name = "sample-service"
            service_port = 80
          }
        }
      }
    }
  }
}

