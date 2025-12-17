provider "aws" {
  region = var.aws_region
}

locals {
  common_tags = merge(
    var.tags,
    {
      environment = var.environment
      region      = var.aws_region
    }
  )
}

module "network" {
  source = "./modules/network"

  aws_region                   = var.aws_region
  environment                  = var.environment
  vpc_cidr                     = var.vpc_cidr
  public_subnet_cidrs          = var.public_subnet_cidrs
  private_app_subnet_cidrs     = var.private_app_subnet_cidrs
  private_ingress_subnet_cidrs = var.private_ingress_subnet_cidrs
  tags                         = local.common_tags
}

module "transit_gateway" {
  source = "./modules/transit-gateway"

  aws_region         = var.aws_region
  environment        = var.environment
  vpc_id             = module.network.vpc_id
  vpc_cidr           = var.vpc_cidr
  tgw_id             = var.tgw_id
  tgw_route_table_id = var.tgw_route_table_id
  subnet_ids         = module.network.private_ingress_subnet_ids
  ingress_rt_id      = module.network.private_ingress_route_table_id
  tags               = local.common_tags
}

module "eks" {
  source = "./modules/eks"

  aws_region   = var.aws_region
  environment  = var.environment
  cluster_name = var.cluster_name
  cluster_type = var.cluster_type
  vpc_id       = module.network.vpc_id
  subnet_ids   = module.network.private_app_subnet_ids
  tags         = local.common_tags
}
