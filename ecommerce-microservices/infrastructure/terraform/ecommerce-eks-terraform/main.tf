locals {
  name = "${var.project_name}-${var.environment}"

  services = toset([
    "user-service",
    "product-service",
    "cart-service",
    "order-service",
    "payment-service",
    "inventory-service",
    "notification-service"
  ])

  common_tags = merge(var.tags, {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  })

  az_count = length(var.availability_zones)
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.19"

  name = "${local.name}-vpc"
  cidr = var.vpc_cidr

  azs = var.availability_zones

  private_subnets = [
    for index in range(local.az_count) : cidrsubnet(var.vpc_cidr, 4, index)
  ]

  public_subnets = [
    for index in range(local.az_count) : cidrsubnet(var.vpc_cidr, 8, 100 + index)
  ]

  enable_nat_gateway     = var.enable_nat_gateway
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/${local.name}-eks" = "shared"
  }

  tags = local.common_tags
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.37"

  cluster_name    = "${local.name}-eks"
  cluster_version = var.eks_cluster_version

  cluster_endpoint_public_access           = true
  cluster_endpoint_public_access_cidrs     = ["0.0.0.0/0"]
  cluster_endpoint_private_access          = true
  enable_cluster_creator_admin_permissions = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    general = {
      name           = "${local.name}-nodes"
      instance_types = var.node_instance_types
      min_size       = var.node_min_size
      max_size       = var.node_max_size
      desired_size   = var.node_desired_size
      capacity_type  = "ON_DEMAND"
    }
  }

  tags = local.common_tags
}

module "ecr" {
  source  = "terraform-aws-modules/ecr/aws"
  version = "~> 2.3"

  for_each = local.services

  repository_name                 = "${local.name}/${each.value}"
  repository_image_tag_mutability = "IMMUTABLE"

  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep the latest 30 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 30
        }
        action = { type = "expire" }
      }
    ]
  })

  tags = local.common_tags
}

resource "random_password" "postgres" {
  count   = var.enable_rds ? 1 : 0
  length  = 24
  special = false
}

resource "aws_security_group" "rds" {
  count       = var.enable_rds ? 1 : 0
  name        = "${local.name}-rds-sg"
  description = "PostgreSQL access from the EKS node security group"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "PostgreSQL from EKS nodes"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [module.eks.node_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}

resource "aws_db_subnet_group" "postgres" {
  count      = var.enable_rds ? 1 : 0
  name       = "${local.name}-postgres-subnets"
  subnet_ids = module.vpc.private_subnets
  tags       = local.common_tags
}

resource "aws_db_instance" "postgres" {
  count                  = var.enable_rds ? 1 : 0
  identifier             = "${local.name}-postgres"
  engine                 = "postgres"
  engine_version         = "16"
  instance_class         = var.db_instance_class
  allocated_storage      = 20
  max_allocated_storage  = 50
  storage_type           = "gp3"
  storage_encrypted      = true
  db_name                = var.db_name
  username               = var.db_username
  password               = random_password.postgres[0].result
  db_subnet_group_name   = aws_db_subnet_group.postgres[0].name
  vpc_security_group_ids = [aws_security_group.rds[0].id]
  publicly_accessible    = false
  multi_az               = false
  backup_retention_period = 1
  deletion_protection    = false
  skip_final_snapshot    = true
  apply_immediately      = true

  tags = local.common_tags
}

resource "aws_secretsmanager_secret" "postgres" {
  count                   = var.enable_rds ? 1 : 0
  name                    = "${local.name}/postgres/admin"
  recovery_window_in_days = 7
  tags                    = local.common_tags
}

resource "aws_secretsmanager_secret_version" "postgres" {
  count     = var.enable_rds ? 1 : 0
  secret_id = aws_secretsmanager_secret.postgres[0].id
  secret_string = jsonencode({
    engine   = "postgres"
    host     = aws_db_instance.postgres[0].address
    port     = 5432
    dbname   = var.db_name
    username = var.db_username
    password = random_password.postgres[0].result
  })
}

resource "aws_security_group" "redis" {
  count       = var.enable_redis ? 1 : 0
  name        = "${local.name}-redis-sg"
  description = "Redis access from EKS nodes"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "Redis from EKS nodes"
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [module.eks.node_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}

resource "aws_elasticache_subnet_group" "redis" {
  count      = var.enable_redis ? 1 : 0
  name       = "${local.name}-redis-subnets"
  subnet_ids = module.vpc.private_subnets
}

resource "aws_elasticache_replication_group" "redis" {
  count                      = var.enable_redis ? 1 : 0
  replication_group_id       = "${local.name}-redis"
  description                = "Cart service Redis cache"
  engine                     = "redis"
  node_type                  = var.redis_node_type
  num_cache_clusters         = 1
  port                       = 6379
  parameter_group_name       = "default.redis7"
  subnet_group_name          = aws_elasticache_subnet_group.redis[0].name
  security_group_ids         = [aws_security_group.redis[0].id]
  automatic_failover_enabled = false
  at_rest_encryption_enabled = true
  transit_encryption_enabled = true
  apply_immediately          = true
  tags                       = local.common_tags
}
