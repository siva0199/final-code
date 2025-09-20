module "vpc" {
  source              = "../../modules/vpc"
  aws_region          = var.aws_region
  project_name        = var.project_name
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidrs = var.public_subnet_cidrs
  app_subnet_cidrs    = var.app_subnet_cidrs
  data_subnet_cidrs   = var.data_subnet_cidrs
  num_azs             = var.num_azs
}

module "lambda" {
  source                    = "../../modules/lambda"
  project_name              = var.project_name
  lambda_execution_role_arn = module.iam.lambda_execution_role_arn
  s3_bucket_name            = "${var.project_name}-uploads-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

module "iam" {
  source        = "../../modules/iam"
  project_name  = var.project_name
  s3_bucket_arn = module.lambda.s3_bucket_arn
}

module "alb" {
  source            = "../../modules/alb"
  project_name      = var.project_name
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
}

module "ecs" {
  source                      = "../../modules/ecs"
  project_name                = var.project_name
  aws_region                  = var.aws_region
  vpc_id                      = module.vpc.vpc_id
  app_subnet_ids              = module.vpc.app_subnet_ids
  alb_security_group_id       = module.alb.alb_security_group_id
  ecs_instance_profile_name   = module.iam.ecs_instance_profile_name
  ecs_task_execution_role_arn = module.iam.ecs_task_execution_role_arn
  target_group_a_arn          = module.alb.target_group_a_arn
  target_group_b_arn          = module.alb.target_group_b_arn
}

# --- Outputs ---
output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer."
  value       = module.alb.alb_dns_name
}

output "api_gateway_endpoint" {
  description = "The endpoint URL for the file upload API."
  value       = module.lambda.api_endpoint
}

output "s3_upload_bucket_name" {
  description = "The name of the S3 bucket for uploads."
  value       = module.lambda.s3_bucket_id
}

