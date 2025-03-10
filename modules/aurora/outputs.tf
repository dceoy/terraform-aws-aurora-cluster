output "rds_cluster_security_group_id" {
  description = "RDS cluster security group ID"
  value       = aws_security_group.rds.id
}

output "rds_cluster_cloudwatch_logs_log_group_names" {
  description = "RDS cluster CloudWatch Logs log group names"
  value       = { for k, v in aws_cloudwatch_log_group.rds : k => v.name }
}

output "rds_cluster_subnet_group_id" {
  description = "RDS cluster subnet group ID"
  value       = aws_db_subnet_group.db.id
}

output "rds_cluster_parameter_group_id" {
  description = "RDS cluster parameter group ID"
  value       = length(aws_rds_cluster_parameter_group.db) > 0 ? aws_rds_cluster_parameter_group.db[0].id : null
}

output "rds_cluster_instance_parameter_group_id" {
  description = "RDS cluster instance parameter group ID"
  value       = length(aws_db_parameter_group.db) > 0 ? aws_db_parameter_group.db[0].id : null
}

output "rds_cluster_monitoring_iam_role_arn" {
  description = "RDS cluster monitoring IAM role ARN"
  value       = length(aws_iam_role.monitoring) > 0 ? aws_iam_role.monitoring[0].arn : null
}

output "rds_cluster_identifier" {
  description = "RDS cluster identifier"
  value       = aws_rds_cluster.db.cluster_identifier
}

output "rds_cluster_resource_id" {
  description = "RDS cluster resource ID"
  value       = aws_rds_cluster.db.cluster_resource_id
}

output "rds_cluster_database_name" {
  description = "RDS cluster database name"
  value       = aws_rds_cluster.db.database_name
}

output "rds_cluster_members" {
  description = "RDS cluster members"
  value       = aws_rds_cluster.db.cluster_members
}

output "rds_cluster_endpoint" {
  description = "RDS cluster endpoint"
  value       = aws_rds_cluster.db.endpoint
}

output "rds_cluster_reader_endpoint" {
  description = "RDS cluster reader endpoint"
  value       = aws_rds_cluster.db.reader_endpoint
}

output "rds_cluster_engine" {
  description = "RDS cluster engine"
  value       = aws_rds_cluster.db.engine
}

output "rds_cluster_engine_version_actual" {
  description = "RDS cluster engine version"
  value       = aws_rds_cluster.db.engine_version_actual
}

output "rds_cluster_availability_zones" {
  description = "RDS cluster availability zones"
  value       = aws_rds_cluster.db.availability_zones
}

output "rds_cluster_instance_identifier" {
  description = "RDS cluster instance identifier"
  value       = aws_rds_cluster_instance.db.identifier
}

output "rds_cluster_instance_writer" {
  description = "Whether the RDS cluster instance is a writer"
  value       = aws_rds_cluster_instance.db.writer
}

output "rds_cluster_instance_availability_zone" {
  description = "RDS cluster instance availability zone"
  value       = aws_rds_cluster_instance.db.availability_zone
}

output "rds_cluster_maintenance_iam_role_arn" {
  description = "RDS cluster maintenance IAM role ARN"
  value       = aws_iam_role.maintenance.arn
}
