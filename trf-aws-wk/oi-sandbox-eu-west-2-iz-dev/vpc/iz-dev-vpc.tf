locals {
  env = {
    provider = "aws"
    aws = {
      profile = "oi-sandbox"
      region = "eu-west-2"
    }
    name = "iz-dev"
  }
  tags = {
    Name = local.env.name
  }
  secrets = {
  }
}

terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  version = "~> 2.0"
  region  = local.env.aws.region
}

module "vpc" {
  source = "/c/home/ws/trf/trf-aws/vpc"
  env = local.env
  tags = merge({ Name = "${local.tags.Name}-vpc" }, local.tags)

  this = {
    aws_vpc = {
      cidr_block = "10.240.0.0/16"
    }
    aws_vpc-data = null
    ntw-public = {
      aws_subnet-list = [
        {
          availability_zone = "eu-west-2a"
          cidr_block        = "10.240.11.0/24"
        },
        {
          availability_zone = "eu-west-2b"
          cidr_block        = "10.240.12.0/24"
        },
        {
          availability_zone = "eu-west-2c"
          cidr_block        = "10.240.13.0/24"
        },
      ]
      aws_subnet-data-list = null
    }
    ntw-private = {
      aws_subnet-list = [
        {
          availability_zone = "eu-west-2a"
          cidr_block        = "10.240.21.0/24"
        },
        {
          availability_zone = "eu-west-2b"
          cidr_block        = "10.240.22.0/24"
        },
        {
          availability_zone = "eu-west-2c"
          cidr_block        = "10.240.23.0/24"
        },
      ]
      aws_subnet-data-list = null
    }
    aws_eip-data = null
    aws_nat_gateway-data = null
    aws_internet_gateway-data = null
  }
}

output "this" { value = module.vpc.this }
