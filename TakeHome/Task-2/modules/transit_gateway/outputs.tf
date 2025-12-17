output "attachment_id" {
  value       = aws_ec2_transit_gateway_vpc_attachment.this.id
  description = "TGW VPC attachment ID."
}
