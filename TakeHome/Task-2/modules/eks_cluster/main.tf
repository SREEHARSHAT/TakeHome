locals {
  base_tags = merge(
    var.tags,
    {
      Component = "container-platform"
    }
  )
}

resource "aws_eks_cluster" "this" {
  count    = var.cluster_type == "eks" ? 1 : 0
  name     = var.cluster_name
  role_arn = "arn:aws:iam::123456789012:role/placeholder-eks-role"

  vpc_config {
    subnet_ids = var.subnet_ids
  }

  tags = local.base_tags
}

resource "aws_ecs_cluster" "this" {
  count = var.cluster_type == "ecs" ? 1 : 0
  name  = var.cluster_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = local.base_tags
}
