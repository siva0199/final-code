output "api_endpoint" {
  description = "The invoke URL for the API Gateway."
  value       = aws_apigatewayv2_api.http_api.api_endpoint
}

output "s3_bucket_id" {
  description = "The ID/Name of the S3 bucket for uploads."
  value       = aws_s3_bucket.upload_bucket.id
}

output "s3_bucket_arn" {
  description = "The ARN of the S3 bucket for uploads."
  value       = aws_s3_bucket.upload_bucket.arn
}

