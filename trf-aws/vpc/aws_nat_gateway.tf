# resource "aws_nat_gateway" "this" {
#   count         = length(module.ntw-public.this.aws_subnet-list)
#   subnet_id     = module.ntw-public.this.aws_subnet-list[count.index].id
#   allocation_id = aws_eip[count.index].id
# }

resource "aws_nat_gateway" "this" {
  count         = var.this.aws_nat_gateway-data == null ? 1 : 0
  tags          = var.tags
  subnet_id     = module.ntw-public.this.aws_subnet-list[0].id
  allocation_id = local.aws_eip[0].id
}

data "aws_nat_gateway" "this" {
  count = var.this.aws_nat_gateway-data != null ? 1 : 0
  id    = var.this.aws_nat_gateway-data.id
}

locals {
  aws_nat_gateway = var.this.aws_nat_gateway-data == null ? aws_nat_gateway.this : data.aws_nat_gateway.this
}
