variable "google_project_id" {}
variable "google_credentials_path" {}
variable "google_region" {
  default = "europe-west1"
}

locals {
  gcp_services = [
    "run.googleapis.com",
    "compute.googleapis.com",
    "cloudkms.googleapis.com",
    "pubsub.googleapis.com",
    "secretmanager.googleapis.com",
    "iam.googleapis.com",
  ]
}

provider "google" {
  project     = var.google_project_id
  credentials = file(var.google_credentials_path)
}

provider "google-beta" {
  project     = var.google_project_id
  credentials = file(var.google_credentials_path)
}

resource "google_project_service" "services" {
  for_each = toset(local.gcp_services)

  service                    = each.value
  disable_dependent_services = true
}
