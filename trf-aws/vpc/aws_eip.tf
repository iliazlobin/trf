# resource "aws_eip" "this" {
#   count = length(module.ntw-public.this.aws_subnet-list)
# }

resource "aws_eip" "this" {
  count = var.this.aws_eip-data == null ? 1 : 0
  tags  = var.tags
}

data "aws_eip" "this" {
  count = var.this.aws_eip-data != null ? 1 : 0
  id    = var.this.aws_eip-data.id
}

locals {
  aws_eip = var.this.aws_eip-data == null ? aws_eip.this : data.aws_eip.this
}
