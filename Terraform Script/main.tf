# Provider configuration with region as a variable
provider "aws" {
  region     = var.aws_region
  
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  token      = var.aws_session_token
}

# Variables
variable "aws_access_key" {
  type    = string
  default = ""
}

variable "aws_secret_key" {
  type    = string
  default = ""
}

variable "aws_session_token" {
  type    = string
  default = ""
}

variable "aws_region" {
  type    = string
  default = "us-west-2"
}

variable "aws_account_id" {
  type    = string
  description = "AWS Account ID"
}

variable "vpc_id" {
  type    = string
  default = ""
}

variable "subnet_id_a" {
  type    = string
  default = ""
}

variable "subnet_id_b" {
  type    = string
  default = ""
}

variable "subnet_id_c" {
  type    = string
  default = ""
}

variable "subnet_id_d" {
  type    = string
  default = ""
}

variable "security_group_id" {
  type    = string
  default = ""
}

# Data source to get the default VPC if no VPC ID is provided
data "aws_vpc" "selected" {
  id = var.vpc_id != "" ? var.vpc_id : data.aws_vpc.default.id
}

data "aws_vpc" "default" {
  default = true
}

# Data source to get default subnets in the VPC if no subnet IDs are provided
data "aws_subnets" "selected" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
}

data "aws_subnet" "default_subnet_a" {
  id = var.subnet_id_a != "" ? var.subnet_id_a : data.aws_subnets.selected.ids[0]
}

data "aws_subnet" "default_subnet_b" {
  id = var.subnet_id_b != "" ? var.subnet_id_b : data.aws_subnets.selected.ids[1]
}

data "aws_subnet" "default_subnet_c" {
  id = var.subnet_id_c != "" ? var.subnet_id_c : data.aws_subnets.selected.ids[2]
}

data "aws_subnet" "default_subnet_d" {
  id = var.subnet_id_d != "" ? var.subnet_id_d : data.aws_subnets.selected.ids[3]
}

# Data source to get the default security group if no security group ID is provided
data "aws_security_group" "default" {
  vpc_id = data.aws_vpc.selected.id
  filter {
    name   = "group-name"
    values = ["default"]
  }
}

data "aws_security_group" "selected" {
  id = var.security_group_id != "" ? var.security_group_id : data.aws_security_group.default.id
}

# S3 Bucket
resource "aws_s3_bucket" "my_bucket" {
  bucket = "your-bucket-unique-name"

  tags = {
    Name = "your-bucket-tag-name"
  }
}

# S3 Bucket ACL
resource "aws_s3_bucket_acl" "my_bucket_acl" {
  bucket = aws_s3_bucket.my_bucket.id

  acl = "public-read"
}

# S3 Bucket Policy
resource "aws_s3_bucket_policy" "my_bucket_policy" {
  bucket = aws_s3_bucket.my_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadForAllObjects"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "arn:aws:s3:::${aws_s3_bucket.my_bucket.bucket}/assets/*"
      },
      {
        Sid       = "AllowCloudFrontAccess",
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "arn:aws:s3:::${aws_s3_bucket.my_bucket.bucket}/*",
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = "arn:aws:cloudfront::${var.aws_account_id}:distribution/${aws_cloudfront_distribution.my_distribution.id}"
          }
        }
      }
    ]
  })
}

# S3 Bucket CORS Configuration
resource "aws_s3_bucket_cors_configuration" "my_bucket_cors" {
  bucket = aws_s3_bucket.my_bucket.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT", "POST", "DELETE", "HEAD"]
    allowed_origins = [
      "https://your.domain.com"
    ]
    expose_headers = ["Authorization", "X-XSRF-TOKEN", "XSRF-TOKEN", "Set-Cookie"]
    max_age_seconds = 3000
  }
}

# CloudFront Origin Access Control (OAC)
resource "aws_cloudfront_origin_access_control" "my_oac" {
  name                              = "MyOAC"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# CloudFront Cache Policy
resource "aws_cloudfront_cache_policy" "custom_ui_policy" {
  name = "CustomUIPolicy-unique-12345"

  parameters_in_cache_key_and_forwarded_to_origin {
    headers_config {
      header_behavior = "whitelist"
      headers {
        items = ["Origin", "Access-Control-Request-Method", "api-key", "Access-Control-Request-Headers", "X-XSRF-TOKEN", "Referer"]
      }
    }

    cookies_config {
      cookie_behavior = "all"
    }

    query_strings_config {
      query_string_behavior = "all"
    }
  }

  default_ttl = 3600
  max_ttl     = 86400
  min_ttl     = 0
}

# CloudFront Origin Request Policy
resource "aws_cloudfront_origin_request_policy" "custom_origin_policy" {
  name = "CustomOriginPolicy-unique-12345"

  headers_config {
    header_behavior = "whitelist"
    headers {
      items = ["Origin", "Access-Control-Request-Method", "api-key", "Access-Control-Request-Headers", "X-XSRF-TOKEN", "Referer"]
    }
  }

  cookies_config {
    cookie_behavior = "all"
  }

  query_strings_config {
    query_string_behavior = "all"
  }
}

# CloudFront Response Headers Policy
resource "aws_cloudfront_response_headers_policy" "custom_response_policy" {
  name = "CustomResponsePolicy-unique-12345"

  cors_config {
    access_control_allow_credentials = true
    access_control_allow_headers {
      items = ["Origin", "Content-Type", "Accept", "Authorization", "X-XSRF-TOKEN", "X-Requested-With", "Access-Control-Request-Method", "Access-Control-Request-Headers"]
    }
    access_control_allow_methods {
      items = ["OPTIONS", "DELETE", "POST", "PUT", "GET"]
    }
    access_control_allow_origins {
      items = ["https://your.domain.com"]
    }
    access_control_expose_headers {
      items = ["Origin", "Content-Type", "Accept", "Authorization", "Access-Control-Allow-Origin", "Access-Control-Allow-Credentials", "X-XSRF-TOKEN"]
    }
    origin_override = true
  }
}

# CloudFront Distribution
resource "aws_cloudfront_distribution" "my_distribution" {
  origin {
    domain_name = aws_s3_bucket.my_bucket.bucket_regional_domain_name
    origin_id   = "S3-my_bucket"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_control.my_oac.id
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_cache_behavior {
    target_origin_id       = "S3-my_bucket"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods  = ["GET", "HEAD", "OPTIONS"]

    cache_policy_id = aws_cloudfront_cache_policy.custom_ui_policy.id
    origin_request_policy_id = aws_cloudfront_origin_request_policy.custom_origin_policy.id
    response_headers_policy_id = aws_cloudfront_response_headers_policy.custom_response_policy.id

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_100"

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name = "YourCloudFrontDistributionTag"
  }
}

# Load Balancer
resource "aws_lb" "alb" {
  name               = "yourLBName"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [data.aws_security_group.selected.id]
  subnets            = [
    data.aws_subnet.default_subnet_a.id,
    data.aws_subnet.default_subnet_b.id,
    data.aws_subnet.default_subnet_c.id,
    data.aws_subnet.default_subnet_d.id
  ]

  enable_deletion_protection = false

  tags = {
    Name = "yourLBTag"
  }
}

# Target Group
resource "aws_lb_target_group" "ecs_tg" {
  name       = "ecs-target-group-name"
  port       = 80
  protocol   = "HTTP"
  vpc_id     = data.aws_vpc.selected.id
  target_type = "ip"

  health_check {
    path     = "/"
    protocol = "HTTP"
  }

  tags = {
    Name = "ecs-target-group-tag"
  }
}

# Listener - Switch to HTTP temporarily
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_tg.arn
  }
}

# ECS Cluster
resource "aws_ecs_cluster" "my_cluster" {
  name = "yourClusterName"
}

# ECS Task Definition
resource "aws_ecs_task_definition" "my_task" {
  family                   = "ecsTaskDefinitionName"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1024"
  memory                   = "2048"
  execution_role_arn       = "your task execution role arn"

  container_definitions = <<DEFINITION
[
  {
    "name": "containerStoreRepository",
    "image": "docker-user-name/your-repo-name",
    "repositoryCredentials": {
      "credentialsParameter": "yourAwssecretArnForDockerCredentials"
    },
    "cpu": 1024,
    "portMappings": [
      {
        "name": "5000",
        "containerPort": 5000,
        "hostPort": 5000,
        "protocol": "tcp",
        "appProtocol": "http"
      }
    ],
    "essential": true,
    "startTimeout": 120,
    "stopTimeout": 30,
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/ecs/yourTaskDefinitionName",
        "awslogs-create-group": "true",
        "awslogs-region": "${var.aws_region}",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }
]
DEFINITION

  runtime_platform {
    cpu_architecture       = "X86_64"
    operating_system_family = "LINUX"
  }

  tags = {
    Name = "yourTaskDefinitionName"
  }
}

# ECS Service
resource "aws_ecs_service" "my_service" {
  name            = "yourClusterServiceName"
  cluster         = aws_ecs_cluster.my_cluster.id
  task_definition = aws_ecs_task_definition.my_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [
      data.aws_subnet.default_subnet_a.id,
      data.aws_subnet.default_subnet_b.id,
      data.aws_subnet.default_subnet_c.id,
      data.aws_subnet.default_subnet_d.id
    ]
    security_groups  = [data.aws_security_group.selected.id]
    assign_public_ip = true
  }

  health_check_grace_period_seconds = 3600

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_tg.arn
    container_name   = "containerStoreRepository"
    container_port   = 5000
  }

  tags = {
    Name = "yourClusterServiceName"
  }
}
