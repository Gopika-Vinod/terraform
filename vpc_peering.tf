module "network_peering" {
  source = "terraform-google-modules/network/google//modules/network-peering"
  version = "7.1.0"

  # Configure the module variables
  prefix = "peering"
  local_network           = module.vpc.network_self_link	
  peer_network      = "projects/viq-st-na-infra-np-s/global/networks/viq-st-na-infra-np-s-vpc"
  export_local_custom_routes = true
  export_local_subnet_routes_with_public_ip = true
  export_peer_custom_routes = true
  export_peer_subnet_routes_with_public_ip = true
}
