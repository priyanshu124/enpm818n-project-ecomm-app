data "aws_ami" "php-app" {
  most_recent = true
  owners      = ["self"] # Only pick AMIs in your AWS account

  filter {
    name   = "name"
    values = ["php-app-*"] # Matches Packer-built AMIs
  }
}

# Launch template used by ASG to launch EC2 instances
resource "aws_launch_template" "lt" {
  # Launch template with IAM instance profile and security group for EC2 instances
  name_prefix   = "${var.prefix}-lt-"
  image_id      = data.aws_ami.php-app.id
  instance_type = var.instance_type
  iam_instance_profile { name = aws_iam_instance_profile.ec2_profile.name }
  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.ec2.id]
  }
  key_name = var.ssh_key_name
  #user_data = base64encode(data.template_file.user_data.rendered)
  tag_specifications {
    resource_type = "instance"
    tags = merge(
      local.common_tags,
      { "Name" = "${local.prefix}-app-launch-template" }
    )
  }
}

# Auto Scaling Group to maintain the desired number of EC2 instances
resource "aws_autoscaling_group" "asg" {
  # Manages EC2 capacity; scales between min/max/desired
  name             = "${var.prefix}-asg"
  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity
  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Latest"
  }

  #triggers rolling replacement when LT changes
  instance_refresh {
    strategy = "Rolling"

    preferences {
      min_healthy_percentage = 50
    }

    # Trigger a refresh when launch template changes (new AMI)
    triggers = ["launch_template"]
  }

  lifecycle {
    create_before_destroy = true
  }
  vpc_zone_identifier = [aws_subnet.private_a.id, aws_subnet.private_b.id]
  health_check_type   = "ELB"

  # attach to a target group so that instances are behind a load balancer
  target_group_arns = [aws_lb_target_group.app.arn]

  tag {
    key                 = "Name"
    value               = "${var.prefix}-app-instance"
    propagate_at_launch = true
  }

}
