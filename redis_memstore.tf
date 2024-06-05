module "viq_redis" {
  source                     = "terraform-google-modules/memorystore/google"
  version                    = "7.1.1"
  project                 = local.project_id
  region                     = var.primary_region
  location_id                = var.primary_zone
  enable_apis                = true
  name                       = "${local.project_id}-redis"
  display_name               = "${local.project_id}-redis"
  connect_mode               = "DIRECT_PEERING"
  auth_enabled               = false 
  memory_size_gb             = 6
  tier                       = "BASIC"
  labels                     = {}
  authorized_network         = module.vpc.network_self_link	
  read_replicas_mode         = "READ_REPLICAS_DISABLED"
  redis_version              = "REDIS_6_X"
  redis_configs              = {
    maxmemory-gb = 6
  }
  persistence_config         = {
    persistence_mode = "DISABLED"
    rdb_snapshot_period = null    
  }
  reserved_ip_range          = var.viq_redis_reserved_ip_range
  transit_encryption_mode    = "DISABLED"
  maintenance_policy         = {
    day = "SATURDAY"
    start_time = {
      hours   = 20
      minutes = 30
      seconds = 0
      nanos   = 0
    }
  }
  replica_count              = null
}
