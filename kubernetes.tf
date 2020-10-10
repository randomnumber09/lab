#kubernetes.tf

#Establish k8s provider
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
  version                = "~> 1.9"
} # end resource

#Create creds secret for passwords
resource "kubernetes_secret" "dbcreds" {
  metadata {
    name = "dbcreds"
  }

  data = {
    username = var.DB_USER
    password = var.DB_PASSWORD
  }
  depends_on = [module.eks.wait_for_cluster_interpreter] #wait for cluster to be awake
}                                                        # end resource

# Deploy application
resource "kubernetes_deployment" "johncookhello-world" {
  metadata {
    name = "hello-rubyrails"
  }
  spec {
    replicas = 3

    selector {
      match_labels = {
        "App" : "hello-rubyrails"
      }
    }

    template {
      metadata {
        labels = {
          App = "hello-rubyrails"
        }
      }

      spec {
        container {
          image = "randomnumber9/johncookrubyhelloworld:1.1"
          name  = "hello-rubyrails"
          port {
            container_port = 3000
          }
          env {
            name = "DATABASE_USER"
            value_from {
              secret_key_ref {
                key  = "username"
                name = "dbcreds"
              }
            }
          }
          env {
            name = "DATABASE_PASSWORD"
            value_from {
              secret_key_ref {
                key  = "password"
                name = "dbcreds"
              }
            }
          }
          env {
            name  = "DATABASE_HOST"
            value = aws_db_instance.labdb.address
          }
        }
      }
    }
  }
  depends_on = [module.eks.wait_for_cluster_interpreter]
} # end resource

#Deploy load balancer
resource "kubernetes_service" "johncookhello-world" {
  metadata {
    name = "hello-rubyrails"
  }
  spec {
    selector = {
      App = "hello-rubyrails"
    }
    port {
      port        = 80
      target_port = 3000
    }
    #session_affinity = "ClientIP"

    type = "LoadBalancer"
  }
  depends_on = [module.eks.wait_for_cluster_interpreter]

} # end resource

#Output ip address of load balancer to command line
output "lb_ip" {
  value = kubernetes_service.johncookhello-world.load_balancer_ingress[0].hostname
}
#end kubernetes.tf
