variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "devopstht"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "ACCOUNT_ID" {
  type = string
}

variable "availability_zones" {
  description = "Region AZs"
  type        = list(string)
  default     = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}

variable "public_subnets_cidr" {
  description = "Public Subnets CIDRs"
  type        = list(string)
}

variable "private_subnets_cidr" {
  description = "Private Subnets CIDRs"
  type        = list(string)
}

variable "order_api_image_name" {
  description = "Docker image for Order API"
  type        = string
}

variable "processor_image_name" {
  description = "Docker image for Order Processor"
  type        = string
}
