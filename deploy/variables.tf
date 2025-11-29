variable "prefix" {
  default = "enpm818n"
}

variable "project" {
  default = "ecomm-app"
}

variable "contact" {
  default = "priyanshu12498@gmail.com"
}

variable "region" {
  default = "us-east-1"
}


variable "instance_type" {
  description = "EC2 instance type for ECS container instances"
  default     = "t3.micro"
}


variable "db_username" {
  description = "Username for the recipe app api database"
  default     = "appuser"
}

variable "db_name" {
  description = "database name for ecommerce app"
  default     = "ecommerce_1"
}

variable "db_password" {
  description = "Password for the ecommerce app database"
}

variable "domain" {
  description = "Domain name"
  default     = "enpm818n-ecomm-app.xyz"
}

variable "ssh_key_name" {
  default     = "enpm818n-ec2-ssh-key"
  description = "Name of the SSH key pair for EC2 access"
}

variable "min_size" {
  description = "ASG min instances"
  type        = number
  default     = 1
}

variable "desired_capacity" {
  description = "ASG desired instances"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "ASG max instances"
  type        = number
  default     = 3
}

variable "ecr_repo_url" {
  description = "ECR repository URL for the ecommerce app"
  default     = "245838289780.dkr.ecr.us-east-1.amazonaws.com/enpm818n/ecommerce-app"
}
