terraform {
  required_providers {
    aws = {
      version = "~> 6.0"
      source  = "hashicorp/aws"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">=2.0.0"
    }
    kubectl = {
      source  = "alekc/kubectl"
      version = "2.4.0"
    }
  }
  required_version = ">= 1.2.5"
}