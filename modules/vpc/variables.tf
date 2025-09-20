variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
}

variable "public_subnet_cidrs" {
  description = "A list of CIDR blocks for the public subnets."
  type        = list(string)
}

variable "app_subnet_cidrs" {
  description = "A list of CIDR blocks for the private application subnets."
  type        = list(string)
}

variable "data_subnet_cidrs" {
  description = "A list of CIDR blocks for the private data subnets."
  type        = list(string)
}

variable "num_azs" {
  description = "Number of Availability Zones to use."
  type        = number
}

variable "project_name" {
  description = "A name for the project to be used in resource tags."
  type        = string
  default     = "iac-demo"
}

