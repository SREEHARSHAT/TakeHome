variable "aws_region" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "tgw_id" {
  type = string
}

variable "tgw_route_table_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "ingress_rt_id" {
  type = string
}

variable "tags" {
  type = map(string)
}
