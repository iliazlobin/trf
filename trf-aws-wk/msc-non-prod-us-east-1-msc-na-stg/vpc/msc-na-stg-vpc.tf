locals {
  env = {
    provider = "aws"
    aws = {
      profile = "msc-na-stg"
      region = "us-east-1"
    }
    name = "prod"
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
    aws_vpc = null
    aws_vpc-data = {
      id = "vpc-0823515e3019418aa"
    }
    aws_eip-data = {
      id = "eipalloc-015d1bbdda347cc79"
    }
    aws_nat_gateway-data = {
      id = "nat-0b5b54e344391f7f9"
    }
    aws_internet_gateway-data = {
      internet_gateway_id = "igw-01428b6727c7197d0"
    }
    ntw-public = {
      aws_subnet-list = null
      aws_subnet-data-list = [
        {
          id = "subnet-0373acffa013f5ced"
        },
        {
          id = "subnet-00af564e768b3f8f7"
        },
        {
          id = "subnet-06ef8bffd36fa0544"
        },
      ]
    }
    ntw-private = {
      aws_subnet-list = null
      aws_subnet-data-list = [
        {
          id = "subnet-0de913435f77eca5b"
        },
        {
          id = "subnet-0754522e033ea87d3"
        },
        {
          id = "subnet-09c951145f6b401e9"
        },
      ]
    }
  }
}

output "this" { value = module.vpc.this }
