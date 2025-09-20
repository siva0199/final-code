output "ecs_task_execution_role_arn" {
  description = "The ARN of the ECS task execution role."
  value       = aws_iam_role.ecs_task_execution_role.arn
}

output "ecs_instance_profile_arn" {
  description = "The ARN of the IAM instance profile for ECS container instances."
  value       = aws_iam_instance_profile.ecs_instance_profile.arn
}

output "ecs_instance_profile_name" {
  description = "The name of the IAM instance profile for ECS container instances."
  value       = aws_iam_instance_profile.ecs_instance_profile.name
}

output "lambda_execution_role_arn" {
  description = "The ARN of the Lambda execution role."
  value       = aws_iam_role.lambda_execution_role.arn
}

