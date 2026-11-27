output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnets
}

output "private_subnet_ids" {
  value = module.vpc.private_subnets
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "ecr_repository_urls" {
  value = { for service, repo in module.ecr : service => repo.repository_url }
}

output "postgres_endpoint" {
  value     = try(aws_db_instance.postgres[0].address, null)
  sensitive = false
}

output "postgres_secret_arn" {
  value = try(aws_secretsmanager_secret.postgres[0].arn, null)
}

output "redis_primary_endpoint" {
  value = try(aws_elasticache_replication_group.redis[0].primary_endpoint_address, null)
}
