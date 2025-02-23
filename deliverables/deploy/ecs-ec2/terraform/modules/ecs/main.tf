resource "aws_ecs_cluster" "main" {
  name = "${var.environment}-cluster"

  setting {
    name  = "containerInsights"
    value = "disabled"
  }
}

# ECS SERVICES AND TASK DEFINITIONS HERE
####### ORDER API ########
resource "aws_ecs_task_definition" "order_api" {
  family             = "${var.environment}-order-api"
  task_role_arn      = var.ecs_task_role_arn
  execution_role_arn = var.ecs_execution_role_arn
  network_mode       = "awsvpc"

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  container_definitions = jsonencode([
    {
      "name" : "order-api",
      "image" : var.order_api_image,
      "memory" : 200,
      "cpu" : 1,
      "essential" : true
    }
  ])
}

resource "aws_ecs_service" "order_api" {
  cluster                       = aws_ecs_cluster.main.id
  name                          = "${var.environment}-order-api"
  task_definition               = aws_ecs_task_definition.order_api.arn
  desired_count                 = 2
  availability_zone_rebalancing = "ENABLED"

  force_new_deployment = true
  placement_constraints {
    type = "distinctInstance"
  }

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
    enabled = true
  }
  depends_on = [aws_autoscaling_group.ecs]
}

####### ORDER PROCESSOR API ########
resource "aws_ecs_task_definition" "processor_api" {
  family             = "${var.environment}-processor-api"
  task_role_arn      = var.ecs_task_role_arn
  execution_role_arn = var.ecs_execution_role_arn
  network_mode       = "awsvpc"

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  container_definitions = jsonencode([
    {
      "name" : "processor-api",
      "image" : var.processor_image,
      "memory" : 200,
      "cpu" : 1,
      "essential" : true
    }
  ])
}

resource "aws_ecs_service" "processor_api" {
  cluster                       = aws_ecs_cluster.main.id
  name                          = "${var.environment}-processor-api"
  task_definition               = aws_ecs_task_definition.processor_api.arn
  desired_count                 = 2
  availability_zone_rebalancing = "ENABLED"

  force_new_deployment = true
  placement_constraints {
    type = "distinctInstance"
  }

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.main.name
    weight            = 100
  }

  service_connect_configuration {
    enabled = true
  }
  depends_on = [aws_autoscaling_group.ecs]
}