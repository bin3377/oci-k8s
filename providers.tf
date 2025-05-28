terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 7.2.0"
    }
  }
}

provider "oci" {
  config_file_profile = "DEFAULT"
  region              = var.region
}
