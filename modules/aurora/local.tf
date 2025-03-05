locals {
  rds_cluster_port = var.rds_cluster_engine == "aurora-postgresql" || var.rds_cluster_engine == "postgres" ? 5432 : 3306
  rds_cluster_name = "${var.system_name}-${var.env_type}-${var.rds_cluster_engine}-cluster"
}
