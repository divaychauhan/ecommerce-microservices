variable "aws_region" {
  description = "AWS region for the environment."
  type        = string
  default     = "ap-south-1"
}

variable "aws_profile" {
  description = "AWS CLI profile name. Configure it before running Terraform."
  type        = string
  default     = "ecommerce-dev"
}

variable "project_name" {
  description = "Short project name used in resource names."
  type        = string
  default     = "ecommerce"
}

variable "environment" {
  description = "Environment name."
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  type    = string
  default = "10.20.0.0/16"
}

variable "availability_zones" {
  description = "Use two AZs for this development environment."
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b"]
}

variable "eks_cluster_version" {
  type    = string
  default = "1.32"
}

variable "node_instance_types" {
  type    = list(string)
  default = ["t3.medium"]
}

variable "node_min_size" {
  type    = number
  default = 1
}

variable "node_desired_size" {
  type    = number
  default = 2
}

variable "node_max_size" {
  type    = number
  default = 3
}

variable "db_instance_class" {
  description = "Choose a small supported class for a learning environment."
  type        = string
  default     = "db.t3.micro"
}

variable "db_name" {
  type    = string
  default = "ecommerce"
}

variable "db_username" {
  type    = string
  default = "ecommerce_admin"
}

variable "redis_node_type" {
  type    = string
  default = "cache.t3.micro"
}

variable "enable_nat_gateway" {
  description = "NAT gateways have ongoing hourly and data-processing charges."
  type        = bool
  default     = true
}

variable "enable_rds" {
  type    = bool
  default = true
}

variable "enable_redis" {
  type    = bool
  default = true
}

variable "tags" {
  type    = map(string)
  default = {}
}
