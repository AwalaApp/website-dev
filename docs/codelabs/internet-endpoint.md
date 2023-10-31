---
nav_order: 1
permalink: /codelabs/internet-endpoint
parent: Codelabs
---

# Build and deploy a server-side app

## What you'll achieve

You'll build and deploy a simply server-side app that sends and receives data via Awala. Think of it as a "Hello world" tutorial -- the app itself will be trivial, and most of the instructions are about deploying it to the cloud.

Awala-compatible, server-side apps can be written in any language and deployed to any platform, but this codelab will only use examples in Node.js and Kotlin on [Google Cloud Platform](https://cloud.google.com/).

You shouldn't need more than 20 minutes to complete the codelab, once the pre-requisites are met.

## Pre-requisites

- Familiarity with either Node.js or Kotlin (we may add more examples in the future).
- [Terraform](https://developer.hashicorp.com/terraform/downloads) 1.5 or newer.
- A domain name with DNSSEC correctly configured.
- A [Google Cloud Platform](https://cloud.google.com/) account with billing configured.
- A [MongoDB Atlas](https://www.mongodb.com/atlas/database) account with billing configured.
- An Android device, so you can test your app end-to-end.

## Estimated costs

To the best of our knowledge, this codelab _shouldn't_ cost anything if you're able to use the free tier of GCP and MongoDB Atlas -- otherwise, it _should_ cost less than $4/day or a few cents per minute as of this writing.

Having said this, you're solely responsible for any costs incurred whilst following this codelab. We're only offering an estimate based on our own experience, not a guarantee.

Make sure to [clean up at the end](#clean-up) to avoid incurring in further costs.

## Troubleshooting

If something doesn't work as expected at any time, [check out the final code](https://github.com/AwalaNetwork/website-dev/tree/main/codelabs/internet-endpoint/) or [ask for help](../help.md).

## Steps

### 1. Create and configure a new GCP project

1. [Create a new project from the GCP Console](https://console.cloud.google.com/projectcreate).
2. [Create a new service account](https://console.cloud.google.com/iam-admin/serviceaccounts/create) with the _Owner_ (`roles/owner`) role.
3. Go to the "Keys" tab for the service account you just created, and create a new key in JSON format.
   ![gcp-sa-key.png](assets/gcp-sa-key.png)
4. Save the JSON file.

### 2. Create and configure a new MongoDB Atlas project

1. Create a new project from [the MongoDB Atlas console](https://cloud.mongodb.com/v2).
2. Go to the Access Management section of your newly-created project.
   ![mongodbatlas-access-manager.png](assets/mongodbatlas-access-manager.png)
3. Create an API key with the _Project Owner_ role.
   ![mongodbatlas-api-key-role.png](assets/mongodbatlas-api-key-creation.png)
4. Copy the public and private keys to a safe place.

### 3. Deploy the Awala Internet Endpoint

### 4. Implement your app

### 5. Deploy your app

### 6. Test your app

## Clean up

Run `terraform destroy` to destroy all the billable resources you created. For good measure, you should also:

1. Go to the [GCP Resource Manager](https://console.cloud.google.com/cloud-resource-manager) and delete the GCP project you created.
2. Delete the MongoDB Atlas project you created.
3. Delete the GCP credentials file from your disk.

Finally, delete the DNS `SRV` record you created.

## What's next?
