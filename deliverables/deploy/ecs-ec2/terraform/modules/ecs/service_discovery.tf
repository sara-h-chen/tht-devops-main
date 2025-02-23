resource "aws_service_discovery_private_dns_namespace" "main" {
  name        = "${var.environment}.internal"
  vpc         = var.vpc_id
  description = "Private DNS namespace for service discovery"
}

# TODO: Use AWS Service Connect to allow ECS tasks to resolve DNS names in the private namespace
resource "aws_service_discovery_service" "main" {
  name = "main"
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.main.id
    dns_records {
      ttl  = 10
      type = "A"
    }
  }
  health_check_custom_config {
    failure_threshold = 1
  }
}