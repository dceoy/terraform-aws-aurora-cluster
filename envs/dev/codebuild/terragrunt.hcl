include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

dependency "kms" {
  config_path = "../kms"
  mock_outputs = {
    kms_key_arn = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

dependency "s3" {
  config_path = "../s3"
  mock_outputs = {
    io_s3_bucket_id   = "mock-s3-io-s3-bucket-id"
    s3_iam_policy_arn = "arn:aws:iam::123456789012:policy/mock-s3-iam-policy-arn"
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    vpc_id = "vpc-12345678"
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

dependency "subnet" {
  config_path = "../subnet"
  mock_outputs = {
    private_subnet_ids        = ["subnet-12345678", "subnet-87654321"]
    private_security_group_id = "sg-12345678"
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

dependency "aurora" {
  config_path = "../aurora"
  mock_outputs = {
    rds_cluster_port                          = 3306
    rds_cluster_endpoint                      = "mock-cluster.cluster-123456789012.us-east-1.rds.amazonaws.com"
    rds_cluster_reader_endpoint               = "mock-cluster.cluster-ro-123456789012.us-east-1.rds.amazonaws.com"
    rds_cluster_instance_endpoint             = "mock-cluster-instance.cluster-123456789012.us-east-1.rds.amazonaws.com"
    rds_cluster_maintenance_iam_policy_arn    = "arn:aws:iam::123456789012:policy/mock-aurora-iam-policy-arn"
    rds_cluster_secretsmanager_secret_arns    = ["arn:aws:secretsmanager:us-east-1:123456789012:secret:mock-aurora-db-secret-arn-1"]
    rds_cluster_secretsmanager_iam_policy_arn = "arn:aws:iam::123456789012:policy/mock-aurora-secretsmanager-iam-policy-arn"
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

inputs = {
  kms_key_arn                             = include.root.inputs.create_kms_key ? dependency.kms.outputs.kms_key_arn : null
  codebuild_logs_config_s3_logs_bucket_id = dependency.s3.outputs.io_s3_bucket_id
  codebuild_iam_policy_arns = [
    dependency.aurora.outputs.rds_cluster_maintenance_iam_policy_arn,
    dependency.aurora.outputs.rds_cluster_secretsmanager_iam_policy_arn,
    dependency.s3.outputs.s3_iam_policy_arn,
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
  ]
  codebuild_environment_environment_variables = {
    "SYSTEM_NAME"                            = include.root.inputs.system_name
    "ENV_TYPE"                               = include.root.inputs.env_type
    "RDS_CLUSTER_DATABASE_NAME"              = include.root.inputs.rds_cluster_database_name
    "RDS_CLUSTER_SECRETS_MANAGER_SECRET_ARN" = dependency.aurora.outputs.rds_cluster_secretsmanager_secret_arns[0]
    "RDS_CLUSTER_PORT"                       = dependency.aurora.outputs.rds_cluster_port
    "RDS_CLUSTER_ENDPOINT"                   = dependency.aurora.outputs.rds_cluster_endpoint
    "RDS_CLUSTER_READER_ENDPOINT"            = dependency.aurora.outputs.rds_cluster_reader_endpoint
    "RDS_CLUSTER_INSTANCE_ENDPOINT"          = dependency.aurora.outputs.rds_cluster_instance_endpoint
  }
  codebuild_vpc_config_vpc_id             = dependency.vpc.outputs.vpc_id
  codebuild_vpc_config_subnets            = dependency.subnet.outputs.private_subnet_ids
  codebuild_vpc_config_security_group_ids = [dependency.subnet.outputs.private_security_group_id]
}

terraform {
  source = "git::https://github.com/dceoy/terraform-aws-codebuild-for-s3.git//modules/codebuild?ref=main"
}
