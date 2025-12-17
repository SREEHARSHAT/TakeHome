output "vpc_id" {
  value       = module.network.vpc_id
  description = "ID of the hub VPC."
}

output "public_subnet_ids" {
  value       = module.network.public_subnet_ids
  description = "Public subnet IDs."
}

output "private_app_subnet_ids" {
  value       = module.network.private_app_subnet_ids
  description = "Private app subnet IDs."
}

output "private_ingress_subnet_ids" {
  value       = module.network.private_ingress_subnet_ids
  description = "Private ingress subnet IDs."
}

output "tgw_attachment_id" {
  value       = module.transit_gateway.attachment_id
  description = "TGW VPC attachment ID."
}

output "cluster_id" {
  value       = module.eks.cluster_id
  description = "Skeleton EKS/ECS cluster ID."
}