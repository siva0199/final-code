resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-cluster"

  tags = {
    Name = "${var.project_name}-cluster"
  }
}

resource "aws_security_group" "ecs_sg" {
  name        = "${var.project_name}-ecs-sg"
  description = "Security group for ECS container instances"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [var.alb_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-ecs-sg"
  }
}

data "aws_ami" "ecs_optimized_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }
}

resource "aws_launch_template" "ecs_launch_template" {
  name_prefix   = "${var.project_name}-ecs-"
  image_id      = data.aws_ami.ecs_optimized_ami.id
  instance_type = "t3.small"

  iam_instance_profile {
    name = var.ecs_instance_profile_name
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.ecs_sg.id]
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    echo ECS_CLUSTER=${aws_ecs_cluster.main.name} >> /etc/ecs/ecs.config
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project_name}-ecs-instance"
    }
  }
}

resource "aws_autoscaling_group" "ecs_asg" {
  name                = "${var.project_name}-ecs-asg"
  vpc_zone_identifier = var.app_subnet_ids
  min_size            = 2
  max_size            = 3
  desired_capacity    = 2

  launch_template {
    id      = aws_launch_template.ecs_launch_template.id
    version = "$Latest"
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = true
  }
}

# --- CloudWatch Log Groups ---
resource "aws_cloudwatch_log_group" "nginx_a" {
  name = "/ecs/${var.project_name}/nginx-a"
  tags = {
    Name = "${var.project_name}-log-group-nginx-a"
  }
}

resource "aws_cloudwatch_log_group" "nginx_b" {
  name = "/ecs/${var.project_name}/nginx-b"
  tags = {
    Name = "${var.project_name}-log-group-nginx-b"
  }
}

# --- ECS Task Definitions ---
resource "aws_ecs_task_definition" "nginx_a" {
  family                   = "nginx-a"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = var.ecs_task_execution_role_arn

  container_definitions = jsonencode([
    {
      name      = "nginx-a"
      image     = "nginx:latest"
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
      command = [
        "/bin/sh",
        "-c",
        "echo '<h1>Response from Nginx Service A</h1>' > /usr/share/nginx/html/index.html && nginx -g 'daemon off;'"
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.nginx_a.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "nginx-a"
        }
      }
    }
  ])
}

resource "aws_ecs_task_definition" "nginx_b" {
  family                   = "nginx-b"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = var.ecs_task_execution_role_arn

  container_definitions = jsonencode([
    {
      name      = "nginx-b"
      image     = "nginx:latest"
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
      command = [
        "/bin/sh",
        "-c",
        "echo '<h1>Response from Nginx Service B</h1>' > /usr/share/nginx/html/index.html && nginx -g 'daemon off;'"
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.nginx_b.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "nginx-b"
        }
      }
    }
  ])
}

# --- ECS Services ---
resource "aws_ecs_service" "nginx_a" {
  name            = "nginx-a-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.nginx_a.arn
  desired_count   = 1
  launch_type     = "EC2"

  # This block is required for 'awsvpc' network mode
  network_configuration {
    subnets         = var.app_subnet_ids
    security_groups = [aws_security_group.ecs_sg.id]
  }

  load_balancer {
    target_group_arn = var.target_group_a_arn
    container_name   = "nginx-a"
    container_port   = 80
  }

  # It's good practice to ensure the ASG is ready before the service tries to place tasks
  depends_on = [aws_autoscaling_group.ecs_asg]
}

resource "aws_ecs_service" "nginx_b" {
  name            = "nginx-b-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.nginx_b.arn
  desired_count   = 1
  launch_type     = "EC2"

  # This block is required for 'awsvpc' network mode
  network_configuration {
    subnets         = var.app_subnet_ids
    security_groups = [aws_security_group.ecs_sg.id]
  }

  load_balancer {
    target_group_arn = var.target_group_b_arn
    container_name   = "nginx-b"
    container_port   = 80
  }

  # It's good practice to ensure the ASG is ready before the service tries to place tasks
  depends_on = [aws_autoscaling_group.ecs_asg]
}

