#########################################
##########3 dataproc-initializations ####
#########################################

module "dataproc_initializations" {
  source             = "terraform-google-modules/cloud-storage/google//modules/simple_bucket"
  version            = "4.0.0"
  name               = "${local.project_id}-dataproc-initializations"
  project_id         = local.project_id
  location           = var.location
  versioning         = false
  bucket_policy_only = true
  storage_class      = "STANDARD"
  depends_on = [
    module.viq_services,
  ]
}
#######################
####### logging #######
#######################

module "logging" {
  source             = "terraform-google-modules/cloud-storage/google//modules/simple_bucket"
  version            = "4.0.0"
  name               = "${local.project_id}-logging"
  project_id         = local.project_id
  location           = var.location
  versioning         = false
  bucket_policy_only = true
  storage_class      = "STANDARD"
  depends_on = [
    module.viq_services,
  ]
}


#######################
##### nmsrv1-esp ######
#######################

module "nmsrv1_esp" {
  source             = "terraform-google-modules/cloud-storage/google//modules/simple_bucket"
  version            = "4.0.0"
  name               = "${local.project_id}-nmsrv1-esp"
  project_id         = local.project_id
  location           = var.location
  versioning         = false
  bucket_policy_only = true
  storage_class      = "STANDARD"
  depends_on = [
    module.viq_services,
  ]
}

##########################
## dataproc-staging2022 ##
##########################

module "dataproc_staging2022" {
  source             = "terraform-google-modules/cloud-storage/google//modules/simple_bucket"
  version            = "4.0.0"
  name               = "${local.project_id}-dataproc-staging2022"
  project_id         = local.project_id
  location           = var.location
  versioning         = false
  bucket_policy_only = true
  storage_class      = "STANDARD"
  depends_on = [
    module.viq_services,
  ]
}


###############################################
############### viq_export_dir ################
###############################################

module "viq_export_dir" {
  source             = "terraform-google-modules/cloud-storage/google//modules/simple_bucket"
  version            = "4.0.0"
  name               = "${local.project_id}-viq-export-dir"
  project_id         = local.project_id
  location           = var.location
  versioning         = false
  bucket_policy_only = true
  storage_class      = "STANDARD"
  iam_members = [
    {
      role   = "roles/storage.objectAdmin"
      member = "serviceAccount:${module.sa_viq_cloud_run.email}"
    },
    {
      role   = "roles/storage.legacyBucketReader"
      member = "serviceAccount:${module.sa_viq_cloud_run.email}"
    },
  ]
  depends_on = [
    module.viq_services,
    module.sa_viq_cloud_run
  ]
}


###############################################
################# gsp-gdpr ####################
###############################################

module "gsp_gdpr" {
  source             = "terraform-google-modules/cloud-storage/google//modules/simple_bucket"
  version            = "4.0.0"
  name               = "${local.project_id}-gsp-gdpr"
  project_id         = local.project_id
  location           = var.location
  versioning         = false
  bucket_policy_only = true
  storage_class      = "STANDARD"
  depends_on = [
    module.viq_services,
  ]
}


###########################################
############### gsp-backup ################
###########################################

module "gsp_backup" {
  source             = "terraform-google-modules/cloud-storage/google//modules/simple_bucket"
  version            = "4.0.0"
  name               = "${local.project_id}-gsp-backup"
  project_id         = local.project_id
  location           = var.location
  versioning         = false
  bucket_policy_only = true
  storage_class      = "STANDARD"
  depends_on = [
    module.viq_services,
  ]
}


###########################################
############### gsp-strapi ################
###########################################

module "gsp_strapi" {
  source             = "terraform-google-modules/cloud-storage/google//modules/simple_bucket"
  version            = "4.0.0"
  name               = "${local.project_id}-gsp-strapi"
  project_id         = local.project_id
  location           = var.location
  versioning         = false
  bucket_policy_only = true
  storage_class      = "STANDARD"
  depends_on = [
    module.viq_services,
  ]
}

###############################################
############# gsp-logos ###############
###############################################

module "gsp_logos" {
  source             = "terraform-google-modules/cloud-storage/google//modules/simple_bucket"
  version            = "4.0.0"
  name               = "${local.project_id}-gsp-logos"
  project_id         = local.project_id
  location           = var.location
  versioning         = false
  bucket_policy_only = true
  storage_class      = "STANDARD"
  iam_members = [
    {
      role   = "roles/storage.objectAdmin"
      member = "serviceAccount:${module.sa_viq_cloud_run.email}"
    },
    {
      role   = "roles/storage.legacyBucketReader"
      member = "serviceAccount:${module.sa_viq_cloud_run.email}"
    },
  ]
  depends_on = [
    module.sa_viq_cloud_run
  ]
}


# ##############################################
# ############## gsp-sql-backup ################
# ##############################################

module "gsp_sql_backup" {
  source             = "terraform-google-modules/cloud-storage/google//modules/simple_bucket"
  version            = "4.0.0"
  name               = "${local.project_id}-gsp-sql-backup"
  project_id         = local.project_id
  location           = var.location
  versioning         = false
  bucket_policy_only = true
  storage_class      = "STANDARD"
  depends_on = [
    module.viq_services,
  ]
}


###############################################
############# st-cass-migration ###############
###############################################

module "cass_migration" {
  source             = "terraform-google-modules/cloud-storage/google//modules/simple_bucket"
  version            = "4.0.0"
  name               = "${local.project_id}-cass-migration"
  project_id         = local.project_id
  location           = var.location
  versioning         = false
  bucket_policy_only = true
  storage_class      = "STANDARD"
  depends_on = [
    module.viq_services,
  ]
}


###############################################
################ gspbackup ####################
###############################################

module "gspbackup" {
  source             = "terraform-google-modules/cloud-storage/google//modules/simple_bucket"
  version            = "4.0.0"
  name               = "${local.project_id}-gspbackup"
  project_id         = local.project_id
  location           = var.location
  versioning         = false
  bucket_policy_only = true
  storage_class      = "STANDARD"
  depends_on = [
    module.viq_services,
  ]
}


##############################################
############# dataproc-staging ###############
##############################################

module "dataproc_staging" {
  source             = "terraform-google-modules/cloud-storage/google//modules/simple_bucket"
  version            = "4.0.0"
  name               = "${local.project_id}-dataproc-staging"
  project_id         = local.project_id
  location           = var.location
  versioning         = false
  bucket_policy_only = true
  storage_class      = "STANDARD"
  depends_on = [
    module.viq_services,
  ]
}

###########################################
############# dataproc-temp ###############
###########################################

module "dataproc_temp" {
  source             = "terraform-google-modules/cloud-storage/google//modules/simple_bucket"
  version            = "4.0.0"
  name               = "${local.project_id}-dataproc-temp"
  project_id         = local.project_id
  location           = var.location
  versioning         = false
  bucket_policy_only = true
  storage_class      = "STANDARD"
  depends_on = [
    module.viq_services,
  ]
}

#####################################################################
############# dataproc-phs(Persistent History Server) ###############
#####################################################################

module "dataproc_phs" {
  source             = "terraform-google-modules/cloud-storage/google//modules/simple_bucket"
  version            = "4.0.0"
  name               = "${local.project_id}-dataproc-phs"
  project_id         = local.project_id
  location           = var.location
  versioning         = false
  bucket_policy_only = true
  storage_class      = "STANDARD"
   lifecycle_rules = [
    {
      action = {
        type = "Delete"
      }
      condition = {
        age = 60
        with_state = "ANY"
        matches_storage_class = "STANDARD"
      }
    }
  ]
  iam_members = [
    {
      role   = "roles/storage.objectAdmin"
      member = "serviceAccount:${module.sa_viq_dataproc_phs.email}"
    },
    {
      role   = "roles/storage.legacyBucketReader"
      member = "serviceAccount:${module.sa_viq_dataproc_phs.email}"
    },
  ]
  depends_on = [
    module.viq_services,
    module.sa_viq_dataproc_phs
  ]
}

# Spark needs the spark-events directory to already exist.
resource "google_storage_bucket_object" "spark_events_dir" {
  bucket       = module.dataproc_phs.name
  name         = "spark-events/.keep"
  content      = " "
  content_type = "application/x-www-form-urlencoded;charset=UTF-8"
  depends_on = [
    module.viq_services,
    module.dataproc_phs
  ]
}

###################################################
############# ci-cd-deployed-git-commits ##########
###################################################
 
module "ci_cd_deployed_git_commits" {
  source             = "terraform-google-modules/cloud-storage/google//modules/simple_bucket"
  version            = "4.0.0"
  name               = "${local.project_id}-ci-cd-deployed-git-commits"
  project_id         = local.project_id
  location           = var.location
  versioning         = false
  bucket_policy_only = true
  storage_class      = "STANDARD"
  depends_on = [
    module.viq_services,
  ]
}

module "gcs_iam_bindings" {
  source          = "terraform-google-modules/iam/google//modules/storage_buckets_iam"
  version         = "7.6.0"
  storage_buckets = [
    module.dataproc_initializations.bucket.name,
    module.logging.bucket.name, 
    module.nmsrv1_esp.bucket.name,
    module.dataproc_staging2022.bucket.name,
    module.viq_export_dir.bucket.name,
    module.gsp_gdpr.bucket.name,
    module.gsp_backup.bucket.name,
    module.gsp_strapi.bucket.name,
    module.gsp_logos.bucket.name,
    module.gsp_sql_backup.bucket.name,
    module.cass_migration.bucket.name,
    module.gspbackup.bucket.name,
    module.jars.bucket.name,
    module.cloud_functions_code.name,
    module.dataflow.name,
  ]
  mode = "additive"
  bindings = var.common_gcs_iam_bindings
  depends_on = [
    module.viq_services,
  ]
}

##############################################
############# cloudsql-certs ###############
##############################################

module "cloudsql_certs" {
  source             = "terraform-google-modules/cloud-storage/google//modules/simple_bucket"
  version            = "4.0.0"
  name               = "${local.project_id}-cloudsql-certs"
  project_id         = local.project_id
  location           = var.location
  versioning         = false
  bucket_policy_only = true
  storage_class      = "STANDARD"
  depends_on = [
    module.viq_services,
  ]
}
#############################
## dataproc-staging-backup ##
#############################

module "dataproc_stagingbkp" {
  source             = "terraform-google-modules/cloud-storage/google//modules/simple_bucket"
  version            = "4.0.0"
  name               = "${local.project_id}-dataproc-staging-bkp"
  project_id         = local.project_id
  location           = var.location
  versioning         = false
  bucket_policy_only = true
  storage_class      = "STANDARD"
}


####################
##  pg-staging    ##
####################
module "pg_staging" {
  source             = "terraform-google-modules/cloud-storage/google//modules/simple_bucket"
  version            = "4.0.0"
  name               = "${local.project_id}-pg-staging"
  project_id         = local.project_id
  location           = var.location
  versioning         = false
  bucket_policy_only = true
  storage_class      = "STANDARD"
}

module "dataflow" {
  source             = "terraform-google-modules/cloud-storage/google//modules/simple_bucket"
  version            = "4.0.0"
  name               = "${local.project_id}-dataflow"
  project_id         = local.project_id
  location           = var.location
  versioning         = false
  bucket_policy_only = true
  storage_class      = "STANDARD"
}

module "jars" {
  source             = "terraform-google-modules/cloud-storage/google//modules/simple_bucket"
  version            = "4.0.0"
  name               = "${local.project_id}-jars"
  project_id         = local.project_id
  location           = var.location
  versioning         = false
  bucket_policy_only = true
  storage_class      = "STANDARD"
}


module "cloud_functions_code" {
  source             = "terraform-google-modules/cloud-storage/google//modules/simple_bucket"
  version            = "4.0.0"
  name               = "${local.project_id}-cloud-functions-code"
  project_id         = local.project_id
  location           = var.location
  versioning         = false
  bucket_policy_only = true
  storage_class      = "STANDARD"
  iam_members = [
    {
      role   = "roles/storage.objectViewer"
      member = "serviceAccount:${module.sa_viq_cloudfunction.email}"
    },
    {
      role   = "roles/storage.legacyBucketReader"
      member = "serviceAccount:${module.sa_viq_cloudfunction.email}"
    },
  ]
}