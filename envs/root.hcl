locals {
  repo_root   = get_repo_root()
  env_vars    = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  ecr_address = "${local.env_vars.locals.account_id}.dkr.ecr.${local.env_vars.locals.region}.amazonaws.com"
}

terraform {
  extra_arguments "parallelism" {
    commands = get_terraform_commands_that_need_parallelism()
    arguments = [
      "-parallelism=16"
    ]
  }
}

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket       = local.env_vars.locals.terraform_s3_bucket
    key          = "${basename(local.repo_root)}/${local.env_vars.locals.system_name}/${path_relative_to_include()}/terraform.tfstate"
    region       = local.env_vars.locals.region
    encrypt      = true
    use_lockfile = true
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
  provider "aws" {
    region = "${local.env_vars.locals.region}"
    default_tags {
      tags = {
        SystemName = "${local.env_vars.locals.system_name}"
        EnvType    = "${local.env_vars.locals.env_type}"
      }
    }
  }
  EOF
}

catalog {
  urls = [
    "github.com/dceoy/terraform-aws-vpc-for-slc"
  ]
}

inputs = {
  system_name                                                             = local.env_vars.locals.system_name
  env_type                                                                = local.env_vars.locals.env_type
  create_kms_key                                                          = true
  kms_key_deletion_window_in_days                                         = 30
  kms_key_rotation_period_in_days                                         = 365
  create_io_s3_bucket                                                     = true
  create_awslogs_s3_bucket                                                = true
  create_s3logs_s3_bucket                                                 = true
  s3_force_destroy                                                        = true
  s3_noncurrent_version_expiration_days                                   = 7
  s3_abort_incomplete_multipart_upload_days                               = 7
  s3_expired_object_delete_marker                                         = true
  vpc_cidr_block                                                          = "10.0.0.0/16"
  vpc_secondary_cidr_blocks                                               = []
  cloudwatch_logs_retention_in_days                                       = 30
  cloudwatch_logs_log_group_class                                         = "STANDARD"
  private_subnet_count                                                    = 2
  public_subnet_count                                                     = 0
  subnet_newbits                                                          = 8
  vpc_interface_endpoint_services                                         = ["rds"]
  iam_role_force_detach_policy                                            = true
  rds_cluster_engine                                                      = "aurora-mysql"
  rds_cluster_engine_version                                              = "8.0.mysql_aurora.3.08.1"
  rds_cluster_engine_mode                                                 = "provisioned"
  rds_cluster_engine_lifecycle_support                                    = "open-source-rds-extended-support"
  rds_cluster_enabled_cloudwatch_logs_exports                             = ["audit", "error", "general", "slowquery"]
  rds_cluster_allow_major_version_upgrade                                 = false
  rds_cluster_apply_immediately                                           = true
  rds_cluster_backtrack_window                                            = 0
  rds_cluster_backup_retention_period                                     = 0
  rds_cluster_scalability_type                                            = "standard"
  rds_cluster_copy_tags_to_snapshot                                       = true
  rds_cluster_database_insights_mode                                      = "standard"
  rds_cluster_delete_automated_backups                                    = true
  rds_cluster_deletion_protection                                         = false
  rds_cluster_enable_local_write_forwarding                               = false
  rds_cluster_enable_http_endpoint                                        = true
  rds_cluster_iam_database_authentication_enabled                         = true
  rds_cluster_master_username                                             = local.env_vars.locals.system_name
  rds_cluster_monitoring_interval                                         = 60
  rds_cluster_network_type                                                = "IPV4"
  rds_cluster_performance_insights_enabled                                = true
  rds_cluster_performance_insights_retention_period                       = 7
  rds_cluster_preferred_backup_window                                     = "02:00-03:00"
  rds_cluster_preferred_maintenance_window                                = "sun:05:00-sun:06:00"
  rds_cluster_storage_type                                                = ""
  rds_cluster_serverlessv2_scaling_configuration_max_capacity             = 1.0
  rds_cluster_serverlessv2_scaling_configuration_min_capacity             = 0.0
  rds_cluster_serverlessv2_scaling_configuration_seconds_until_auto_pause = 3600
  rds_cluster_instance_class                                              = "db.serverless"
  rds_cluster_instance_auto_minor_version_upgrade                         = true
}
