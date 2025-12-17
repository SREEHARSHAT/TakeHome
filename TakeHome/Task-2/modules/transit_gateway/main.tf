resource "aws_ec2_transit_gateway_vpc_attachment" "this" {
  transit_gateway_id = var.tgw_id
  vpc_id             = var.vpc_id
  subnet_ids         = var.subnet_ids

  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-tgw-attachment"
      Environment = var.environment
    }
  )
}

resource "aws_ec2_transit_gateway_route" "to_vpc" {
  transit_gateway_route_table_id = var.tgw_route_table_id
  destination_cidr_block         = var.vpc_cidr
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.this.id
}

# Example route back to org from ingress RT (mocked supernet)
resource "aws_route" "from_ingress_to_tgw" {
  route_table_id         = var.ingress_rt_id
  destination_cidr_block = "10.0.0.0/8"
  transit_gateway_id     = var.tgw_id
}
