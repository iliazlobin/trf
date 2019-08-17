variable "env" {}
variable "tags" {}
variable "this" {}

resource "aws_lb" "this" {
  count              = var.this.aws_lb != null ? 1 : 0
  name               = var.tags.Name
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.this.aws_lb.security_groups[*].id
  subnets            = var.this.aws_lb.subnets[*].id
  tags               = var.tags
}

resource "aws_autoscaling_group" "this" {
  max_size                  = var.this.aws_autoscaling_group.max_size
  min_size                  = var.this.aws_autoscaling_group.min_size
  desired_capacity          = var.this.aws_autoscaling_group.desired_capacity
  health_check_type         = var.this.aws_autoscaling_group.health_check_type != null ? var.this.aws_autoscaling_group.health_check_type : "EC2"
  health_check_grace_period = var.this.aws_autoscaling_group.health_check_grace_period != null ? var.this.aws_autoscaling_group.health_check_grace_period : 300

  vpc_zone_identifier = var.this.aws_autoscaling_group.vpc_zone_identifier[*].id
  # target_group_arns   = var.this.aws_autoscaling_group.target_group_arns[*].arn

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }
  dynamic "tag" {
    for_each = var.tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
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
