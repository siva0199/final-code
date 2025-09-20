variable "project_name" {
  description = "A name for the project to be used in resource tags."
  type        = string
  default     = "iac-demo"
}

variable "vpc_id" {
  description = "The ID of the VPC where the ALB will be deployed."
  type        = string
}

variable "public_subnet_ids" {
  description = "A list of public subnet IDs for the ALB."
  type        = list(string)
}

