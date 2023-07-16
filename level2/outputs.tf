output "website_url" {
  description = "Website URL"
  value       = "https://www.appsite-paul.link"
}

output "aws_region_name" {
  description = "AWS region name"
  value       = data.aws_region.this.name
}

output "rds_db_instance_endpoint" {
  description = "RDS db instance endpoint"
  value       = module.rds.db_instance_address
}

output "mysql_connect_command" {
  description = "Connect with SessionManager to ASG instance and test following command:"
  value       = "mysql -u admin -p -h ${module.rds.db_instance_address}"
}
