# aws-deployment
This repository contains scripts and configurations for deploying applications to AWS. It includes IaC for services like EC2, ECS, Lambda, S3, and RDS. Ideal for automating AWS deployments, it ensures scalability, security, and efficiency. Suitable for both simple and complex AWS architectures.

# Terraform Setup and Execution Guide

This guide provides detailed steps to set up and execute the Terraform configuration using AWS credentials defined in a `terraform.tfvars` file. Follow these instructions to deploy the infrastructure defined in the Terraform script.

## Prerequisites

Before you begin, ensure you have the following:

- **Terraform CLI** installed on your local machine. You can download it from [here](https://www.terraform.io/downloads.html). or from [here](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

## Step 1: Clone the Repository or Setup the Terraform Files

Ensure that your Terraform files (`main.tf`, `variables.tf`, `terraform.tfvars`, etc.) are in the same directory. If you've cloned a repository, navigate to the project directory.

## Step 2: Create the `terraform.tfvars` File

In the root of your project directory, create a file named `terraform.tfvars`. This file will store your AWS credentials and region information.
If you want create then you can create by using below connads
```
touch main.tf
touch terraform.tfvars
```

Example `terraform.tfvars`:

```hcl
aws_access_key    = "your-access-key"
aws_secret_key    = "your-secret-key"
aws_session_token = "your-session-token"  # Optional if using temporary credentials
aws_region        = "us-west-2"
```

## Important Notes:
Session Token: If you are using temporary credentials (like those obtained through aws sts assume-role), ensure the aws_session_token is also included.

## Step 3: Initialize Terraform

In the project directory, run the following command to initialize Terraform. This command downloads the necessary provider plugins and sets up the working directory.

```
terraform init
```

## Step 4: Plan Your Terraform Deployment

Run the following command to generate and review the execution plan. This command shows what actions Terraform will take to achieve the desired state described in your configuration files.

```
terraform plan
```
for saving output into the file
```
terraform plan -out output.txt
```
And your output should looks like below for correct terraform script


# Terraform Plan Output Example

```
data.aws_vpc.default: Reading...
data.aws_vpc.default: Read complete after 3s [id=vpc-b06168c8]
data.aws_vpc.selected: Reading...
data.aws_vpc.selected: Read complete after 2s [id=vpc-b06168c8]
data.aws_security_group.default: Reading...
data.aws_subnets.selected: Reading...
data.aws_subnets.selected: Read complete after 0s [id=us-west-2]
data.aws_subnet.default_subnet_a: Reading...
data.aws_subnet.default_subnet_b: Reading...
data.aws_subnet.default_subnet_c: Reading...
data.aws_subnet.default_subnet_d: Reading...
data.aws_security_group.default: Read complete after 0s [id=sg-9d05f296]
data.aws_security_group.selected: Reading...
data.aws_subnet.default_subnet_c: Read complete after 1s [id=subnet-407ffb0a]
data.aws_subnet.default_subnet_a: Read complete after 1s [id=subnet-62d03d48]
data.aws_subnet.default_subnet_b: Read complete after 1s [id=subnet-2acc5652]
data.aws_security_group.selected: Read complete after 2s [id=sg-9d05f296]
data.aws_subnet.default_subnet_d: Read complete after 2s [id=subnet-e3bfcabe]

Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_cloudfront_cache_policy.custom_ui_policy will be created
  + resource "aws_cloudfront_cache_policy" "custom_ui_policy" {
      + default_ttl = 3600
      + etag        = (known after apply)
      + id          = (known after apply)
      + max_ttl     = 86400
      + min_ttl     = 0
      + name        = "CustomUIPolicy"

.....................
```

This output confirms that Terraform is correctly reading your configuration and preparing to apply the changes.

## Step 5: Apply the Terraform Plan
If the plan looks good, you can apply it by running:

```
terraform apply
```

This command will execute the actions necessary to create, update, or delete resources in your AWS account as described by your Terraform configuration.

### Step 6: Verify the Deployment

After the terraform apply command completes, verify that the resources were created successfully in the AWS Management Console.

### Step 8: Clean Up

To clean up and destroy the infrastructure created by Terraform, run:

```
terraform destroy
```

This will remove all resources defined in your Terraform configuration from your AWS account.

