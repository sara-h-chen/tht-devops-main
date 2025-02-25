resource "aws_ecs_cluster" "main" {
  name = "${var.environment}-cluster"

  setting {
    name  = "containerInsights"
    value = "disabled"
  }
}

# ECS SERVICES AND TASK DEFINITIONS HERE
####### ORDER API ########
resource "aws_cloudwatch_log_group" "order_logs" {
  name              = "/ecs/${var.aws_region}/${aws_ecs_cluster.main.name}/order-api"
  retention_in_days = 1
}

resource "aws_ecs_task_definition" "order_api" {
  family             = "order-api"
  task_role_arn      = var.ecs_task_role_arn
  execution_role_arn = var.ecs_execution_role_arn
  network_mode       = "bridge"

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  container_definitions = jsonencode([
    {
      name      = "order-api"
      image     = var.order_api_image
      cpu       = 256
      memory    = 300
      essential = true
      portMappings = [
        {
          name          = "http"
          containerPort = 8000
          hostPort      = 0
        }
      ],
      environment = [
        {
          name  = "ORDERS_TABLE_NAME"
          value = "${var.orders_table_name}"
        },
        {
          name  = "DYNAMODB_TABLE"
          value = "${var.orders_table_name}"
        },
        {
          name  = "AWS_DEFAULT_REGION"
          value = "${var.aws_region}"
        },
        {
          name  = "ORDER_PROCESSOR_URL"
          value = "http://processor-api.${var.environment}.internal"
        }
      ],
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/${var.aws_region}/${aws_ecs_cluster.main.name}/order-api"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "order-api"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "order_api" {
  cluster                       = aws_ecs_cluster.main.id
  name                          = "order-api"
  task_definition               = aws_ecs_task_definition.order_api.arn
  desired_count                 = 1
  availability_zone_rebalancing = "ENABLED"
  force_new_deployment          = true

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.main.name
    weight            = 100
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.order_api.arn
    container_name   = "order-api"
    container_port   = 8000
  }

  service_connect_configuration {
    enabled   = true
    namespace = aws_service_discovery_private_dns_namespace.main.arn
    service {
      discovery_name = "order-api"
      port_name      = "http"
      client_alias {
        dns_name = "order-api.${var.environment}.internal"
        port     = 80
      }
    }
  }
  depends_on = [aws_autoscaling_group.ecs]
}

####### ORDER PROCESSOR API ########
resource "aws_cloudwatch_log_group" "processor_logs" {
  name              = "/ecs/${var.aws_region}/${aws_ecs_cluster.main.name}/processor-api"
  retention_in_days = 1
}

resource "aws_ecs_task_definition" "processor_api" {
  family             = "processor-api"
  task_role_arn      = var.ecs_task_role_arn
  execution_role_arn = var.ecs_execution_role_arn
  network_mode       = "bridge"

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  container_definitions = jsonencode([
    {
      name      = "processor-api"
      image     = var.processor_image
      cpu       = 256
      memory    = 300
      essential = true
      portMappings = [
        {
          name          = "http"
          hostPort      = 0
          containerPort = 8000
        }
      ],
      environment = [
        {
          name  = "INVENTORY_TABLE_NAME"
          value = "${var.inventory_table_name}"
        },
        {
          name  = "DYNAMODB_TABLE"
          value = "${var.inventory_table_name}"
        },
        {
          name  = "AWS_DEFAULT_REGION"
          value = "${var.aws_region}"
        }
      ],
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/${var.aws_region}/${aws_ecs_cluster.main.name}/processor-api"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "processor-api"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "processor_api" {
  cluster                       = aws_ecs_cluster.main.id
  name                          = "processor-api"
  task_definition               = aws_ecs_task_definition.processor_api.arn
  desired_count                 = 1
  availability_zone_rebalancing = "ENABLED"
  force_new_deployment          = true

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.main.name
    weight            = 100
  }

  service_connect_configuration {
    enabled   = true
    namespace = aws_service_discovery_private_dns_namespace.main.arn
    service {
      discovery_name = "processor-api"
      port_name      = "http"
      client_alias {
        dns_name = "processor-api.${var.environment}.internal"
        port     = 80
      }
    }
  }
  depends_on = [aws_autoscaling_group.ecs]
}