variable "members" {
  type = list(string)
  description = "Provide iam-formated member"
}

variable "dataset_id" {
  type = string
  description = "Dataset ID on which roles need to be granted"
}

variable "role" {
  type = string
  description = "Role to be granted"
}

variable "project_id" {
  type = string
  description = "Project ID in which dataset resides"
}