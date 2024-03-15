terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.40"
    }
    template = {
      source  = "hashicorp/template"
      version = "~> 2.2"
    }
  }
}

# Configure provider
provider "aws" {
  region  = "eu-central-1"
  profile = "<your_profile>"
}
