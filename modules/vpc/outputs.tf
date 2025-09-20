output "vpc_id" {
  description = "The ID of the VPC."
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "List of IDs of public subnets."
  value       = aws_subnet.public[*].id
}

output "app_subnet_ids" {
  description = "List of IDs of private application subnets."
  value       = aws_subnet.app[*].id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC."
  value       = aws_vpc.main.cidr_block
}

