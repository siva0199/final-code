# DevOps / IaC Production Demo on AWS with Terraform

This project demonstrates a small, production-ready infrastructure on AWS, provisioned entirely using Terraform. It showcases best practices for modular Infrastructure as Code (IaC), including networking, container orchestration, load balancing, serverless APIs, and security.

## Table of Contents
- [Architecture Overview](#architecture-overview)
- [Key Features](#key-features)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Deployment Instructions](#deployment-instructions)
- [Testing and Verification (Proof of Deployment)](#testing-and-verification-proof-of-deployment)
- [Security Considerations](#security-considerations)
- [CI/CD Pipeline](#cicd-pipeline)
- [Cleanup](#cleanup)

## Architecture Overview

The infrastructure is designed to be secure, scalable, and resilient. It consists of a custom VPC with multiple subnets, an ECS cluster for containerized services, an Application Load Balancer for traffic distribution, and a serverless API for file uploads.

```
graph TD
    subgraph "AWS Cloud (us-east-1)"
        subgraph "VPC (10.0.0.0/16)"
            subgraph "Public Subnets"
                ALB[Application Load Balancer]
            end

            subgraph "Private App Subnets"
                ECS_Cluster[ECS Cluster - EC2 Instances]
                ECS_Service_A[Nginx Service A]
                ECS_Service_B[Nginx Service B]
            end

            subgraph "Private Data Subnets"
                NAT[NAT Gateway]
            end

            APIGW[API Gateway HTTP API] --> Lambda[Python Lambda]
            Lambda --> S3[S3 Bucket]
        end

        User --> ALB
        ALB -- Round-Robin --> ECS_Service_A
        ALB -- Round-Robin --> ECS_Service_B

        User -- /upload --> APIGW
    end

    style S3 fill:#f2b447
    style Lambda fill:#f58535
    style APIGW fill:#ff4f8b
    style ECS_Cluster fill:#2e73b8
```

## Key Features

- **Modular Terraform Code**: Infrastructure is defined in reusable modules (`vpc`, `iam`, `ecs`, `alb`, `lambda`).
- **Secure Networking**: A custom VPC with public subnets for external-facing resources (ALB) and private subnets for internal services (ECS instances).
- **Container Orchestration**: An ECS cluster running on an EC2 Auto Scaling Group hosts two distinct `nginx` services.
- **Load Balancing**: An Application Load Balancer performs round-robin traffic distribution between the two `nginx` services.
- **Serverless API**: A secure file upload endpoint using API Gateway and a Python Lambda function to store objects in a private S3 bucket.
- **Least Privilege Security**: Fine-grained IAM roles and Security Groups are implemented to ensure services only have the permissions they need.
- **Observability**: All container and Lambda logs are centralized in CloudWatch Logs for monitoring and debugging.
- **Automation**: A GitHub Actions workflow validates the Terraform code on every push and pull request.

## Project Structure
```
.
├── .github/workflows/terraform.yml  # GitHub Actions CI workflow
├── environments/demo/               # Root module for the 'demo' environment
│   ├── main.tf
│   ├── providers.tf
│   ├── terraform.tfvars
│   └── variables.tf
├── modules/                         # Reusable Terraform modules
│   ├── alb/
│   ├── ecs/
│   ├── iam/
│   ├── lambda/
│   │   └── src/upload_handler.py    # Lambda function source code
│   └── vpc/
└── README.md
```

## Prerequisites

- [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) (v1.x or later)
- [AWS CLI](https://aws.amazon.com/cli/)
- An AWS account with configured credentials and permissions to create the resources.

## Deployment Instructions

1.  **Clone the Repository**:
    ```
    git clone <your-repo-url>
    cd <your-repo-url>
    ```

2.  **Navigate to the Demo Environment**:
    All commands must be run from the `environments/demo` directory.
    ```
    cd environments/demo
    ```

3.  **Initialize Terraform**:
    This command downloads the necessary provider plugins and initializes the backend.
    ```
    terraform init
    ```

4.  **Review the Execution Plan**:
    This dry-run command shows what resources Terraform will create.
    ```
    terraform plan
    ```

5.  **Apply the Configuration**:
    This command builds and deploys all the resources. You will be prompted to confirm.
    ```
    terraform apply
    ```
    Upon completion, Terraform will output the DNS name for the load balancer and the invoke URL for the API endpoint.

## Testing and Verification (Proof of Deployment)

### 1. Test ALB Round-Robin Routing

The ALB is configured to distribute traffic evenly between `nginx-a` and `nginx-b`. The `curl` loop below demonstrates this behavior.

**Command:**
```
ALB_DNS=$(terraform output -raw alb_dns_name)
for i in {1..10}; do curl -s http://${ALB_DNS}/ | grep -o 'Nginx Service [A-B]'; sleep 1; done
```

**Output Snippet:**
```
Nginx Service B
Nginx Service A
Nginx Service B
Nginx Service A
Nginx Service A
...
```

### 2. Test File Upload API

Create a sample file and `POST` it to the `/upload` endpoint.

**Command:**
```
API_ENDPOINT=$(terraform output -raw api_gateway_endpoint)
echo "This is a test file for the S3 upload." > sample.txt
curl -X POST --data-binary "@sample.txt" -H "Content-Type: text/plain" "${API_ENDPOINT}/upload"
```
**Output Snippet:**
```
{"message":"File uploaded successfully!","bucket":"iac-demo-uploads-xxxxxxxx","key":"uploads/2025-09-20-XX-XX-XX-sample.txt"}
```

### 3. Verify File in S3 Bucket

The uploaded file can be viewed in the S3 bucket via the AWS Management Console.

**Screenshot of S3 Bucket:**

<!-- YOUR SCREENSHOT OF THE S3 BUCKET CONTENTS GOES HERE -->
<!-- Example: ![S3 Upload Verification](https://user-images.githubusercontent.com/xxxx/xxxx-xxxx.png) -->


### 4. Verify Logs in CloudWatch

All service logs are streamed to CloudWatch for observability.

**Screenshot of ECS `nginx-a` Log Group:**

<!-- YOUR SCREENSHOT OF THE ECS LOGS GOES HERE -->


**Screenshot of Lambda `upload-handler` Log Group:**

<!-- YOUR SCREENSHOT OF THE LAMBDA LOGS GOES HERE -->


## Security Considerations

- **IAM Least Privilege**: Each component (ECS Task, EC2 Instance, Lambda) has a dedicated IAM role with the minimum required permissions. For example, the Lambda function can only perform `s3:PutObject` on the specific target bucket.
- **Network Segmentation**: Security Groups are used to control traffic flow. The ECS instances only accept traffic from the ALB, and the ALB only accepts public HTTP traffic.
- **No Hardcoded Secrets**: The architecture avoids hardcoded secrets. The GitHub Actions workflow assumes that AWS credentials are provided securely via repository secrets.

## CI/CD Pipeline

This repository includes a GitHub Actions workflow defined in `.github/workflows/terraform.yml`. This CI pipeline is triggered on every `push` and `pull_request` to the `main` branch and performs the following checks:
- `terraform fmt -check`: Ensures all Terraform code is correctly formatted.
- `terraform validate`: Checks the syntax and configuration of the Terraform files.

## Cleanup

To avoid ongoing charges, destroy all the resources created by this project by running the following command from the `environments/demo` directory:

```
terraform destroy
```
You will be prompted to confirm the deletion of all resources.
```
