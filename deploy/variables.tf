variable "prefix" {
  default = "enpm818n"
}

variable "project" {
  default = "ecommerce-app"
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


variable "db_username" {
  description = "Username for the recipe app api database"
  default     = "ecomm-app-user"
}

variable "db_password" {
  description = "Password for the Terraform database"
}

variable "domain" {
  description = "Domain name"
  default     = "enpm818n-ecommerce.com"
}

