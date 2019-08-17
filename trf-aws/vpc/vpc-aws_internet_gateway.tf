resource "aws_internet_gateway" "this" {
  count  = var.this.aws_internet_gateway-data == null ? 1 : 0
  tags   = var.tags
  vpc_id = local.aws_vpc.id
}

data "aws_internet_gateway" "this" {
  count               = var.this.aws_internet_gateway-data != null ? 1 : 0
  internet_gateway_id = var.this.aws_internet_gateway-data.internet_gateway_id
}

locals {
  aws_internet_gateway0 = var.this.aws_internet_gateway-data == null ? aws_internet_gateway.this : data.aws_internet_gateway.this
  aws_internet_gateway = local.aws_internet_gateway0[0]
}
