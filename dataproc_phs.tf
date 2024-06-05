#locals {
# name = "dataproc-persistent-history-server"
#}
#module "dataproc_phs_cluster" {
#  source          = "./custom_modules/dataproc"
#  name            = local.name
#  project         = local.project_id
#  staging_bucket  = module.dataproc_staging.name
#  temp_bucket     = module.dataproc_temp.name
#  region          = var.primary_region
#  zone            = var.primary_zone
#  subnetwork      = module.vpc.subnets["${var.primary_region}/sb-${local.project_id}-dataproc-${var.primary_region}"]["id"]
#  service_account = module.sa_viq_dataproc_phs.email
#  network_tags = [
#    "nt-egress-allow-all-http-https",
#    "nt-ingress-allow-ssh-iap",
#    "nt-ingress-allow-dataproc-tcp-udp-icmp-all",
#  ]
#  internal_ip_only      = true
#  enable_shielded_nodes = true
#  cluster_metadata =  {
#    block-project-ssh-keys = true
#    enable-oslogin = true
#  }
#  master_num_instances = 1
#  master_machine_type      = "n1-standard-4"
#  master_boot_disk_size_gb = 50
#  worker_num_instances     = 0
#  image_version            = "2.1.2-debian11"
#  override_properties      = {
#    "dataproc:dataproc.x.zero.workers"              = "true"
#    "yarn:yarn.log-aggregation-enable"                  = "true"
#    "yarn:yarn.nodemanager.remote-app-log-dir"          = "gs://${local.project_id}-dataproc-phs/yarn/logs/"
#    "yarn:yarn.log-aggregation.retain-seconds"          = "604800" # 7 days
#    "yarn:yarn.log.server.url"                          = "http://${local.name}-m:19888/jobhistory/logs"
#    "mapred:mapreduce.jobhistory.always-scan-user-dir"  = "true"
#    "mapred:mapreduce.jobhistory.address"               = "${local.name}-m:10020"
#    "mapred:mapreduce.jobhistory.webapp.address"        = "${local.name}-m:19888"
#    "mapred:mapreduce.jobhistory.done-dir"              = "gs://${module.dataproc_phs.name}/done-dir"
#    "mapred:mapreduce.jobhistory.intermediate-done-dir" = "gs://${module.dataproc_phs.name}/intermediate-done-dir"
#    "spark:spark.eventLog.dir"                          = "gs://${module.dataproc_phs.name}/spark-events/"
#    "spark:spark.history.fs.logDirectory"               = "gs://${module.dataproc_phs.name}/spark-events/"
#    "spark:spark.ui.enabled"                            = "true"
#    "spark:spark.ui.filters"                            = "org.apache.spark.deploy.yarn.YarnProxyRedirectFilter"
#    "spark:spark.yarn.historyServer.address"            = "${local.name}-m:18080"
#  } 
#  optional_components     = []
#  enable_http_port_access = true
#  depends_on = [
#    module.viq_services,
#    module.dataproc_phs,
#    module.sa_viq_dataproc_phs,
#  ]
#} 