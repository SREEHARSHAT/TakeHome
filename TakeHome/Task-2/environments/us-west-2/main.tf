module "vpc" {
  source              = "../../modules/vpc"
  cidr_block          = var.cidr_block
  name                = var.name
  public_subnet_cidrs = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

module "transit_gateway" {
  source     = "../../modules/transit_gateway"
}

