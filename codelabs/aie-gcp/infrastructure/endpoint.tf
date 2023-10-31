variable "internet_address" {}
variable "pohttp_server_domain" {}

module "awala-endpoint" {
  source  = "relaycorp/awala-endpoint/google"
  version = "1.8.20"

  backend_name     = "pong"
  internet_address = var.internet_address

  project_id = var.google_project_id
  region     = var.google_region

  pohttp_server_domain = var.pohttp_server_domain

  mongodb_uri      = local.mongodb_uri
  mongodb_db       = local.mongodb_db_name
  mongodb_user     = mongodbatlas_database_user.main.username
  mongodb_password = random_password.mongodb_user_password.result
}

output "pohttp_server_ip_address" {
  value = module.awala-endpoint.pohttp_server_ip_address
}
output "bootstrap_job_name" {
  value = module.awala-endpoint.bootstrap_job_name
}
