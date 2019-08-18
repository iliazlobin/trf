variable "env" {}
variable "tags" {}
variable "this" {}

resource "aws_instance" "web" {
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"

  tags = {
    Name = "HelloWorld"
  }
}

resource "aws_launch_template" "this" {
  name = var.tags.Name

  dynamic "iam_instance_profile" {
    for_each = aws_iam_instance_profile.this[*].arn
    iterator = it
    content {
      arn = it.value
    }
  }
  image_id                             = var.this.aws_launch_template.image_id
  instance_type                        = var.this.aws_launch_template.instance_type
  instance_initiated_shutdown_behavior = "terminate"
  key_name                             = aws_key_pair.this.key_name

  # network_interfaces {
  #   associate_public_ip_address = true
  #   security_groups = ""
  # }
  vpc_security_group_ids = var.this.aws_launch_template.vpc_security_group_ids[*].id
  user_data              = var.this.aws_launch_template.user_data != null ? "${base64encode(var.this.aws_launch_template.user_data)}" : null
  tags                   = var.tags
}

resource "aws_iam_instance_profile" "this" {
  count = var.this.aws_iam_instance_profile != null ? 1 : 0
  name  = var.tags.Name
  role  = var.this.aws_iam_instance_profile.aws_iam_role.id
}

resource "aws_key_pair" "this" {
  key_name   = var.tags.Name
  public_key = var.this.aws_key_pair.public_key
}

output "this" {
  value = {
    
  }
}
