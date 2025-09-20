variable "project_name" {
  description = "A name for the project to be used in resource tags."
  type        = string
  default     = "iac-demo"
}

variable "lambda_execution_role_arn" {
  description = "ARN of the IAM role for the Lambda function."
  type        = string
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket for uploads."
  type        = string
}

