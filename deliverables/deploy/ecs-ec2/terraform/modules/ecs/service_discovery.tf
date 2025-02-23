resource "aws_service_discovery_private_dns_namespace" "main" {
  name        = "${var.environment}.internal"
  vpc         = var.vpc_id
  description = "Private DNS namespace for service discovery"
}