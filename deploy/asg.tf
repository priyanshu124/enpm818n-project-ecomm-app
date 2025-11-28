# Find recent ECS-optimized Amazon Linux 2 AMI
data "aws_ami" "ecs_ami" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
  name   = "virtualization-type"
  values = ["hvm"]
  }
}

# Render user-data template for EC2 instances
data "template_file" "user_data" {
  template = file("./templates/ec2/ec2-userdata.tpl")
  vars = {
    ecs_cluster_name = aws_ecs_cluster.cluster.name
  }
}

# Launch template used by ASG to launch ECS-optimized EC2 instances
resource "aws_launch_template" "lt" {
  # Launch template with IAM instance profile and security group so EC2 can run ECS tasks and pull images
  name_prefix   = "${var.prefix}-lt-"
  image_id      = data.aws_ami.ecs_ami.id
  instance_type = var.instance_type
  iam_instance_profile { name = aws_iam_instance_profile.ec2_profile.name }
  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.ecs.id]
  }
  key_name  = var.ssh_key_name
  user_data = base64encode(data.template_file.user_data.rendered)
  tag_specifications {
    resource_type = "instance"
    tags = merge(
      local.common_tags,
      { "Name" = "${local.prefix}-ec2-launch-template" }
    )
  }
}

# Auto Scaling Group to maintain the desired number of ECS container hosts
resource "aws_autoscaling_group" "asg" {
  # Manages EC2 capacity for ECS cluster; scales between min/max/desired
  name             = "${var.prefix}-asg"
  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity
  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Latest"
  }
  vpc_zone_identifier = [aws_subnet.public_a.id, aws_subnet.public_b.id]
  health_check_type   = "EC2"
  target_group_arns   = [aws_lb_target_group.app.arn]
  tag {
    key                 = "Name"
    value               = "${var.prefix}-ecs-instance"
    propagate_at_launch = true
  }
  depends_on = [aws_ecs_cluster.cluster]
}
