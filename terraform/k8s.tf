################################
# NAMESPACE
################################
resource "kubernetes_namespace_v1" "app" {
  metadata {
    name = var.namespace
  }
}

################################
# DEPLOYMENT
################################
resource "kubernetes_deployment_v1" "app" {
  metadata {
    name      = var.app_name
    namespace = kubernetes_namespace_v1.app.metadata[0].name

    labels = {
      app = var.app_name
    }
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        app = var.app_name
      }
    }

    template {
      metadata {
        labels = {
          app = var.app_name
        }
      }

      spec {
        container {
          name  = var.app_name
          image = var.image

          port {
            container_port = var.container_port
          }

          resources {
            requests = {
              cpu    = "250m"
              memory = "256Mi"
            }
            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
          }
        }
      }
    }
  }
}

################################
# SERVICE (LOAD BALANCER)
################################
resource "kubernetes_service_v1" "app" {
  metadata {
    name      = var.app_name
    namespace = kubernetes_namespace_v1.app.metadata[0].name

    labels = {
      app = var.app_name
    }
  }

  spec {
    selector = {
      app = var.app_name
    }

    port {
      port        = var.service_port
      target_port = var.container_port
    }

    type = "LoadBalancer"
  }
}
################################
# OUTPUT URL
################################
output "app_url" {
  description = "Public URL of the application LoadBalancer"
  value = try(
    kubernetes_service.app.status[0].load_balancer[0].ingress[0].hostname,
    "pending-loadbalancer"
  )
}
