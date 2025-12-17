output "vpc_id" {
  value       = aws_vpc.this.id
  description = "VPC ID."
}

output "public_subnet_ids" {
  value       = [for s in aws_subnet.public : s.id]
  description = "Public subnet IDs."
}

output "private_app_subnet_ids" {
  value       = [for s in aws_subnet.private_app : s.id]
  description = "Private app subnet IDs."
}

output "private_ingress_subnet_ids" {
  value       = [for s in aws_subnet.private_ingress : s.id]
  description = "Private ingress subnet IDs."
}

output "private_ingress_route_table_id" {
  value       = aws_route_table.private_ingress.id
  description = "Ingress route table ID."
}
