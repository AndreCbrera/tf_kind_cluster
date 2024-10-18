provider "kubernetes" {
  # Docs: https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs
  config_path    = "~/.kube/config"
  config_context = local.cluster_context
}

provider "helm" {
  # Docs: https://registry.terraform.io/providers/hashicorp/helm/latest/docs
  kubernetes {
    config_path    = "~/.kube/config"
    config_context = local.cluster_context
  }
}