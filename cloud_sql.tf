module "viq_psql" {
  source           = "GoogleCloudPlatform/sql-db/google//modules/postgresql"
  version          = "15.1.0"
  project_id       = local.project_id
  name             = "${local.project_id}-db01"
  database_version = "POSTGRES_13"

  region = var.primary_region
  zone   = var.primary_zone

  #tier              = "db-custom-2-7680" #TODO: add machine type
  tier              = var.env == "viq-st-na-s" || var.env == "viq-st-eu-s" ? "db-custom-8-30720" : "db-custom-2-7680"
 
  availability_type = "ZONAL"

  disk_autoresize = true
  disk_size       = 100
  disk_type       = "PD_HDD"

  maintenance_window_day          = 7 #Sunday
  maintenance_window_hour         = 9 #UTC
  maintenance_window_update_track = "stable"
  user_labels = var.country == "eu" ? {
  "orca-rmg-flag" = "true"
} : {}


  database_flags = [
    {
      name  = "cloudsql.iam_authentication"
      value = "on"
    },
    {
      name  = "log_checkpoints"
      value = "on"
    },
    {
      name  = "log_connections"
      value = "on"
    },
    {
      name  = "log_disconnections"
      value = "on"
    },
    {
      name  = "log_duration"
      value = "on"
    },
    {
      name  = "log_error_verbosity"
      value = "default"
    },
    {
      name  = "log_min_duration_statement"
      value = "-1"
    },
    {
      name  = "log_min_error_statement"
      value = "error"
    },
    {
      name  = "log_hostname"
      value = "off"
    },
    {
      name  = "log_parser_stats"
      value = "off"
    },
    {
      name  = "log_planner_stats"
      value = "off"
    },
    {
      name  = "log_statement"
      value = "ddl"
    },
    {
      name  = "log_statement_stats"
      value = "off"
    },
    {
      name  = "log_temp_files"
      value = "0"
    },
    {
      name = "log_lock_waits"
      value = "on"
    },
    {
      name  = "max_connections"
      value = "4096"
    },
    {
      name  = "max_standby_archive_delay"
      value = "30000"
    },
    {
      name = "max_standby_streaming_delay"
      value = "30000"
    },
    {
      name = "cloudsql.logical_decoding"
      value = "on"
    }	
  ]
  deletion_protection = true

  backup_configuration = {
    enabled                        = true
    start_time                     = "17:00"
    location                       = var.location
    point_in_time_recovery_enabled = true
    transaction_log_retention_days = "7"
    retained_backups               = 30
    retention_unit                 = "COUNT"
  }
  ip_configuration = {
    ipv4_enabled        = false
    require_ssl         = true
    private_network     = module.vpc.network_self_link #module.vpc.network_name #TODO: add vpc referred by module
    authorized_networks = []
    allocated_ip_range  = null
  }
  create_timeout      = "30m"
  user_name           = "postgres"
  user_password       = google_secret_manager_secret_version.sm_viq_psql_db01_postgres_usr_pwd_secret_version_basic.secret_data
  encryption_key_name = null

  read_replicas = [
    {
      name             = ""
      database_version = "POSTGRES_13"
      region = var.primary_region
      zone   = var.primary_zone
      #tier              = "db-custom-2-7680" #TODO: add machine type
       tier = local.project_id == "viq-st-na-s" || local.project_id == "viq-st-eu-s" ? "db-custom-8-30720" : "db-custom-2-7680"

      availability_type = "ZONAL"

      disk_autoresize = true
      disk_autoresize_limit = 0
      disk_size       = 528
    # disk_size       = "${var.country == "na" ? 100 : 70}"
      disk_type       = "PD_HDD"

      maintenance_window_day          = 7 #Sunday
      maintenance_window_hour         = 9 #UTC
      maintenance_window_update_track = "stable"

      user_labels = {
        "root" = "root"
      }

      
      database_flags = [
        {
          name  = "cloudsql.iam_authentication"
          value = "on"
        },
        {
          name  = "log_checkpoints"
          value = "on"
        },
        {
          name  = "log_connections"
          value = "on"
        },
        {
          name  = "log_disconnections"
          value = "on"
        },
        {
          name  = "log_duration"
          value = "on"
        },
        {
          name  = "log_error_verbosity"
          value = "default"
        },
        {
          name  = "log_min_duration_statement"
          value = "-1"
        },
        {
          name  = "log_min_error_statement"
          value = "error"
        },
        {
          name  = "log_hostname"
          value = "off"
        },
        {
          name  = "log_parser_stats"
          value = "off"
        },
        {
          name  = "log_planner_stats"
          value = "off"
        },
        {
          name  = "log_statement"
          value = "ddl"
        },
        {
          name  = "log_statement_stats"
          value = "off"
        },
        {
          name  = "log_temp_files"
          value = "0"
        },
        {
          name = "log_lock_waits"
          value = "on"
        },
        {
          name  = "max_connections"
          value = "4096"
        },
        {
          name  = "max_standby_archive_delay"
          value = "30000"
        },
        {
          name = "max_standby_streaming_delay"
          value = "30000"
        },
        {
          name = "cloudsql.logical_decoding"
          value = "on"
        },
      ]
      deletion_protection = true
      backup_configuration = {
        enabled                        = true
        start_time                     = "17:00"
        location                       = "US"
        point_in_time_recovery_enabled = true
        transaction_log_retention_days = "7"
        retained_backups               = 30
        retention_unit                 = "COUNT"
      }
      ip_configuration = {
        ipv4_enabled        = false
        require_ssl         = true
        private_network     = module.vpc.network_self_link #module.vpc.network_name #TODO: add vpc referred by module
        authorized_networks = []
        allocated_ip_range  = null
      }
      create_timeout      = "30m"
      user_name           = "postgres"
      user_password       = google_secret_manager_secret_version.sm_viq_psql_db01_postgres_usr_pwd_secret_version_basic.secret_data
      encryption_key_name = null
    }
  ]
  depends_on = [
    google_service_networking_connection.psc_vpc_private_service_access
  ]
}

resource "google_secret_manager_secret_version" "sm_viq_psql_db01_postgres_usr_pwd_secret_version_basic" {
  secret      = module.sm_viq_psql_db01_postgres_usr_pwd.secret_id
  secret_data = "password" #to be upcycled
  lifecycle {
    # enabled - The current state of the SecretVersion.
    ignore_changes = [enabled]
  }
}

data "google_secret_manager_secret_version" "sm_viq_psql_db01_postgres_usr_pwd_secret_version_basic_data_source" {
  secret = module.sm_viq_psql_db01_postgres_usr_pwd.secret_id
  depends_on = [
    google_secret_manager_secret_version.sm_viq_psql_db01_postgres_usr_pwd_secret_version_basic
  ]
}
############################################################
############ Cloud SQL Primary Instance Certificates #######
############################################################

resource "google_sql_ssl_cert" "viq_psql_primary" {
  project = local.project_id
  common_name = "ovsrefresh"
  instance    = module.viq_psql.instance_name
}

# The actual certificate data for this client certificate.
resource "google_secret_manager_secret_version" "sm_viq_psql_db01_primary_client_cert_pem" {
  secret      = module.sm_viq_psql_db01_primary_client_cert_pem.secret_id
  secret_data = google_sql_ssl_cert.viq_psql_primary.cert
  lifecycle {
    # enabled - The current state of the SecretVersion.
    ignore_changes = [enabled]
  }
}

resource "google_storage_bucket_object" "viq_psql_db01_primary_client_cert_pem" {
  bucket       = module.cloudsql_certs.name
  name         = "certs/${local.project_id}/${var.primary_region}/${module.viq_psql.instance_name}/primary/client-cert.pem"
  content      = google_sql_ssl_cert.viq_psql_primary.cert
  content_type = "application/octet-stream"
  depends_on = [
    module.cloudsql_certs
  ]
}

# The private key associated with the client certificate.
resource "google_secret_manager_secret_version" "sm_viq_psql_db01_primary_client_key_pem" {
  secret      = module.sm_viq_psql_db01_primary_client_key_pem.secret_id
  secret_data = google_sql_ssl_cert.viq_psql_primary.private_key
  lifecycle {
    # enabled - The current state of the SecretVersion.
    ignore_changes = [enabled]
  }
}

data "google_secret_manager_secret_version" "sm_viq_psql_db01_primary_client_key_pem" {
  secret = module.sm_viq_psql_db01_primary_client_key_pem.secret_id
  depends_on = [
    google_secret_manager_secret_version.sm_viq_psql_db01_primary_client_key_pem
  ]
}

resource "google_storage_bucket_object" "viq_psql_db01_primary_client_key_pem" {
  bucket       = module.cloudsql_certs.name
  name         = "certs/${local.project_id}/${var.primary_region}/${module.viq_psql.instance_name}/primary/client-key.pem"
  content      = google_sql_ssl_cert.viq_psql_primary.private_key
  content_type = "application/octet-stream"
  depends_on = [
    module.cloudsql_certs
  ]
}


# The CA cert of the server this client cert was generated from.
resource "google_secret_manager_secret_version" "sm_viq_psql_db01_primary_server_ca_pem" {
  secret      = module.sm_viq_psql_db01_primary_server_ca_pem.secret_id
  secret_data = google_sql_ssl_cert.viq_psql_primary.server_ca_cert
  lifecycle {
    # enabled - The current state of the SecretVersion.
    ignore_changes = [enabled]
  }
}

resource "google_storage_bucket_object" "viq_psql_db01_primary_server_ca_pem" {
  bucket       = module.cloudsql_certs.name
  name         = "certs/${local.project_id}/${var.primary_region}/${module.viq_psql.instance_name}/primary/server-ca.pem"
  content      = google_sql_ssl_cert.viq_psql_primary.server_ca_cert
  content_type = "application/octet-stream"
  depends_on = [
    module.cloudsql_certs
  ]
}
############################################################
############ Cloud SQL Replica Instance Certificates #######
############################################################

resource "google_sql_ssl_cert" "viq_psql_replica" {
  project = local.project_id
  common_name = "ovsrefresh"
  instance    = module.viq_psql.read_replica_instance_names[0]
}

# The actual certificate data for this client certificate.
resource "google_secret_manager_secret_version" "sm_viq_psql_db01_replica_client_cert_pem" {
  secret      = module.sm_viq_psql_db01_replica_client_cert_pem.secret_id
  secret_data = google_sql_ssl_cert.viq_psql_replica.cert
  lifecycle {
    # enabled - The current state of the SecretVersion.
    ignore_changes = [enabled]
  }
}

resource "google_storage_bucket_object" "viq_psql_db01_replica_client_cert_pem" {
  bucket       = module.cloudsql_certs.name
  name         = "certs/${local.project_id}/${var.primary_region}/${module.viq_psql.instance_name}/replica/client-cert.pem"
  content      = google_sql_ssl_cert.viq_psql_replica.cert
  content_type = "application/octet-stream"
  depends_on = [
    module.cloudsql_certs
  ]
}

# The private key associated with the client certificate.
resource "google_secret_manager_secret_version" "sm_viq_psql_db01_replica_client_key_pem" {
  secret      = module.sm_viq_psql_db01_replica_client_key_pem.secret_id
  secret_data = google_sql_ssl_cert.viq_psql_replica.private_key
  lifecycle {
    # enabled - The current state of the SecretVersion.
    ignore_changes = [enabled]
  }
}

data "google_secret_manager_secret_version" "sm_viq_psql_db01_replica_client_key_pem" {
  secret = module.sm_viq_psql_db01_replica_client_key_pem.secret_id
  depends_on = [
    google_secret_manager_secret_version.sm_viq_psql_db01_replica_client_key_pem
  ]
}

resource "google_storage_bucket_object" "viq_psql_db01_replica_client_key_pem" {
  bucket       = module.cloudsql_certs.name
  name         = "certs/${local.project_id}/${var.primary_region}/${module.viq_psql.instance_name}/replica/client-key.pem"
  content      = google_sql_ssl_cert.viq_psql_replica.private_key
  content_type = "application/octet-stream"
  depends_on = [
    module.cloudsql_certs
  ]
}

# The CA cert of the server this client cert was generated from.
resource "google_secret_manager_secret_version" "sm_viq_psql_db01_replica_server_ca_pem" {
  secret      = module.sm_viq_psql_db01_replica_server_ca_pem.secret_id
  secret_data = google_sql_ssl_cert.viq_psql_replica.server_ca_cert
  lifecycle {
    # enabled - The current state of the SecretVersion.
    ignore_changes = [enabled]
  }
}

resource "google_storage_bucket_object" "viq_psql_db01_replica_server_ca_pem" {
  bucket       = module.cloudsql_certs.name
  name         = "certs/${local.project_id}/${var.primary_region}/${module.viq_psql.instance_name}/replica/server-ca.pem"
  content      = google_sql_ssl_cert.viq_psql_replica.server_ca_cert
  content_type = "application/octet-stream"
  depends_on = [
    module.cloudsql_certs
  ]
}
