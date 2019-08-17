variable "env" {}
variable "tags" {}
variable "this" {}

module "ntw-public" {
  source = "./ntw"
  env    = var.env
  tags   = merge(var.tags, { Name = "${var.tags.Name}-ntw-public" })
  this = {
    aws_vpc                 = local.aws_vpc
    aws_subnet-list         = var.this.ntw-public.aws_subnet-list
    aws_subnet-data-list    = var.this.ntw-public.aws_subnet-data-list
    map_public_ip_on_launch = true
    aws_route = {
      aws_internet_gateway = local.aws_internet_gateway
      aws_nat_gateway-list = null
    }
  }
}

module "ntw-private" {
  source = "./ntw"
  env    = var.env
  tags   = merge(var.tags, { Name = "${var.tags.Name}-ntw-private" })
  this = {
    aws_vpc                 = local.aws_vpc
    aws_subnet-list         = var.this.ntw-private.aws_subnet-list
    aws_subnet-data-list    = var.this.ntw-private.aws_subnet-data-list
    map_public_ip_on_launch = false
    aws_route = {
      aws_internet_gateway = null
      aws_nat_gateway-list = local.aws_nat_gateway
    }
  }
}

output "this" {
  value = {
    aws_vpc     = local.aws_vpc
    ntw-public  = module.ntw-public.this
    ntw-private = module.ntw-private.this
  }
}
