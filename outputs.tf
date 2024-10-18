output "cluster_endpoint" {
    value = kind_cluster.cluster.endpoint
}
output "nginx_ingress_app_version" {
    value = helm_release.nginx_ingress.metadata[0].app_version
}