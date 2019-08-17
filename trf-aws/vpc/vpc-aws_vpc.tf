resource "aws_vpc" "this" {
  count                = var.this.aws_vpc-data == null ? 1 : 0
  tags                 = var.tags
  cidr_block           = var.this.aws_vpc.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
}

data "aws_vpc" "this" {
  count = var.this.aws_vpc-data != null ? 1 : 0
  id    = var.this.aws_vpc-data.id
}

locals {
  aws_vpc0 = var.this.aws_vpc-data == null ? aws_vpc.this : data.aws_vpc.this
  aws_vpc = local.aws_vpc0[0]
}
