data aws_secretsmanager_secret configs {
  name = var.secret_manager_name
}

data aws_secretsmanager_secret_version configs{
  secret_id = data.aws_secretsmanager_secret.configs.id
}

# Creating an ECS task definition
resource aws_ecs_task_definition task {
  family                   = "backend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  memory                   = 256
  execution_role_arn       = aws_iam_role.execution_role.arn


  container_definitions = jsonencode([
    {
      name: "backend",
      image: var.image,
      essential: true,
      # entryPoint: ["python", "-m", "gunicorn", "-c", "app/gunicorn_config.py", "app.main:app"]
      environment: [
        {
          "name": "PORT",
          "value": "8000"
        },
        {
          "name": "CORS_ORIGINS",
          "value": jsondecode(data.aws_secretsmanager_secret_version.configs.secret_string)["CORS_ORIGINS"]
        },
        {
          "name": "PYTHONPATH",
          "value": "."
        },
        {
          "name": "DB_USER",
          "value": jsondecode(data.aws_secretsmanager_secret_version.configs.secret_string)["DATABASE_USERNAME"]
        },
        {
          "name": "DB_PASSWORD",
          "value": jsondecode(data.aws_secretsmanager_secret_version.configs.secret_string)["DATABASE_PASSWORD"]
        },
        {
          "name": "DB_HOST",
          "value": jsondecode(data.aws_secretsmanager_secret_version.configs.secret_string)["DATABASE_HOST"]
        },
        {
          "name": "DB_NAME",
          "value": jsondecode(data.aws_secretsmanager_secret_version.configs.secret_string)["DATABASE_NAME"]
        },
        {
          "name": "DATABASE_URL",
          "value": jsondecode(data.aws_secretsmanager_secret_version.configs.secret_string)["DATABASE_URL"]
        },
        {
          "name": "VOYAGE_API_KEY",
          "value": jsondecode(data.aws_secretsmanager_secret_version.configs.secret_string)["VOYAGE_API_KEY"]
        },
        {
          "name": "CLERK_SECRET_KEY",
          "value": jsondecode(data.aws_secretsmanager_secret_version.configs.secret_string)["CLERK_SECRET_KEY"]
        },
        {
          "name": "PINECONE_API_KEY",
          "value": jsondecode(data.aws_secretsmanager_secret_version.configs.secret_string)["PINECONE_API_KEY"]
        },
      ]
      logConfiguration: {
        logDriver: "awslogs",
        options: {
          "awslogs-group": aws_cloudwatch_log_group.log_group.name,
          "awslogs-region": "eu-central-1",
          "awslogs-stream-prefix": "ecs-backend"
        }
      },
      portMappings: [
        {
          containerPort: 8000,
          hostPort: 8000,
        },
      ],
    },
  ])
}

resource aws_service_discovery_service backend {
  name = "backend"
  dns_config {
    namespace_id = var.namespace_id
    dns_records {
      ttl = 10
      type = "A"
    }
  }
}

resource "aws_cloudwatch_log_group" "log_group" {
  name = "ecs-web-application-demo-backend"
  retention_in_days = 14
}

# Creating an ECS service
resource "aws_ecs_service" "service" {
  name             = "service"
  cluster          = var.cluster_id
  task_definition  = aws_ecs_task_definition.task.arn
  desired_count    = 1
  launch_type      = "EC2"

  network_configuration {
    security_groups  = [var.security_group_id]
    subnets          = var.vpc_public_subnets
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.test.arn
    container_name   = "backend"
    container_port   = 8000
  }

  service_registries {
    registry_arn = aws_service_discovery_service.backend.arn
    container_name = "backend"
  }

  lifecycle {
    ignore_changes = [task_definition]
  }

  depends_on = [ aws_lb_target_group.test ]
}

resource "aws_lb" "test" {
  name               = "backend-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [ var.security_group_id ]
  subnets            = var.vpc_public_subnets

  tags = {
    Environment = "production"
  }
}

resource "aws_lb_listener" "test" {
  load_balancer_arn = aws_lb.test.arn
  port = "80"
  protocol = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.test.arn
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.test.arn
  port = "443"
  protocol = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-2016-08"
  certificate_arn = var.certificate_arn
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.test.arn
  }
}

resource "aws_lb_target_group" "test" {
  name = "alb-tg"
  port = 8000
  protocol = "HTTP"
  vpc_id = var.vpc_id
  target_type = "ip"

  health_check {
    path = "/"
    protocol = "HTTP"
    port = "traffic-port"
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    interval = 30
  }
}
