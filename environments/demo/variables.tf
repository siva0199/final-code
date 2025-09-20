variable "aws_region" {
  description = "The AWS region for the deployment."
  type        = string
}

variable "project_name" {
  description = "Name of the project."
  type        = string
  default     = "iac-demo"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
}

variable "public_subnet_cidrs" {
  description = "List of public subnet CIDRs."
  type        = list(string)
}

variable "app_subnet_cidrs" {
  description = "List of private app subnet CIDRs."
  type        = list(string)
}

variable "data_subnet_cidrs" {
  description = "List of private data subnet CIDRs."
  type        = list(string)
}

variable "num_azs" {
  description = "Number of AZs to use."
  type        = number
}

