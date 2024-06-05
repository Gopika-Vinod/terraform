data "template_file" "cloudsql_proxy" {
  template = file("./scripts/cloudsql_proxy.tpl")
  vars = {
    conn = module.viq_psql.instance_connection_name
  }
}


module "viq_cloudsql_proxy" {
  source = "./custom_modules/compute_engine"

  project_id   = local.project_id
  disk_size_gb = 50
  machine_type = "n1-standard-2"
  name         = "${local.project_id}-cloudsql-proxy"
  service_account = {
    email  = module.sa_viq_cloudsql_proxy.email
    scopes = ["cloud-platform"]
  }
  source_image         = "debian-11-bullseye-v20220719"
  source_image_project = "debian-cloud"
  source_image_family  = "debian-11"
  tags = [
    "nt-egress-allow-all-http-https",
    "nt-ingress-allow-psql-proxy-tcp-5432",
    "nt-ingress-allow-ssh-iap"
  ]
  zone = var.primary_zone
  metadata = {
    block-project-ssh-keys = false
    startup-script         = data.template_file.cloudsql_proxy.rendered
  }
  enable_shielded_vm = true
  subnetwork_project = local.project_id
  subnetwork         = module.vpc.subnets["${var.primary_region}/sb-${local.project_id}-compute-${var.primary_region}"]["id"]
  static_ips         = module.internal_static_ip_reserve.addresses[0]
  depends_on = [
    module.viq_services,
  ]
  # labels = {
  #   bu-owner-manager   = "jc6793"
  #   bu-owner-technical = "mc8311"
  #   description        = "business-unit"
  # }
}

