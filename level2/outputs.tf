output "loadbalancer_url" {
  value = "http://${module.lb.loadbalancer_dns_name}"
}
