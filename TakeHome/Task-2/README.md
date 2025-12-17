# Skylo Regional Hub - Terraform Infrastructure

This repository contains the Terraform code to provision the foundational infrastructure for the Skylo Regional Hub in the `us-west-2` AWS region.

## Modules

- **VPC**: Creates the VPC, subnets, route tables, NAT Gateways, and Internet Gateway.
- **Transit Gateway**: Attaches the VPC to a Transit Gateway.
- **EKS Cluster**: Skeleton module for deploying an EKS cluster.

## Usage

1. Navigate to the environments/us-west-2 directory.
2. Update the `terraform.tfvars` file with your desired configuration.

3. Run the following commands:
   terraform init
   terraform plan
   terraform apply

