output "loadbalancer_url" {
  value = "http://${module.lb.loadbalancer_dns_name}"
}

output "aws_region_name" {
  value       = data.aws_region.this.name
  description = "AWS region name"
}
