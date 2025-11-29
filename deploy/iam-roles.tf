
# IAM roles & instance profile to allow EC2 to run ECS agent, pull from ECR, read Secrets/SSM, and send logs


# Role for EC2 instances (ECS container host)
resource "aws_iam_role" "ec2_instance_role" {
  # Role attached to EC2 instances so they can run ECS agent and perform actions
  name               = "${var.prefix}-ec2-instance-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

# Extra permissions for EC2 to pull from ECR, read Secrets/SSM, send logs
resource "aws_iam_role_policy" "ec2_role_policy" {
  name   = "${var.prefix}-ec2_role_policy"
  role   = aws_iam_role.ec2_instance_role.id
  policy = file("./templates/ecs/ecs-task-role.json")
  depends_on = [aws_iam_role.ec2_instance_role]
}

# Instance profile for EC2 to attach the role
resource "aws_iam_instance_profile" "ec2_profile" {
  # Instance profile used by the Launch Template to give EC2 the IAM role
  name = "${var.prefix}-ec2-profile"
  role = aws_iam_role.ec2_instance_role.name
  depends_on = [aws_iam_role.ec2_instance_role]
}

