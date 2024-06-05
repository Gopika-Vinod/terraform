
##cloud run
variable "url_map" {
  type = list(object({
    name   = string
    description = string
    path = string
    # enable_cdn = bool
  }))
  default = []  
  description = "URL Map for the load balancer"  
}

variable "default_service" {
  type = string
  description = "Default backend service for Load balancer"
}

variable "lb_domain_name" {
  type =string
  description = "domain name to be used for creating google managed ssl cert"  
}

variable "lb_name" {
  type =string
  description = "Name for the load balancer"  
}

variable "neg_region" {
  type        = string
  description = "Region for Network Endpoint group"
}

variable "project_id" {
  type        = string
  description = "Project ID"
}

variable "security_policy" {
  type        = string
  description = "Cloud Armour Security Policy"
  default = null
}

# variable "enable_cdn" {
#   type      = bool
#   description = "enable cdn for cloud run services"
#   default = false
# }

variable "enable_cdn_services" {
  type = list(string)
  description = "cdn enable services"
  default = []
}