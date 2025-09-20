data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/src"
  output_path = "${path.module}/upload_handler.zip"
}

resource "aws_s3_bucket" "upload_bucket" {
  bucket = var.s3_bucket_name

  tags = {
    Name = "${var.project_name}-uploads"
  }
}

resource "aws_s3_bucket_public_access_block" "block" {
  bucket = aws_s3_bucket.upload_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "lifecycle_rule" {
  bucket = aws_s3_bucket.upload_bucket.id

  rule {
    id     = "standard-ia-30days"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    expiration {
      days = 365
    }
  }
}

resource "aws_lambda_function" "upload_handler" {
  function_name    = "${var.project_name}-upload-handler"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  handler          = "upload_handler.lambda_handler"
  runtime          = "python3.11"
  role             = var.lambda_execution_role_arn

  environment {
    variables = {
      UPLOAD_BUCKET_NAME = aws_s3_bucket.upload_bucket.id
    }
  }

  tags = {
    Name = "${var.project_name}-upload-handler"
  }
}

resource "aws_apigatewayv2_api" "http_api" {
  name          = "${var.project_name}-http-api"
  protocol_type = "HTTP"
  description   = "API for file uploads"
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.http_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.upload_handler.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "upload_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "POST /upload"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_lambda_permission" "api_gateway_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.upload_handler.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${aws_lambda_function.upload_handler.function_name}"
  retention_in_days = 14
}

