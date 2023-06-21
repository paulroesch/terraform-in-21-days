output "loadbalancer_dns_name" {
  value = aws_lb.main.dns_name
}

output "loadbalancer_id" {
  value = aws_lb.main.id
}

output "loadbalancer_target_group_arn" {
  value = aws_lb_target_group.main.arn
}

output "loadbalancer_sg_id" {
  value = aws_security_group.load-balancer.id
}
