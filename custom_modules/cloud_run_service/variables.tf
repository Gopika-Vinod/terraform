
// service
variable "project_id" {
  description = "The project ID to deploy to"
  type        = string
}

variable "service_name" {
  description = "Name must be unique within a namespace, within a Cloud Run region. Is required when creating resources. Name is primarily intended for creation idempotence and configuration definition. Cannot be updated."
  type        = string
}

variable "location" {
  description = "The location of the cloud run instance. eg us-central1"
  type        = string
}


variable "traffic_split" {
  type = list(object({
    latest_revision = bool # LatestRevision may be optionally provided to indicate that the latest ready Revision of the Configuration should be used for this traffic target. When provided LatestRevision must be true if RevisionName is empty; it must be false when RevisionName is non-empty.
    percent         = number
    revision_name   = string
    tag             = string
  }))
  description = "Managing traffic routing to the service"
  default = [{
    latest_revision = true
    percent         = 100
    revision_name   = "v1-0-0"
    tag             = null
  }]
}

variable "service_labels" {
  type        = map(string)
  description = "A set of key/value label pairs to assign to the service"
  default     = {}
}

variable "service_annotations" {
  type        = map(string)
  description = "Annotations to the service. Acceptable values all, internal, internal-and-cloud-load-balancing"
  default = {
    "run.googleapis.com/launch-stage" = "GA" 
    "run.googleapis.com/ingress" = "internal-and-cloud-load-balancing"
  }
}


// Metadata
variable "template_labels" {
  type        = map(string)
  description = "A set of key/value label pairs to assign to the container metadata"
  default     = {}
}

variable "template_annotations" {
  type        = map(string)
  description = "Annotations to the container metadata including VPC Connector and SQL. See [more details](https://cloud.google.com/run/docs/reference/rpc/google.cloud.run.v1#revisiontemplate)"
  default = {
    "run.googleapis.com/client-name"   = "terraform"
    "generated-by"                     = "terraform"

        # By default, container instances have min-instances turned off, with a setting of 0
        # number of container instances to be kept warm and ready to serve requests. 
        # Instances kept running using the minimum instances feature do incur billing costs.
        "autoscaling.knative.dev/minScale" = 0
        # By default, Cloud Run services are configured to scale out to a maximum of 100 instances.
        # Use this setting as a way to control your costs or to limit the number of connections to a backing service, such as to a database.
        "autoscaling.knative.dev/maxScale" = 2
        # If you use second generation, you must also specify at least 512 MiB of memory.
        # https://cloud.google.com/run/docs/about-execution-environments
        "run.googleapis.com/execution-environment" = "gen2"
        # all-traffic: Sends all outbound traffic through the connector.
        # private-ranges-only: Sends only traffic to internal addresses through the VPC connector.
        "run.googleapis.com/vpc-access-egress" = "private-ranges-only"
  }
}


variable "argument" {
  type        = list(string)
  description = "Arguments passed to the ENTRYPOINT command, include these only if image entrypoint needs arguments"
  default     = []
}

variable "image" {
  description = "GCR hosted image URL to deploy"
  type        = string
}

variable "container_command" {
  type        = list(string)
  description = "Leave blank to use the ENTRYPOINT command defined in the container image, include these only if image entrypoint should be overwritten"
  default     = []
}

variable "env_vars" {
  type = list(object({
    value = string
    name  = string
  }))
  description = "Environment variables (cleartext)"
  default     = []
}

variable "limits" {
  type        = map(string)
  description = "Resource limits to the container"
  default     = null
}
variable "requests" {
  type        = map(string)
  description = "Resource requests to the container"
  default     = {}
}

variable "volumes_mount" {
  type = list(object({
    name       = string
    mount_path = string
  }))
  description = "Path within the container at which the volume should be mounted. "
  default     = []
}

variable "generate_revision_name" {
  type        = bool
  description = "Option to enable revision name generation"
  default     = true
}

variable "encryption_key" {
  description = "CMEK encryption key self-link expected in the format projects/PROJECT/locations/LOCATION/keyRings/KEY-RING/cryptoKeys/CRYPTO-KEY."
  type        = string
  default     = null
}


variable "volume_mounts" {
  type = list(object({
    mount_path = string
    name       = string
  }))
  description = "[Beta] Volume Mounts to be attached to the container (when using secret)"
  default     = []
}

variable "startup_probe" {
  type = object({
    initial_delay_seconds = optional(string,30)
    timeout_seconds = optional(string,1)
    period_seconds = optional(string,10)
    failure_threshold  = optional(string,3)
    tcp_socket = optional(object({
      port = string
    }))
    http_get = optional(object({
      path = optional(string)
      http_headers = optional(object({
        name = string 
        value = string
      }))
    }))
    grpc = optional(object({
      port = string
      service = string 
    }))
  })
}


variable "liveness_probe" {
  type = object({
    initial_delay_seconds = optional(string,30)
    timeout_seconds = optional(string,1)
    period_seconds = optional(string,10)
    failure_threshold  = optional(string,3)
    http_get = optional(object({
      path = string
      http_headers = optional(object({
        name = string 
        value = string
      }))
    }))
    grpc = optional(object({
      port = string
      service = string 
    }))
  })
}

variable "env_secret_vars" {
  type = list(object({
    name = string
    value_from = set(object({
      secret_key_ref = map(string)
    }))
  }))
  description = "[Beta] Environment variables (Secret Manager)"
  default     = []
}

variable "container_concurrency" {
  type        = number
  description = "Concurrent request limits to the service"
  default     = null
}

variable "timeout_seconds" {
  type        = number
  description = "Timeout for each request"
  default     = 120
}

variable "service_account_email" {
  type        = string
  description = "Service Account email needed for the service"
  default     = ""
}

variable "volumes" {
  type = list(object({
    name = string
    secret = object({
      secret_name = string
      items       = map(string)
    })
  }))
  description = "[Beta] Volumes needed for environment variables (when using secret)"
  default     = []
}

variable "ports" {
  type = object({
    name = string
    port = number
  })
  description = "Port which the container listens to (http1 or h2c)"
  default = {
    name = "http1"
    port = 8080
  }
}

variable "allow_unauthenticated"{
  type = bool
  description = "You can allow unauthenticated invocations to a service by assigning the IAM Cloud Run Invoker role to the allUsers member type."
  default = true
}
// IAM
variable "members" {
  type        = list(string)
  description = "Users/SAs to be given invoker access to the service"
  default     = []
}