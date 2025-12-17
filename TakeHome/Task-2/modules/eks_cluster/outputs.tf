output "cluster_id" {
  description = "ID of the EKS/ECS cluster (skeleton)."
  value = (
    var.cluster_type == "eks"
    ? (length(aws_eks_cluster.this) > 0 ? aws_eks_cluster.this[0].id : null)
    : (length(aws_ecs_cluster.this) > 0 ? aws_ecs_cluster.this[0].id : null)
  )
}