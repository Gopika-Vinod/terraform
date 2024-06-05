terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      #version = ">=4.52.0"
      version = ">=4.80.0"
    }
    google-beta = {
      source = "hashicorp/google-beta"
      #version = ">=4.52.0"
      version = ">=4.80.0"
    }
    local = {
      source = "hashicorp/local"
      version = "2.3.0"
    }
  }
}
