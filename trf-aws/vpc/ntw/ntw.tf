variable "env" {}
variable "tags" {}
variable "this" {}

resource "aws_subnet" "this" {
  count                   = var.this.aws_subnet-data-list != null ? 0 : length(var.this.aws_subnet-list)
  tags                    = var.tags
  vpc_id                  = var.this.aws_vpc.id
  availability_zone       = var.this.aws_subnet-list[count.index].availability_zone
  cidr_block              = var.this.aws_subnet-list[count.index].cidr_block
  map_public_ip_on_launch = var.this.map_public_ip_on_launch
}

data "aws_subnet" "this" {
  count = var.this.aws_subnet-data-list != null ? length(var.this.aws_subnet-data-list) : 0
  id    = var.this.aws_subnet-data-list[count.index].id
}

locals {
  aws_subnet-list = var.this.aws_subnet-data-list != null ? data.aws_subnet.this : aws_subnet.this
}

resource "aws_route_table" "this" {
  count  = var.this.aws_subnet-data-list != null ? 0 : var.this.aws_route.aws_internet_gateway != null ? 1 : var.this.aws_route.aws_nat_gateway-list != null ? length(var.this.aws_route.aws_nat_gateway-list) : 0
  tags   = var.tags
  vpc_id = var.this.aws_vpc.id
}

resource "aws_route_table_association" "this" {
  count          = length(local.aws_subnet-list)
  route_table_id = var.this.aws_route.aws_internet_gateway != null ? aws_route_table.this[0].id : count.index < length(aws_route_table.this) ? aws_route_table.this[count.index].id : aws_route_table.this[0].id
  subnet_id      = local.aws_subnet-list[count.index].id
}

resource "aws_route" "this" {
  count                  = var.this.aws_subnet-data-list != null ? 0 : var.this.aws_route.aws_internet_gateway != null ? 1 : var.this.aws_route.aws_nat_gateway-list != null ? length(var.this.aws_route.aws_nat_gateway-list) : 0
  route_table_id         = var.this.aws_route.aws_internet_gateway != null ? aws_route_table.this[0].id : count.index < length(aws_route_table.this) ? aws_route_table.this[count.index].id : aws_route_table.this[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = var.this.aws_route.aws_internet_gateway != null ? var.this.aws_route.aws_internet_gateway.id : null
  nat_gateway_id         = var.this.aws_route.aws_internet_gateway != null ? null : count.index < length(var.this.aws_route.aws_nat_gateway-list) ? var.this.aws_route.aws_nat_gateway-list[count.index].id : var.this.aws_route.aws_nat_gateway-list[0].id
}

# data "aws_subnet" "public_subnets" {
#   count = length(var.this.aws_subnet-list)
#   id = "${element(concat(var.this.subnet-public_ids, list("")), count.index)}"
# }

output "this" {
  value = {
    aws_subnet-list = local.aws_subnet-list
  }
}
