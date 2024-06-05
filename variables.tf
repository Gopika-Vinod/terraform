######################################
############# vpc.tf #################
######################################

variable "vpc_subnets" {
  type        = list(map(string))
  description = "The list of subnets being created"
}

variable "vpc_secondary_ranges" {
  type = map(list(object({
    range_name    = string,
    ip_cidr_range = string
  })))
}

##########################################
############## firewall.tf ###############
##########################################


variable "common_firewall_rules" {
  type = map(object({
    description          = string
    direction            = string       # (INGRESS|EGRESS)
    action               = string       # (allow|deny)
    ranges               = list(string) # list of IP CIDR ranges
    sources              = list(string) # tags or SAs (ignored for EGRESS)
    targets              = list(string) # tags or SAs
    use_service_accounts = bool         # use tags or SAs in sources/targets
    rules = list(object({
      protocol = string
      ports    = list(string)
    }))
    extra_attributes = map(string) # map, optional keys disabled or priority
  }))
}

################################################
####### # project_level_iam_bindings.tf ########
################################################
variable "viq_project_level_iam_bindings" {
  description = "Map of role (key) and list of members (value) to add the IAM policies/bindings"
  type        = map(list(string))
  default     = {}
}

################################################
####### private_service_access.tf ##############
################################################

variable "private_service_access_cidr_prefix" {
  type        = string
  description = "Prefix of Reserved IP CIDR"
}

variable "private_service_access_cidr_ip" {
  type        = list(string)
  description = "List of Reserved IP"
}



#################################
########### common ##############
#################################
variable "project_prefix" {
  type        = string
  description = "Project Prefix"
}

variable "country" {
  type        = string
  description = "project country"
}

variable "env" {
  type        = string
  description = "Environment suffix"
}

variable "primary_region" {
  type        = string
  description = "primary region"
}

variable "primary_zone" {
  type        = string
  description = "primary zone"
}

variable "location" {
  type        = string
  description = "resource location"
}

variable "ops_project_id" {
  type =string
  description = "Name for ops_project_id"  
}

variable "cloud_run_load_balancer_hosts" {
  type =list(string)
  description = "Host Names of the all the Global HTTPs load balancer for VIQ Cloud Run services"  
  default = []
}



# Gcs

variable "common_gcs_iam_bindings" {
  type = map(list(string))
}

# BQ Dataset

variable "bigquery_datasets" {
  type = list(string)
}

# artifact_location

variable "artifact_location" {
  type        = string
}

# memorystore redis

variable "viq_redis_reserved_ip_range" {
  type = string
  description = "IP range used for DIRECT PEERING for redis"
}

######Composer_2 variables######
# variable "master_ipv4_cidr_block" {
#   type =string
#   description = "composer 2 master cidr range"
#   default  = null  
# }

#comment below var while applying in eu-t
variable "cmpsr_2_4_3_master_ipv4_cidr_block" {
  type =string
  description = "composer 2 master cidr range" 
  default = null  

}
