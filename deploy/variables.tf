variable "prefix" {
  default = "enpm818n"
}

variable "project" {
  default = "ecoomerce-app"
}

variable "contact" {
  default = "priyanshu12498@gmail.com"
}

variable "region" {
  default = "us-east-1"
}


variable "instance_type" {
  description = "EC2 instance type for ECS container instances"
  default     = "t2.micro"
}
