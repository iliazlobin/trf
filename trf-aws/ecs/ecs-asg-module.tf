module "asg" {
  source                = "/c/home/ws/trf/trf-aws/asg"
  env                   = var.env
  tags                  = var.this.asg.tags
  this = {
    aws_lb                = var.this.asg.aws_lb
    aws_autoscaling_group = var.this.asg.aws_autoscaling_group
    aws_launch_template = {
      vpc_security_group_ids = var.this.asg.aws_launch_template.vpc_security_group_ids
      image_id               = var.this.asg.aws_launch_template.image_id
      instance_type          = var.this.asg.aws_launch_template.instance_type
      # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/launch_container_instance.html
      # ECS_CONTAINER_INSTANCE_TAGS={"tag_key": "tag_value"}
      user_data = <<-EOT
        #!/bin/bash
        cat <<'EOD' >> /etc/ecs/ecs.config
        ECS_CLUSTER=${aws_ecs_cluster.this.name}
        EOD
      EOT
    }
    aws_key_pair             = var.this.asg.aws_key_pair
    aws_iam_instance_profile = var.this.asg.aws_iam_instance_profile
  }
}
