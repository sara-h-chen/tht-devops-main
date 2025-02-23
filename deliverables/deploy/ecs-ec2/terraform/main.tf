module "vpc" {
  source = "./modules/vpc"

  environment = var.environment

  vpc_name             = "${var.environment}-vpc"
  vpc_cidr             = var.vpc_cidr
  private_subnet_cidrs = var.private_subnets_cidr
  public_subnet_cidrs  = var.public_subnets_cidr

}

module "iam" {
  source = "./modules/iam"

  environment = var.environment

  orders_table_arn    = module.dynamodb.orders_table_arn
  inventory_table_arn = module.dynamodb.inventory_table_arn

  order_api_repo_arn       = data.terraform_remote_state.supporting_infra.outputs.order_api_repository_arn
  order_processor_repo_arn = data.terraform_remote_state.supporting_infra.outputs.order_processor_repository_arn
}

module "ecs" {
  source      = "./modules/ecs"
  environment = var.environment

  vpc_id          = module.vpc.vpc_id
  public_subnets  = module.vpc.public_subnets
  private_subnets = module.vpc.private_subnets

  alb_security_group_id = module.security.alb_security_group_id
  ecs_security_group_id = module.security.ecs_task_security_group_id

  order_api_image = "${var.ACCOUNT_ID}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.order_api_image_name}"
  processor_image = "${var.ACCOUNT_ID}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.processor_image_name}"

  ecs_execution_role_arn = module.iam.ecs_execution_role_arn
  ecs_task_role_arn      = module.iam.ecs_task_role_arn

  inventory_table_name = module.dynamodb.inventory_table_name
  orders_table_name    = module.dynamodb.orders_table_name

  depends_on = [module.vpc]
}


module "vpc_endpoints" {
  source = "./modules/vpc_endpoints"

  vpc_id                  = module.vpc.vpc_id
  private_subnets         = module.vpc.private_subnets
  private_route_table_ids = module.vpc.private_route_table_ids
  ecs_security_group_id   = module.security.ecs_task_security_group_id
}

module "dynamodb" {
  source = "./modules/dynamodb"

  environment = var.environment
}


module "security" {
  source = "./modules/security"

  environment = var.environment

  vpc_id = module.vpc.vpc_id

  depends_on = [module.vpc]
}
