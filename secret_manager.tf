# psql root user password
module "sm_viq_psql_db01_postgres_usr_pwd" {
  source                = "./custom_modules/secret_manager"
  secret_id             = "sm-${local.project_id}-psql-db01-postgres-usr-pwd"
  project_id            = local.project_id
  replication_locations = [
    var.primary_region 
  ]
}

module "sm_viq_auth_secret" {
  source                = "./custom_modules/secret_manager"
  secret_id             = "sm-${local.project_id}-auth-secret"
  project_id            = local.project_id
  replication_locations = [
    var.primary_region
  ]
  members = [
    "serviceAccount:${module.sa_viq_cloud_run.email}",
  ]
}
module "sm_viq_db01_ovsrefresh_usr_pwd" {
  source                = "./custom_modules/secret_manager"
  secret_id             = "sm-${local.project_id}-db01-ovsrefresh-usr-pwd"
  project_id            = local.project_id
  replication_locations = [
    var.primary_region
  ]
  members = [
    "serviceAccount:${module.sa_viq_cloud_run.email}",
    
  ]
}
module "sm_viq_es_ovsr_application_usr_pwd" {
  source                = "./custom_modules/secret_manager"
  secret_id             = "sm-${local.project_id}-es-ovsr-application-usr-pwd"
  project_id            = local.project_id
  replication_locations = [
    var.primary_region 
  ]
  members = [
    "serviceAccount:${module.sa_viq_cloud_run.email}",
  ]
}

module "sm_viq_cms_api_secret" {
  source                = "./custom_modules/secret_manager"
  secret_id             = "sm-${local.project_id}-cms-api-secret"
  project_id            = local.project_id
  replication_locations = [
    var.primary_region
  ]
  members = [
    "serviceAccount:${module.sa_viq_cloud_run.email}",
  ]
}

module "sm_viq_strapicms_usr_pwd" {
  source                = "./custom_modules/secret_manager"
  secret_id             = "sm-${local.project_id}-strapicms-usr-pwd"
  project_id            = local.project_id
  replication_locations = [
    var.primary_region
  ]
  members = [
    "serviceAccount:${module.sa_viq_cloud_run.email}",
  ]
}

module "sm_com_zebra_ovs_email_access_key" {
  source                = "./custom_modules/secret_manager"
  secret_id             = "sm-${local.project_id}-email-access-key"
  project_id            = local.project_id
  replication_locations = [
    var.primary_region
  ]
  members = [
    "serviceAccount:${module.sa_viq_cloud_run.email}",
   
  ]
}

############################################################
############ Cloud SQL Primary Instance Certificates #######
############################################################

module "sm_viq_psql_db01_primary_client_cert_pem" {
  source                = "./custom_modules/secret_manager"
  secret_id             = "sm-${local.project_id}-psql-db01-primary-client-cert-pem"
  project_id            = local.project_id
  replication_locations = [
    var.primary_region
  ]
  members = [
    "serviceAccount:${module.sa_viq_cloud_run.email}",
    "serviceAccount:${module.sa_viq_cloudfunction.email}",
  ]
}
module "sm_viq_psql_db01_primary_client_key_pem" {
  source                = "./custom_modules/secret_manager"
  secret_id             = "sm-${local.project_id}-psql-db01-primary-client-key-pem"
  project_id            = local.project_id
  replication_locations = [
    var.primary_region
  ]
  members = [
    "serviceAccount:${module.sa_viq_cloud_run.email}",
    "serviceAccount:${module.sa_viq_cloudfunction.email}",
  ]
}

module "sm_viq_psql_db01_primary_server_ca_pem" {
  source                = "./custom_modules/secret_manager"
  secret_id             = "sm-${local.project_id}-psql-db01-primary-server-ca-pem"
  project_id            = local.project_id
  replication_locations = [
    var.primary_region
  ]
  members = [
    "serviceAccount:${module.sa_viq_cloud_run.email}",
    "serviceAccount:${module.sa_viq_cloudfunction.email}",
  ]
}
############################################################
############ Cloud SQL Replica Instance Certificates #######
############################################################

module "sm_viq_psql_db01_replica_client_cert_pem" {
  source                = "./custom_modules/secret_manager"
  secret_id             = "sm-${local.project_id}-psql-db01-replica-client-cert-pem"
  project_id            = local.project_id
  replication_locations = [
    var.primary_region
  ]
  members = [
    "serviceAccount:${module.sa_viq_cloud_run.email}",
  ]
}
module "sm_viq_psql_db01_replica_client_key_pem" {
  source                = "./custom_modules/secret_manager"
  secret_id             = "sm-${local.project_id}-psql-db01-replica-client-key-pem"
  project_id            = local.project_id
  replication_locations = [
    var.primary_region
  ]
  members = [
    "serviceAccount:${module.sa_viq_cloud_run.email}",
  ]
}

module "sm_viq_psql_db01_replica_server_ca_pem" {
  source                = "./custom_modules/secret_manager"
  secret_id             = "sm-${local.project_id}-psql-db01-replica-server-ca-pem"
  project_id            = local.project_id
  replication_locations = [
    var.primary_region 
  ]
  members = [
    "serviceAccount:${module.sa_viq_cloud_run.email}",
  ]
}

module "sm_viq_pg_ovsrobu_url" {
  source                = "./custom_modules/secret_manager"
  secret_id             = "sm-${local.project_id}-pg-ovsrobu-url"
  project_id            = local.project_id
  replication_locations = [
    var.primary_region 
  ]
  members = [
    "serviceAccount:${module.sa_viq_cloudfunction.email}",
  ]
}

##############################################
######### Composer Environment Secrets #######
##############################################

locals {
  p_region = var.primary_region == "us-central1" ? "usc1" : "euw1"
  p_env = var.env == "d" ? "dev" : "test"
}
module "sm_airflow_variables_es_and_pg_credentials" {
  source                = "./custom_modules/secret_manager"
  secret_id             = "airflow-variables-es-and-pg-credentials-${local.p_region}-${local.p_env}"
  project_id            = local.project_id
  replication_locations = [
    var.primary_region
  ]
  members = [
    "serviceAccount:${module.sa_viq_composer.email}"
  ]
}

##############################################
######### SAML Environment Secrets #######
##############################################

module "sm_viq_saml_cert" {
  source                = "./custom_modules/secret_manager"
  secret_id             = "sm-${local.project_id}-saml-cert"
  project_id            = local.project_id
  replication_locations = [
    var.primary_region
  ]
  members = [
    "serviceAccount:${module.sa_viq_cloud_run.email}",
    
  ]
}

module "sm_viq_saml_key" {
  source                = "./custom_modules/secret_manager"
  secret_id             = "sm-${local.project_id}-saml-key"
  project_id            = local.project_id
  replication_locations = [
    var.primary_region
  ]
  members = [
    "serviceAccount:${module.sa_viq_cloud_run.email}",
    
  ]
}

##############################################
######### DATALAKE API Secrets #######
##############################################

module "sm_datalake_api_key" {
  source                = "./custom_modules/secret_manager"
  secret_id             = "sm-${local.project_id}-datalake-api-key"
  project_id            = local.project_id
  replication_locations = [
    var.primary_region
  ]
  members = [
    "serviceAccount:${module.sa_viq_cloud_run.email}",
    
  ]
}

module "sm_common_datalake_api_key" {
  source                = "./custom_modules/secret_manager"
  secret_id             = "sm-${local.project_id}-common-datalake-apikey"
  project_id            = local.project_id
  replication_locations = [
    var.primary_region
  ]
  members = [
    "serviceAccount:${module.sa_viq_cloud_run.email}",
    
  ]
}
module "key_for_savanna_stage_api_load_testing" {
  source                = "./custom_modules/secret_manager"
  secret_id             = "sm-${local.project_id}-stage-common-datalake-apikey"
  project_id            = local.project_id
  replication_locations = [
    var.primary_region
  ]
  members = [
    "serviceAccount:${module.sa_viq_cloud_run.email}",
    
  ]
}