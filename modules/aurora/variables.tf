variable "system_name" {
  description = "System name"
  type        = string
}

variable "env_type" {
  description = "Environment type"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs"
  type        = list(string)
}

variable "ingress_security_group_ids" {
  description = "Ingress security group IDs"
  type        = list(string)
  default     = []
}

variable "kms_key_arn" {
  description = "KMS key ARN"
  type        = string
  default     = null
}

variable "cloudwatch_logs_retention_in_days" {
  description = "CloudWatch Logs retention in days"
  type        = number
  default     = 30
  validation {
    condition     = contains([0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.cloudwatch_logs_retention_in_days)
    error_message = "CloudWatch Logs retention in days must be 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653 or 0 (zero indicates never expire logs)"
  }
}

variable "cloudwatch_logs_log_group_class" {
  description = "CloudWatch Logs log group class"
  type        = string
  default     = "STANDARD"
  validation {
    condition     = contains(["STANDARD", "INFREQUENT_ACCESS"], var.cloudwatch_logs_log_group_class)
    error_message = "CloudWatch Logs log group class must be STANDARD or INFREQUENT_ACCESS"
  }
}

variable "iam_role_force_detach_policies" {
  description = "Whether to force detaching any IAM policies the IAM role has before destroying it"
  type        = bool
  default     = true
}

variable "rds_cluster_engine" {
  description = "RDS cluster database engine"
  type        = string
  default     = "aurora-postgresql"
  validation {
    condition     = contains(["aurora-postgresql", "aurora-mysql"], var.rds_cluster_engine)
    error_message = "RDS cluster engine must be aurora-postgresql or aurora-mysql"
  }
}

variable "rds_cluster_engine_mode" {
  description = "RDS cluster database engine mode"
  type        = string
  default     = "provisioned"
  validation {
    condition     = contains(["global", "parallelquery", "provisioned", ""], var.rds_cluster_engine_mode)
    error_message = "RDS cluster engine mode must be global, parallelquery, provisioned, or empty"
  }
}

variable "rds_cluster_engine_version" {
  description = "RDS cluster database engine version (updating this argument results in an outage)"
  type        = string
  default     = null
}

variable "rds_cluster_engine_lifecycle_support" {
  description = "RDS cluster database engine life cycle type for a DB instance"
  type        = string
  default     = "open-source-rds-extended-support"
  validation {
    condition     = contains(["open-source-rds-extended-support", "open-source-rds-extended-support-disabled"], var.rds_cluster_engine_lifecycle_support)
    error_message = "RDS cluster engine lifecycle support must be open-source-rds-extended-support or open-source-rds-extended-support-disabled"
  }
}

variable "rds_cluster_parameter_group_family" {
  description = "Parameter group family for the RDS cluster"
  type        = string
  default     = null
}

variable "rds_cluster_parameter_group_parameters" {
  description = "List of the parameters to apply for the RDS cluster"
  type        = list(map(string))
  default     = []
  validation {
    condition     = alltrue([for m in var.rds_cluster_parameter_group_parameters : alltrue([for k in keys(m) : contains(["name", "value", "apply_method"], k)])])
    error_message = "RDS cluster parameter group parameters allow only name, value, and apply_method as keys"
  }
}

variable "rds_cluster_instance_parameter_group_family" {
  description = "Parameter group family for the RDS cluster instances"
  type        = string
  default     = null
}

variable "rds_cluster_instance_parameter_group_parameters" {
  description = "List of the parameters to apply for the RDS cluster instances"
  type        = list(map(string))
  default     = []
  validation {
    condition     = alltrue([for m in var.rds_cluster_instance_parameter_group_parameters : alltrue([for k in keys(m) : contains(["name", "value", "apply_method"], k)])])
    error_message = "RDS cluster instance parameter group parameters allow only name, value, and apply_method as keys"
  }
}

variable "rds_cluster_enabled_cloudwatch_logs_exports" {
  description = "RDS cluster log types to export to CloudWatch Logs"
  type        = list(string)
  default     = ["audit", "error", "general", "slowquery"]
  validation {
    condition     = alltrue([for x in var.rds_cluster_enabled_cloudwatch_logs_exports : contains(["audit", "error", "general", "slowquery", "postgresql"], x)])
    error_message = "RDS cluster enabled cloudwatch logs exports must be audit, error, general, slowquery or postgresql"
  }
}

variable "rds_cluster_allocated_storage" {
  description = "Allocated storage in GiB for the multi-AZ RDS cluster"
  type        = number
  default     = null
}

variable "rds_cluster_allow_major_version_upgrade" {
  description = "Whether to allow major engine version upgrades when changing engine versions"
  type        = bool
  default     = false
}

variable "rds_cluster_apply_immediately" {
  description = "Whether to apply any cluster modifications immediately, or during the next maintenance window"
  type        = bool
  default     = false
}

variable "rds_cluster_availability_zones" {
  description = "List of EC2 Availability Zones for the RDS cluster storage where RDS cluster instances can be created"
  type        = list(string)
  default     = null
}

variable "rds_cluster_backtrack_window" {
  description = "Target backtrack window in seconds for the RDS cluster (only for aurora-mysql and aurora engines)"
  type        = number
  default     = 0
  validation {
    condition     = var.rds_cluster_backtrack_window >= 0 && var.rds_cluster_backtrack_window <= 259200
    error_message = "RDS cluster backtrack window must be between 0 and 259200 (72 hours)"
  }
}

variable "rds_cluster_backup_retention_period" {
  description = "Days to retain backups for in the RDS cluster"
  type        = number
  default     = 1
}

variable "rds_cluster_ca_certificate_identifier" {
  description = "CA certificate identifier to use for the multi-AZ RDS cluster's server certificate"
  type        = string
  default     = null
}

variable "rds_cluster_scalability_type" {
  description = "Scalability mode of the Aurora RDS cluster"
  type        = string
  default     = "standard"
  validation {
    condition     = contains(["limitless", "standard"], var.rds_cluster_scalability_type)
    error_message = "RDS cluster scalability type must be limitless or standard"
  }
}

variable "rds_cluster_copy_tags_to_snapshot" {
  description = "Whether to copy all RDS cluster tags to snapshots"
  type        = bool
  default     = false
}

variable "rds_cluster_database_insights_mode" {
  description = "Database Insights mode to enable for the RDS cluster"
  type        = string
  default     = null
  validation {
    condition     = var.rds_cluster_database_insights_mode == null || contains(["standard", "advanced"], var.rds_cluster_database_insights_mode)
    error_message = "RDS cluster database insights mode must be standard or advanced"
  }
}

variable "rds_cluster_db_cluster_instance_class" {
  description = "Compute and memory capacity of each DB instance in the multi-AZ RDS cluster (e.g., db.m6g.xlarge)"
  type        = string
  default     = null
}

variable "rds_cluster_delete_automated_backups" {
  description = "Whether to remove automated backups immediately after the RDS cluster is deleted"
  type        = bool
  default     = true
}

variable "rds_cluster_deletion_protection" {
  description = "Whether to enable deletion protection for the RDS cluster"
  type        = bool
  default     = false
}

variable "rds_cluster_domain" {
  description = "ID of the Directory Service Active Directory domain to create the instance in for the RDS cluster"
  type        = string
  default     = null
}

variable "rds_cluster_domain_iam_role_name" {
  description = "IAM role name to be used when making API calls to the Directory Service for the RDS cluster (required if domain is provided)"
  type        = string
  default     = null
}

variable "rds_cluster_enable_local_write_forwarding" {
  description = "Whether to enable local write forwarding for the RDS cluster"
  type        = bool
  default     = null
}

variable "rds_cluster_enable_http_endpoint" {
  description = "Whether to enable HTTP endpoint (data API) for the RDS cluster"
  type        = bool
  default     = null
}

variable "rds_cluster_final_snapshot_identifier" {
  description = "Name of the final snapshot when the RDS cluster is deleted"
  type        = string
  default     = null
}

variable "rds_cluster_iam_database_authentication_enabled" {
  description = "Whether to enable IAM database authentication for the RDS cluster"
  type        = bool
  default     = null
}

variable "rds_cluster_iops" {
  description = "Amount of provisioned IOPS (input/output operations per second) to be initially allocated for each DB instance in the multi-AZ RDS cluster"
  type        = number
  default     = null
  validation {
    condition     = var.rds_cluster_iops == null || (var.rds_cluster_iops >= 0.5 && var.rds_cluster_iops <= 50)
    error_message = "RDS cluster IOPS must be a multiple between .5 and 50"
  }
}

variable "rds_cluster_master_username" {
  description = "Master DB user name for the RDS cluster"
  type        = string
  default     = null
}

variable "rds_cluster_monitoring_interval" {
  description = "Interval in seconds between points when Enhanced Monitoring metrics are collected for the RDS cluster"
  type        = number
  default     = 0
  validation {
    condition     = contains([0, 1, 5, 10, 15, 30, 60], var.rds_cluster_monitoring_interval)
    error_message = "RDS cluster monitoring interval must be 0, 1, 5, 10, 15, 30, or 60"
  }
}

variable "rds_cluster_network_type" {
  description = "Network type of the RDS cluster"
  type        = string
  default     = null
  validation {
    condition     = var.rds_cluster_network_type == null || contains(["IPV4", "DUAL"], var.rds_cluster_network_type)
    error_message = "RDS cluster network type must be IPV4 or DUAL"
  }
}

variable "rds_cluster_performance_insights_enabled" {
  description = "Whether to enable Performance Insights for the RDS cluster"
  type        = bool
  default     = null
}

variable "rds_cluster_performance_insights_retention_period" {
  description = "Amount of time to retain Performance Insights data of the RDS cluster for"
  type        = number
  default     = null
  validation {
    condition     = var.rds_cluster_performance_insights_retention_period == null || var.rds_cluster_performance_insights_retention_period == 7 || var.rds_cluster_performance_insights_retention_period == 731 || (var.rds_cluster_performance_insights_retention_period % 31 == 0 && var.rds_cluster_performance_insights_retention_period >= 31 && var.rds_cluster_performance_insights_retention_period <= 713)
    error_message = "RDS cluster performance insights retention period must be 7, 731, or a multiple of 31 between 31 and 713"
  }
}

variable "rds_cluster_preferred_backup_window" {
  description = "Daily time range in UTC during which automated backups are created for the RDS cluster (default: a 30-minute window selected at random from an 8-hour block of time per region, e.g. 04:00-09:00)"
  type        = string
  default     = null
}

variable "rds_cluster_preferred_maintenance_window" {
  description = "Weekly time range in UTC during which system maintenance can occur for the RDS cluster (e.g., wed:04:00-wed:04:30)"
  type        = string
  default     = null
}

variable "rds_cluster_storage_type" {
  description = "Storage type to be associated with the RDS cluster"
  type        = string
  default     = null
  validation {
    condition     = var.rds_cluster_storage_type == null || contains(["aurora-iopt1", "io1", "io2", ""], var.rds_cluster_storage_type)
    error_message = "RDS cluster storage type must be aurora-iopt1, io1, io2, or empty"
  }
}
variable "rds_cluster_serverlessv2_scaling_configuration_max_capacity" {
  description = "Minimum capacity for the Aurora Serverless v2 DB cluster in provisioned DB engine mode"
  type        = number
  default     = null
  validation {
    condition     = var.rds_cluster_serverlessv2_scaling_configuration_max_capacity == null || (var.rds_cluster_serverlessv2_scaling_configuration_max_capacity >= 0 && var.rds_cluster_serverlessv2_scaling_configuration_max_capacity <= 256 && var.rds_cluster_serverlessv2_scaling_configuration_max_capacity % 0.5 == 0)
    error_message = "RDS cluster serverlessv2 scaling configuration max capacity must be between 0 and 256 in steps of 0.5"
  }
}

variable "rds_cluster_serverlessv2_scaling_configuration_min_capacity" {
  description = "Maximum capacity for the Aurora Serverless v2 DB cluster in provisioned DB engine mode"
  type        = number
  default     = null
  validation {
    condition     = var.rds_cluster_serverlessv2_scaling_configuration_min_capacity == null || (var.rds_cluster_serverlessv2_scaling_configuration_min_capacity >= 0 && var.rds_cluster_serverlessv2_scaling_configuration_min_capacity <= 256 && var.rds_cluster_serverlessv2_scaling_configuration_min_capacity % 0.5 == 0)
    error_message = "RDS cluster serverlessv2 scaling configuration min capacity must be between 0 and 256 in steps of 0.5"
  }
}

variable "rds_cluster_serverlessv2_scaling_configuration_seconds_until_auto_pause" {
  description = "Time in seconds before the Aurora Serverless v2 DB cluster in provisioned DB engine mode is paused"
  type        = number
  default     = null
  validation {
    condition     = var.rds_cluster_serverlessv2_scaling_configuration_seconds_until_auto_pause == null || (var.rds_cluster_serverlessv2_scaling_configuration_seconds_until_auto_pause >= 300 && var.rds_cluster_serverlessv2_scaling_configuration_seconds_until_auto_pause <= 86400)
    error_message = "RDS cluster serverlessv2 scaling configuration seconds until auto pause must be between 300 and 86400"
  }
}

variable "rds_cluster_instance_class" {
  description = "Instance type to use at master instance for the RDS cluster"
  type        = string
  default     = "db.serverless"
}

variable "rds_cluster_instance_auto_minor_version_upgrade" {
  description = "Whether to enable automatic minor engine upgrades for the RDS cluster instances during the maintenance window"
  type        = bool
  default     = true
}
