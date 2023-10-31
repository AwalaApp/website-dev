---
nav_order: 1
permalink: /codelabs/internet-endpoint
parent: Codelabs
---

# Build and deploy a server-side app

## What you'll achieve

**You'll build and deploy a server-side app that sends and receives data via Awala**. Think of it as a "Hello world" tutorial -- the app itself will be trivial because it just communicates with [Awala Ping](https://play.google.com/store/apps/details?id=tech.relaycorp.ping).

The following diagram illustrates the architecture of the app you'll build, and where it fits the in the Awala network as it communicates with Awala Ping:

![Diagram](assets/aie-diagram.svg)

Awala-compatible, server-side apps can be written in any language and deployed to any platform, but this codelab will only use examples in Node.js and Kotlin on [Google Cloud Platform](https://cloud.google.com/).

You shouldn't need more than 30 minutes to complete the codelab, once the pre-requisites are met.

## Pre-requisites

- Familiarity with either Node.js or Kotlin (we may add more examples in the future).
- [Terraform](https://developer.hashicorp.com/terraform/downloads) 1.5 or newer.
- A domain name with DNSSEC correctly configured. Use [DNSSEC Analyzer](https://dnssec-analyzer.verisignlabs.com/) to verify this.
- A [Google Cloud Platform](https://cloud.google.com/) account with billing configured.
- A [MongoDB Atlas](https://www.mongodb.com/atlas/database) account with billing configured.
- A [Docker Hub](https://hub.docker.com/) account, so you can deploy the Docker image you'll create.
- An Android device, so you can test your app end-to-end.

## Estimated costs

To the best of our knowledge, this codelab _shouldn't_ cost anything if you're able to use the free tier of GCP and MongoDB Atlas -- otherwise, it _should_ cost less than $4/day or a few cents per minute as of this writing.

Having said this, you're solely responsible for any costs incurred whilst following this codelab. We're only offering an estimate based on our own experience, not a guarantee.

Make sure to [clean up at the end](#clean-up) to avoid incurring in further costs.

## Troubleshooting

If something doesn't work as expected at any time, [check out the final code](https://github.com/AwalaNetwork/website-dev/tree/main/codelabs/aie-gcp/) or [ask for help](../help.md).

## Steps

### 1. Set up your development environment

Open your terminal and create the directory `aie-gcp` with two subdirectories: `codelab-tf` and `codelab-app`. For example:

```shell
mkdir -p aie-gcp/infrastructure aie-gcp/app
```

`infrastructure/` will contain the Terraform code to manage your GCP and MongoDB Atlas resources, whilst `app/` will contain the code for your app.

Next, create the file `air-gcp/infrastructure/providers.tf` with the following content to configure the Terraform providers you'll use:

```hcl
terraform {
  required_providers {
    google = {
      version = "~> 4.84.0"
    }
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "~> 1.10.2"
    }
  }
}
```

Finally, initialise your workspace and install the providers above:

```shell
terraform init
```

### 2. Create and configure a new GCP project

First, configure your GCP project as follows:

1. [Create a new project from the GCP Console](https://console.cloud.google.com/projectcreate).
2. [Create a new service account](https://console.cloud.google.com/iam-admin/serviceaccounts/create) with the _Owner_ (`roles/owner`) role.
3. Generate a new key for the service account you just created from the "Keys" tab, and save the JSON file to disk.
   ![gcp-sa-key.png](assets/gcp-sa-key.png)
4. Enable the [Cloud Resource Manager API](https://console.developers.google.com/apis/api/cloudresourcemanager.googleapis.com/overview).

Next, integrate your project in Terraform:

1. Create `aie-gcp/infrastructure/gcp.tf` with the following content:
   ```hcl
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
   ```
2. Create `aie-gcp/infrastructure/terraform.tfvars` with the following content -- make sure to replace the placeholders with the correct values:
   ```hcl
   google_project_id       = "<YOUR-GCP-PROJECT-ID>"
   google_credentials_path = "<PATH-TO-GCP-CREDENTIALS-JSON>"
   ```

Finally, get Terraform to complete the setup:

```shell
terraform apply
```

It should normally take a couple of minutes for Terraform to complete the setup.

### 3. Create and configure a new MongoDB Atlas project

1. Create a new project from [the MongoDB Atlas console](https://cloud.mongodb.com/v2).
2. Go to the Access Management section of your newly-created project.
   ![mongodbatlas-access-manager.png](assets/mongodbatlas-access-manager.png)
3. Create an API key with the _Project Owner_ role.
   ![mongodbatlas-api-key-role.png](assets/mongodbatlas-api-key-creation.png)
4. Keep the browser tab open, so you can copy the public and private keys shortly.

Next, integrate your MongoDB Atlas project in Terraform and create the required resources:

1. Create `aie-gcp/infrastructure/mongodbatlas.tf` with the following content:
   ```hcl
   variable "mongodbatlas_public_key" {}
   variable "mongodbatlas_private_key" {}
   variable "mongodbatlas_project_id" {}

   provider "mongodbatlas" {
     public_key  = var.mongodbatlas_public_key
     private_key = var.mongodbatlas_private_key
   }
   
   locals {
     mongodb_db_name = "main"
     mongodb_uri     = "${mongodbatlas_serverless_instance.main.connection_strings_standard_srv}/?retryWrites=true&w=majority"
   }
   
   resource "mongodbatlas_serverless_instance" "main" {
     project_id = var.mongodbatlas_project_id
     name       = "awala-endpoint"
      
     provider_settings_backing_provider_name = "GCP"
     provider_settings_provider_name         = "SERVERLESS"
     provider_settings_region_name           = "WESTERN_EUROPE"
   }
   
   resource "mongodbatlas_project_ip_access_list" "main" {
     project_id = var.mongodbatlas_project_id
     comment    = "See https://github.com/relaycorp/terraform-google-awala-endpoint/issues/2"
     cidr_block = "0.0.0.0/0"
   }
   
   resource "mongodbatlas_database_user" "main" {
     project_id = var.mongodbatlas_project_id
      
     username           = "awala-endpoint"
     password           = random_password.mongodb_user_password.result
     auth_database_name = "admin"
   
     roles {
       role_name     = "readWrite"
       database_name = local.mongodb_db_name
     }
   }
   
   resource "random_password" "mongodb_user_password" {
     length = 32
   }
   ```
2. Store the public and private keys in `aie-gcp/infrastructure/terraform.tfvars`, as follows:
   ```
   mongodbatlas_public_key  = "<YOUR-PUBLIC-KEY>"
   mongodbatlas_private_key = "<YOUR-PRIVATE-KEY>"
   mongodbatlas_project_id  = "<YOUR-MONGODB-ATLAS-PROJECT-ID>"
   ```

Finally, get Terraform to complete the setup:

```shell
terraform apply
```

It should normally take around 3 minutes for Terraform to complete the setup.

### 4. Deploy the Awala Internet Endpoint

Now that your GCP and MongoDB Atlas projects are properly configured, we're ready to deploy the [Awala Internet Endpoint (AIE)](https://docs.relaycorp.tech/awala-endpoint-internet/) using [its Terraform module for GCP](https://registry.terraform.io/modules/relaycorp/awala-endpoint/google/latest):

1. Create the file `aie-gcp/infrastructure/endpoint.tf` with the following content:
   ```hcl
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

   ```
2. Specify your DNS configuration in `aie-gcp/infrastructure/terraform.tfvars` by setting: `internet_address` (the _Awala Internet address_ of your endpoint; e.g., `your-company.com`) and `pohttp_server_domain` (the domain name of your endpoint's HTTP server; e.g., `awala.your-company.com`):
   ```hcl
   internet_address     = "your-company.com"
   pohttp_server_domain = "awala.your-company.com"
   ```
   
   Tip: The Awala Internet address of your endpoint is what Awala users actually see, so you want to set it to something they'd recognise.

Now use Terraform to deploy the AIE:

```shell
terraform init   # Run again to get the AIE module
terraform apply  # Should take ~3 minutes
```

Use the outputs from the command above to complete the remaining steps by hand:

1. Go to your DNS provider to add the following records:
   - `A` record for the HTTP server, whose IPv4 address can be found in the output `pohttp_server_ip_address`.
   - `SRV` record for your Awala Internet address, which should point to the `A` record above. For example:
     ```
     _awala-pdc._tcp.your-company.com. 3600 IN SRV 0 0 443 awala.your-company.com.
     ```
2. Go to the [Cloud Run jobs console](https://console.cloud.google.com/run/jobs) and manually execute the job specified in the output `bootstrap_job_name`.
   ![cloud-run-jobs.png](assets/gcp-cloudrun-job-exec.png)

### 5. Implement your app

### 6. Deploy your app

### 7. Test your app

## Clean up

Run `terraform destroy` to destroy all the billable resources you created. For good measure, you should also:

1. Go to the [GCP Resource Manager](https://console.cloud.google.com/cloud-resource-manager) and delete the GCP project you created.
2. Delete the [MongoDB Atlas](https://cloud.mongodb.com/v2) project you created.
3. Delete the GCP credentials file from your disk.

Finally, delete the directory `aie-gcp` and the DNS `SRV` record you created.

## What's next?
