# iam.tf
# IAM roles & instance profile to allow EC2 to run ECS agent, pull from ECR, read Secrets/SSM, and send logs

# Role for EC2 instances (ECS container host)
resource "aws_iam_role" "ec2_role" {
  # Role attached to EC2 instances so they can run ECS agent and perform actions
  name               = "${var.prefix}-ec2-role"
  assume_role_policy = file("./templates/ecs/ec2-assume-role-policy.json")
  tags = merge(
    local.common_tags,
    { "Name" = "${local.prefix}-main" }
  )
}

# Attach AWS managed policy that provides ECS instance permissions
resource "aws_iam_role_policy_attachment" "ecs_managed" {
  # Enables EC2 to be an ECS container instance
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

# Inline policy giving EC2 permissions to pull images, read secrets, write logs, and read S3 static assets
resource "aws_iam_role_policy" "ec2_extra" {
  name = "${var.prefix}-ec2-extra"
  role = aws_iam_role.ec2_role.id
  policy = file("./templates/ec2/ec2-extra-policy.json")
}

# Instance profile for EC2 to attach the role
resource "aws_iam_instance_profile" "ec2_profile" {
  # Instance profile used by the Launch Template to give EC2 the IAM role
  name = "${var.prefix}-ec2-profile"
  role = aws_iam_role.ec2_role.name
}
