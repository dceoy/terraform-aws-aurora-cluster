# trivy:ignore:AVD-AWS-0104
resource "aws_security_group" "rds" {
  name        = "${var.system_name}-${var.env_type}-rds-sg"
  description = "Security group for RDS"
  vpc_id      = var.vpc_id
  ingress {
    description = "Allow all inbound traffic from the security group itself"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }
  ingress {
    description     = "Allow inbound traffic from the ingress security groups"
    from_port       = local.rds_cluster_port
    to_port         = local.rds_cluster_port
    protocol        = "tcp"
    security_groups = var.ingress_security_group_ids
  }
  egress {
    description      = "Allow all outbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name       = "${var.system_name}-${var.env_type}-rds-sg"
    SystemName = var.system_name
    EnvType    = var.env_type
  }
  lifecycle {
    create_before_destroy = true
  }
}

# trivy:ignore:avd-aws-0017
resource "aws_cloudwatch_log_group" "rds" {
  for_each          = toset(var.rds_cluster_enabled_cloudwatch_logs_exports)
  name              = "/aws/rds/cluster/${aws_rds_cluster.db.cluster_identifier}/${each.key}"
  retention_in_days = var.cloudwatch_logs_retention_in_days
  log_group_class   = var.cloudwatch_logs_log_group_class
  kms_key_id        = var.kms_key_arn
  tags = {
    Name       = "/aws/rds/cluster/${aws_rds_cluster.db.cluster_identifier}/${each.key}"
    SystemName = var.system_name
    EnvType    = var.env_type
  }
}

resource "aws_db_subnet_group" "db" {
  name        = "${local.rds_cluster_name}-subnet-group"
  description = "${local.rds_cluster_name}-subnet-group"
  subnet_ids  = var.private_subnet_ids
  tags = {
    Name       = "${local.rds_cluster_name}-subnet-group"
    SystemName = var.system_name
    EnvType    = var.env_type
  }
}

resource "aws_rds_cluster_parameter_group" "db" {
  count       = var.rds_cluster_parameter_group_family != null && length(var.rds_cluster_parameter_group_parameters) > 0 ? 1 : 0
  name_prefix = "${local.rds_cluster_name}-parameter-group-"
  description = "${local.rds_cluster_name}-parameter-group"
  family      = var.rds_cluster_parameter_group_family
  dynamic "parameter" {
    for_each = var.rds_cluster_parameter_group_parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = lookup(parameter.value, "apply_method", "immediate")
    }
  }
  lifecycle {
    create_before_destroy = true
  }
  tags = {
    Name       = "${local.rds_cluster_name}-parameter-group"
    SystemName = var.system_name
    EnvType    = var.env_type
  }
}

resource "aws_db_parameter_group" "db" {
  count       = var.rds_cluster_instance_parameter_group_family != null && length(var.rds_cluster_instance_parameter_group_parameters) > 0 ? 1 : 0
  name_prefix = "${local.rds_cluster_name}-instance-parameter-group-"
  description = "${local.rds_cluster_name}-instance-parameter-group"
  family      = var.rds_cluster_instance_parameter_group_family
  dynamic "parameter" {
    for_each = var.rds_cluster_instance_parameter_group_parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = lookup(parameter.value, "apply_method", "immediate")
    }
  }
  lifecycle {
    create_before_destroy = true
  }
  tags = {
    Name       = "${local.rds_cluster_name}-instance-parameter-group"
    SystemName = var.system_name
    EnvType    = var.env_type
  }
}

# trivy:ignore:AVD-AWS-0077
# trivy:ignore:AVD-AWS-0343
resource "aws_rds_cluster" "db" {
  cluster_identifier                    = local.rds_cluster_name
  engine                                = var.rds_cluster_engine
  engine_mode                           = var.rds_cluster_scalability_type == "limitless" ? "" : var.rds_cluster_engine_mode
  engine_version                        = var.rds_cluster_engine_version
  engine_lifecycle_support              = var.rds_cluster_engine_lifecycle_support
  db_subnet_group_name                  = aws_db_subnet_group.db.name
  vpc_security_group_ids                = [aws_security_group.rds.id]
  port                                  = local.rds_cluster_port
  enabled_cloudwatch_logs_exports       = var.rds_cluster_enabled_cloudwatch_logs_exports
  kms_key_id                            = var.kms_key_arn
  db_cluster_parameter_group_name       = length(aws_rds_cluster_parameter_group.db) > 0 ? aws_rds_cluster_parameter_group.db[0].id : null
  db_instance_parameter_group_name      = length(aws_db_parameter_group.db) > 0 ? aws_db_parameter_group.db[0].id : null
  allocated_storage                     = var.rds_cluster_allocated_storage
  allow_major_version_upgrade           = var.rds_cluster_allow_major_version_upgrade
  apply_immediately                     = var.rds_cluster_apply_immediately
  availability_zones                    = var.rds_cluster_availability_zones
  backtrack_window                      = var.rds_cluster_engine == "aurora-mysql" || var.rds_cluster_engine == "aurora" ? var.rds_cluster_backtrack_window : null
  backup_retention_period               = var.rds_cluster_backup_retention_period
  ca_certificate_identifier             = var.rds_cluster_ca_certificate_identifier
  cluster_scalability_type              = var.rds_cluster_scalability_type
  copy_tags_to_snapshot                 = var.rds_cluster_copy_tags_to_snapshot
  database_insights_mode                = var.rds_cluster_database_insights_mode
  database_name                         = var.rds_cluster_database_name
  db_cluster_instance_class             = var.rds_cluster_db_cluster_instance_class
  delete_automated_backups              = var.rds_cluster_delete_automated_backups
  deletion_protection                   = var.rds_cluster_deletion_protection
  domain                                = var.rds_cluster_domain
  domain_iam_role_name                  = var.rds_cluster_domain_iam_role_name
  enable_http_endpoint                  = var.rds_cluster_enable_http_endpoint
  enable_local_write_forwarding         = var.rds_cluster_enable_local_write_forwarding
  final_snapshot_identifier             = var.rds_cluster_final_snapshot_identifier
  iam_database_authentication_enabled   = var.rds_cluster_iam_database_authentication_enabled
  iam_roles                             = var.rds_cluster_iam_roles
  manage_master_user_password           = true
  master_user_secret_kms_key_id         = var.kms_key_arn
  master_username                       = var.rds_cluster_master_username != null ? var.rds_cluster_master_username : var.system_name
  monitoring_interval                   = var.rds_cluster_monitoring_interval
  monitoring_role_arn                   = length(aws_iam_role.monitoring) > 0 ? aws_iam_role.monitoring[0].arn : null
  network_type                          = var.rds_cluster_network_type
  performance_insights_enabled          = var.rds_cluster_performance_insights_enabled
  performance_insights_kms_key_id       = var.rds_cluster_performance_insights_enabled ? var.kms_key_arn : null
  performance_insights_retention_period = var.rds_cluster_performance_insights_enabled ? var.rds_cluster_performance_insights_retention_period : null
  preferred_backup_window               = var.rds_cluster_preferred_backup_window
  preferred_maintenance_window          = var.rds_cluster_preferred_maintenance_window
  skip_final_snapshot                   = var.rds_cluster_final_snapshot_identifier == null
  storage_encrypted                     = true
  storage_type                          = var.rds_cluster_storage_type
  dynamic "serverlessv2_scaling_configuration" {
    for_each = var.rds_cluster_engine_mode == "provisioned" && (var.rds_cluster_serverlessv2_scaling_configuration_max_capacity != null || var.rds_cluster_serverlessv2_scaling_configuration_min_capacity != null || var.rds_cluster_serverlessv2_scaling_configuration_seconds_until_auto_pause != null) ? [true] : []
    content {
      max_capacity             = var.rds_cluster_serverlessv2_scaling_configuration_max_capacity
      min_capacity             = var.rds_cluster_serverlessv2_scaling_configuration_min_capacity
      seconds_until_auto_pause = var.rds_cluster_serverlessv2_scaling_configuration_seconds_until_auto_pause
    }
  }
  tags = {
    Name       = local.rds_cluster_name
    SystemName = var.system_name
    EnvType    = var.env_type
  }
  lifecycle {
    ignore_changes = [
      cluster_scalability_type,
      engine_version,
      global_cluster_identifier,
      replication_source_identifier,
      snapshot_identifier
    ]
  }
}

resource "aws_iam_role" "monitoring" {
  count                 = var.rds_cluster_monitoring_interval > 0 ? 1 : 0
  name                  = "${var.system_name}-${var.env_type}-rds-cluster-monitoring-iam-role"
  description           = "RDS cluster monitoring IAM role"
  force_detach_policies = var.iam_role_force_detach_policies
  path                  = "/"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowRDSMonitoringToAssumeRole"
        Effect = "Allow"
        Action = ["sts:AssumeRole"]
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })
  tags = {
    Name       = "${var.system_name}-${var.env_type}-rds-cluster-monitoring-iam-role"
    SystemName = var.system_name
    EnvType    = var.env_type
  }
}

resource "aws_iam_role_policy_attachments_exclusive" "monitoring" {
  count       = length(aws_iam_role.monitoring) > 0 ? 1 : 0
  role_name   = aws_iam_role.monitoring[0].name
  policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"]
}

# trivy:ignore:AVD-AWS-0133
resource "aws_rds_cluster_instance" "db" {
  identifier                   = "${local.rds_cluster_name}-instance"
  cluster_identifier           = aws_rds_cluster.db.cluster_identifier
  engine                       = aws_rds_cluster.db.engine
  engine_version               = aws_rds_cluster.db.engine_version_actual
  preferred_maintenance_window = aws_rds_cluster.db.preferred_maintenance_window
  instance_class               = var.rds_cluster_instance_class
  db_subnet_group_name         = aws_db_subnet_group.db.name
  apply_immediately            = var.rds_cluster_apply_immediately
  auto_minor_version_upgrade   = var.rds_cluster_instance_auto_minor_version_upgrade
  copy_tags_to_snapshot        = var.rds_cluster_copy_tags_to_snapshot
  db_parameter_group_name      = length(aws_db_parameter_group.db) > 0 ? aws_db_parameter_group.db[0].id : null
  monitoring_interval          = var.rds_cluster_monitoring_interval
  monitoring_role_arn          = length(aws_iam_role.monitoring) > 0 ? aws_iam_role.monitoring[0].arn : null
  publicly_accessible          = false
  tags = {
    Name       = "${local.rds_cluster_name}-instance"
    SystemName = var.system_name
    EnvType    = var.env_type
  }
  lifecycle {
    ignore_changes = [engine_version]
  }
}

resource "aws_iam_role" "maintenance" {
  name                  = "${var.system_name}-${var.env_type}-rds-cluster-maintenance-iam-role"
  description           = "RDS cluster maintenance IAM role"
  force_detach_policies = var.iam_role_force_detach_policies
  path                  = "/"
  max_session_duration  = var.rds_cluster_maintenance_iam_role_max_session_duration
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowRootAccountToAssumeRole"
        Action = ["sts:AssumeRole"]
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${local.account_id}:root"
        }
      }
    ]
  })
  tags = {
    Name       = "${var.system_name}-${var.env_type}-rds-cluster-maintenance-iam-role"
    SystemName = var.system_name
    EnvType    = var.env_type
  }
}

resource "aws_iam_role_policy" "maintenance" {
  name = "${var.system_name}-${var.env_type}-rds-cluster-maintenance-iam-policy"
  role = aws_iam_role.maintenance.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid      = "AllowRDSDBConnect",
        Effect   = "Allow",
        Action   = ["rds-db:connect"],
        Resource = ["arn:aws:rds-db:${local.region}:${local.account_id}:dbuser:${aws_rds_cluster.db.cluster_identifier}/*"],
      },
      {
        Sid    = "AllowRDSDBDescribe",
        Effect = "Allow",
        Action = [
          "rds:DescribeDBClusters",
          "rds:DescribeDBInstances"
        ],
        Resource = ["arn:aws:rds:${local.region}:${local.account_id}:db:*"],
        Condition = {
          StringEquals = {
            "aws:ResourceTag/SystemName" = var.system_name
            "aws:ResourceTag/EnvType"    = var.env_type
          }
        }
      }
    ]
  })
}

data "aws_secretsmanager_secret" "db" {
  arn = aws_rds_cluster.db.master_user_secret[0].secret_arn
}

data "aws_secretsmanager_secret_version" "db" {
  secret_id = data.aws_secretsmanager_secret.db.id
}

resource "terraform_data" "create_iam_user" {
  count            = var.rds_cluster_database_user_to_create != null ? 1 : 0
  depends_on       = [aws_rds_cluster_instance.db]
  triggers_replace = [aws_rds_cluster.db.endpoint]
  provisioner "local-exec" {
    command = <<-EOT
    mysql \
      --host=${aws_rds_cluster.db.endpoint} \
      --user=${aws_rds_cluster.db.master_username} \
      --password='${jsondecode(data.aws_secretsmanager_secret_version.db.secret_string).password}' \
      --execute="CREATE USER '${var.rds_cluster_database_user_to_create}' IDENTIFIED WITH AWSAuthenticationPlugin AS 'RDS'; GRANT ALL PRIVILEGES ON *.* TO ${var.rds_cluster_database_user_to_create}; FLUSH PRIVILEGES;"
    EOT
  }
}
