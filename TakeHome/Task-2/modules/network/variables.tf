variable "aws_region" {
  type        = string
  description = "AWS region."
}

variable "environment" {
  type        = string
  description = "Environment name."
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR."
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public subnet CIDRs."
}

variable "private_app_subnet_cidrs" {
  type        = list(string)
  description = "Private app subnet CIDRs."
}

variable "private_ingress_subnet_cidrs" {
  type        = list(string)
  description = "Private ingress subnet CIDRs."
}

variable "tags" {
  type        = map(string)
  description = "Tags."
}
