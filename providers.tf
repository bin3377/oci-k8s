terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 7.2.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.37"
    }
  }
}

provider "oci" {
  config_file_profile = "DEFAULT"
}
