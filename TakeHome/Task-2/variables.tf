variable "aws_region" {
  type        = string
  description = "AWS region for the regional hub."
  default     = "us-west-2"
}

variable "environment" {
  type        = string
  description = "Environment name (e.g., prod, staging)."
  default     = "prod"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the hub VPC."
  default     = "10.50.0.0/16"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public subnet CIDRs (one per AZ)."
  default = [
    "10.50.0.0/20",
    "10.50.16.0/20",
    "10.50.32.0/20"
  ]
}

variable "private_app_subnet_cidrs" {
  type        = list(string)
  description = "Private subnet CIDRs for app/compute."
  default = [
    "10.50.128.0/20",
    "10.50.144.0/20",
    "10.50.160.0/20"
  ]
}

variable "private_ingress_subnet_cidrs" {
  type        = list(string)
  description = "Private subnet CIDRs for ingress/TGW."
  default = [
    "10.50.64.0/20",
    "10.50.80.0/20",
    "10.50.96.0/20"
  ]
}

variable "tgw_id" {
  type        = string
  description = "Transit Gateway ID (mock input)."
  default     = "tgw-0123456789abcdef0"
}

variable "tgw_route_table_id" {
  type        = string
  description = "Transit Gateway route table ID (mock input)."
  default     = "tgw-rtb-0123456789abcdef0"
}

variable "cluster_name" {
  type        = string
  description = "Name of the container cluster."
  default     = "skylo-hub-eks"
}

variable "cluster_type" {
  type        = string
  description = "Cluster type: eks or ecs."
  default     = "eks"

  validation {
    condition     = contains(["eks", "ecs"], var.cluster_type)
    error_message = "cluster_type must be either \"eks\" or \"ecs\"."
  }
}

variable "tags" {
  type        = map(string)
  description = "Common tags applied to all resources."
  default = {
    project = "skylo-regional-hub"
  }
}
