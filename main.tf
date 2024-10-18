terraform {
    #required_version = ">= 1.9.0"

    required_providers {
            kind = {
                source  = "tehcyx/kind"
                version = ">= 0.6.0"
            }
    }
}

resource "kind_cluster" "cluster" {
    name            = local.cluster_name
    node_image      = "kindest/node:v${local.cluster_version}"
    wait_for_ready  = true

    kind_config {
       kind        = "Cluster"
       api_version = "kind.x-k8s.io/v1alpha4"

       # Worker configurations
       node {
        role = "worker"
        kubeadm_config_patches = [
            "kind: JoinConfiguration\nnodeRegistration:\n  kubeletExtraArgs:\n    node-labels: \"ingress-ready=true\"\n"
        ]
        extra_port_mappings {
            container_port = 80
            host_port      = 8080
            listen_address  = "0.0.0.0"
        }
       }
      # Control plane
       node {
        role = "control-plane"
       }
    }
}

resource "null_resource" "wait_for_cluster" {
    depends_on = [kind_cluster.cluster ]
}
resource "helm_release" "nginx_ingress" {
  # This depends on kind cluster being created first
  depends_on = [null_resource.wait_for_cluster]

  name             = "nginx-ingress"
  repository       = var.nginx_ingress.chart_repository
  chart            = var.nginx_ingress.chart_name
  version          = var.nginx_ingress.chart_version
  namespace        = var.nginx_ingress.namespace
  create_namespace = true

  values = [templatefile("${path.root}/nginx-helm-chart-values-template.yaml", {
    ingressClassName = var.nginx_ingress.ingress_class_name
    replicas         = var.nginx_ingress.replicas
  })]

}

# local variables
locals {
  cluster_name       = "cluster1"
  cluster_version    = "1.31.0"
  cluster_context    = "kind-${local.cluster_name}"
  ingress_class_name = "nginx"
}