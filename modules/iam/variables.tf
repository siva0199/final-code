variable "project_name" {
  description = "A name for the project to be used in resource tags."
  type        = string
  default     = "iac-demo"
}

variable "s3_bucket_arn" {
  description = "ARN of the S3 bucket for Lambda uploads."
  type        = string
}

