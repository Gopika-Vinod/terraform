variable "dataset_id" {
  description = "Unique ID for the dataset being provisioned."
  type        = string
}

variable "iam_members" {
  description = "  "
  type = list(object({
    role = string
    member=string
  }))
  default = []
}

variable "access" {
  description = "An array of objects that define dataset access for one or more entities."
  type        = any
  default = [{
    role          = "roles/bigquery.dataOwner"
    special_group = "projectOwners"
  }]
}

variable "project_id" {
  description = "Project where the dataset and table are created"
  type        = string
}

variable "encryption_key" {
  description = "Default encryption key to apply to the dataset. Defaults to null (Google-managed)."
  type        = string
  default     = null
}

variable "dataset_name" {
  description = "Friendly name for the dataset being provisioned."
  type        = string
  default     = null
}

variable "description" {
  description = "Dataset description."
  type        = string
  default     = null
}

variable "location" {
  description = "The regional location for the dataset only US and EU are allowed in module"
  type        = string
  default     = "US"
}

variable "dataset_labels" {
  description = "Key value pairs in a map for dataset labels"
  type        = map(string)
  default     = {}
}

variable "delete_contents_on_destroy" {
  description = "(Optional) If set to true, delete all the tables in the dataset when destroying the resource; otherwise, destroying the resource will fail if tables are present."
  type        = bool
  default     = null
}

variable "default_table_expiration_ms" {
  type = string
  default = null
}