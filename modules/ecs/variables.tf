variable "project_name" {
  description = "A name for the project to be used in resource tags."
  type        = string
  default     = "iac-demo"
}

variable "aws_region" {
  description = "AWS region for the resources."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC."
  type        = string
}

variable "app_subnet_ids" {
  description = "List of private application subnet IDs."
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "The security group ID of the ALB."
  type        = string
}

variable "ecs_instance_profile_name" {
  description = "The name of the IAM instance profile for ECS instances."
  type        = string
}

variable "ecs_task_execution_role_arn" {
  description = "The ARN of the ECS task execution IAM role."
  type        = string
}

variable "target_group_a_arn" {
  description = "The ARN of the target group for service A."
  type        = string
}

variable "target_group_b_arn" {
  description = "The ARN of the target group for service B."
  type        = string
}

