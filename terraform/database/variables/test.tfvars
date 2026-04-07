project_id            = "ditto-test"
environment           = "test"
region                = "europe-west2"
platform_state_bucket = "ditto-tf-state-test"
platform_state_prefix = "components/platform/test"

db_availability_type              = "ZONAL"
db_backup_enabled                 = true
db_pitr_enabled                   = true
db_transaction_log_retention_days = 3
db_deletion_protection            = false
