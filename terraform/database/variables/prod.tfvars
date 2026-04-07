project_id            = "ditto-prod"
environment           = "prod"
region                = "europe-west2"
platform_state_bucket = "ditto-tf-state-prod"
platform_state_prefix = "components/platform/prod"

db_availability_type              = "REGIONAL"
db_backup_enabled                 = true
db_pitr_enabled                   = true
db_transaction_log_retention_days = 7
db_deletion_protection            = true
