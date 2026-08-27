terraform {
  required_version = ">= 1.5.1"

  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "~> 2.5"
    }
  }
}
