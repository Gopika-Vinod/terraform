
# # LOCAL PRIVATE ZONE
module "private_dns_zone_local" {
  source      = "terraform-google-modules/cloud-dns/google"
  version     = "5.0.0"
  project_id  = local.project_id
  type        = "private"
  name        = "dns-zone-${module.vpc.network_name}-local"
  domain      = "local."
  description = "Private DNS Zone for Local"
  private_visibility_config_networks = [
    module.vpc.network_self_link
  ]
  depends_on = [
    module.viq_services,
  ]
}

resource "google_dns_record_set" "viq_psql_master" {
  name = "${module.viq_psql.instance_name}.local."
  type = "A"
  ttl  = 300
  project  = local.project_id

  managed_zone = module.private_dns_zone_local.name

  rrdatas = [
    module.viq_psql.instance_first_ip_address
  ]
}

resource "google_dns_record_set" "viq_psql_replica" {
  name = "${module.viq_psql.read_replica_instance_names[0]}.local."
  type = "A"
  ttl  = 300
  project  = local.project_id

  managed_zone = module.private_dns_zone_local.name

  rrdatas = [
    module.viq_psql.replicas_instance_first_ip_addresses[0][0]["ip_address"]
  ]
}

resource "google_dns_policy" "dns_logging_policy" {
  name                      = "dns-logging-policy"
  enable_logging            = true
  enable_inbound_forwarding = false
  description               = "DNS Policy to enable logging for Private Managed Zones"
  project                   = local.project_id
  networks {
    network_url = module.vpc.network_self_link
  }
}