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

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.


# Deploy Angular to AWS S3 and CloudFront

This GitHub Action automates the process of deploying an Angular application to an S3 bucket and invalidating the CloudFront cache whenever there is a push to the `develop` branch.

## Overview

This workflow is triggered by a push to the `develop` branch. It checks out the code, installs dependencies, builds the Angular project, and then uploads the build artifacts to an S3 bucket. Finally, it invalidates the CloudFront cache to ensure the latest version of the application is served.

## Workflow Steps

1. **Checkout Code**: The workflow checks out the latest version of the code from the `develop` branch.

2. **Set up Node.js**: It sets up the Node.js environment, specifically using version 14, which is required for building the Angular application.

3. **Install Dependencies**: The workflow installs all the necessary dependencies using `npm install`.

4. **Build Angular App**: It builds the Angular application using the `npm run buildstaging` command. This command should be configured in your `package.json` to build the application for the staging environment.

5. **Upload to S3**: The build artifacts are uploaded to the specified S3 bucket. The `--delete` argument ensures that any files in the S3 bucket that are not part of the current build are removed.

6. **Configure AWS Credentials**: AWS credentials are configured to allow the workflow to interact with AWS services.

7. **Invalidate CloudFront Cache**: The workflow invalidates the CloudFront cache, ensuring that the latest version of the application is delivered to users.

## Prerequisites

- **AWS S3 Bucket**: You must have an S3 bucket set up to host the Angular application.
- **CloudFront Distribution**: A CloudFront distribution should be configured to serve the content from the S3 bucket.
- **AWS Credentials**: AWS Access Key and Secret Key must be stored as secrets in your GitHub repository.

## Environment Variables and Secrets

- `TEST_AWS_S3_BUCKET`: The name of the S3 bucket where the Angular application will be deployed.
- `TEST_AWS_ACCESS_KEY_ID`: AWS Access Key ID with permission to upload to the S3 bucket and invalidate the CloudFront distribution.
- `TEST_AWS_SECRET_ACCESS_KEY`: AWS Secret Access Key associated with the Access Key ID.
- `TEST_DISTRIBUTION_ID`: The CloudFront Distribution ID that serves the Angular application.

## Usage

This workflow is set to run automatically on every push to the `develop` branch. To set up this workflow in your own repository, add the following YAML code to a file named `.github/workflows/deploy.yml`:

```yaml
name: Deploy Angular to AWS S3 and CloudFront

on:
  push:
    branches:
      - develop

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v2

      - name: Set up Node.js
        uses: actions/setup-node@v2
        with:
          node-version: '14'

      - name: Install dependencies
        run: npm install

      - name: Build Angular app
        run: npm run buildstaging

      - name: Upload to S3
        uses: jakejarvis/s3-sync-action@v0.5.1
        with:
          args: --delete
        env:
          AWS_S3_BUCKET: ${{ vars.TEST_AWS_S3_BUCKET }}
          aws-access-key-id: ${{ secrets.TEST_AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.TEST_AWS_SECRET_ACCESS_KEY }}
          SOURCE_DIR: 'dist/'  # Adjust according to your project
    
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v1
        with:
          aws-access-key-id: ${{ secrets.TEST_AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.TEST_AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ vars.TEST_AWS_REGION }}
  
      - name: Invalidate CloudFront cache
        run: aws cloudfront create-invalidation --distribution-id ${{ vars.TEST_DISTRIBUTION_ID }} --paths "/*"
```
## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.


# Deploy Springboot Application to AWS ECS

This GitHub Action automates the process of deploying a Java Spring Boot application to Amazon Elastic Container Service (ECS) using Docker. The workflow is triggered by a push to the `develop` branch, builds the application using Maven, creates a Docker image, and then updates the ECS service with the new image.

## Workflow Steps

1. **Checkout Code**: The workflow checks out the latest version of the code from the `develop` branch.

2. **Set up JDK 11**: It sets up the Java Development Kit (JDK) version 11 using the Temurin distribution, which is required to build the Spring Boot application.

3. **Build with Maven**: The workflow builds the Spring Boot application using Maven with the `test` profile and skips the tests. The output is a packaged `.jar` file.

4. **Log in to Docker Hub**: The workflow logs into Docker Hub using the credentials stored in GitHub Secrets.

5. **Build Docker Image**: It builds a Docker image for the application using the Dockerfile in the repository. The image is tagged with the release version specified in the workflow variables.
   ## Dockerfile
```
# Use an official base image
FROM openjdk:11-jdk-slim

# Install tini
RUN apt-get update && apt-get install -y tini

# Set the working directory in the container
WORKDIR /yourApp

# Copy the jar file to the container
COPY target/yourApp-0.0.1-SNAPSHOT.jar yourApp.jar

# Expose the port your application will run on
EXPOSE 5000

# Set tini as entrypoint
ENTRYPOINT ["/usr/bin/tini", "--", "java", "-jar", "yourApp.jar"]
```

7. **Push Docker Image to Docker Hub**: The Docker image is pushed to Docker Hub, making it available for deployment.

8. **Configure AWS Credentials**: AWS credentials are configured to allow the workflow to interact with AWS services.

9. **Update ECS Service**: The workflow updates the ECS service with the new Docker image, forces a new deployment, and enables deployment circuit breakers for rollback in case of deployment failure.

## Prerequisites

- **AWS ECS Cluster and Service**: You must have an ECS cluster and service set up to deploy the application.
- **Docker Hub Account**: A Docker Hub account to push the Docker image.
- **AWS Credentials**: AWS Access Key and Secret Key must be stored as secrets in your GitHub repository.

## Environment Variables and Secrets

- `DOCKER_USERNAME`: Docker Hub username.
- `DOCKER_PASSWORD`: Docker Hub password.
- `RELEASE_VERSION`: The version tag for the Docker image.
- `TEST_AWS_ACCESS_KEY_ID`: AWS Access Key ID with permission to update the ECS service.
- `TEST_AWS_SECRET_ACCESS_KEY`: AWS Secret Access Key associated with the Access Key ID.
- `TEST_AWS_REGION`: AWS region where the ECS cluster is located.
- `TEST_ECS_SERVICE_NAME`: Name of the ECS service to be updated.
- `TEST_ECS_CLUSTER_NAME`: Name of the ECS cluster where the service is running.
- `TEST_ECS_TASK_NAME`: Name of the ECS task definition to be updated.

## Usage

This workflow is set to run automatically on every push to the `develop` branch. To set up this workflow in your own repository, add the following YAML code to a file named `.github/workflows/deploy.yml`:

```yaml
name: Deploy to AWS ECS

on:
  push:
    branches:
      - develop

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v2

      - name: Set up JDK 11
        uses: actions/setup-java@v2
        with:
          java-version: 11
          distribution: temurin

      - name: Build with Maven
        run: mvn clean package -P test -DskipTests

      - name: Log in to Docker Hub
        run: echo "${{ secrets.DOCKER_PASSWORD }}" | docker login -u "${{ secrets.DOCKER_USERNAME }}" --password-stdin

      - name: Build Docker image
        run: docker build -t ${{ secrets.DOCKER_USERNAME }}/propertystore:${{ vars.RELEASE_VERSION }} .

      - name: Push Docker image to Docker Hub
        run: docker push ${{ secrets.DOCKER_USERNAME }}/propertystore:${{ vars.RELEASE_VERSION }}

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v1
        with:
          aws-access-key-id: ${{ secrets.TEST_AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.TEST_AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ vars.TEST_AWS_REGION }}

      - name: Update ECS service
        run: |
          set -e
          SERVICE_NAME="${{ vars.TEST_ECS_SERVICE_NAME }}"
          CLUSTER_NAME="${{ vars.TEST_ECS_CLUSTER_NAME }}"
          aws ecs update-service \
                --cluster $CLUSTER_NAME \
                --service $SERVICE_NAME \
                --task-definition ${{ vars.TEST_ECS_TASK_NAME }} \
                --force-new-deployment \
                --deployment-configuration "deploymentCircuitBreaker={enable=true,rollback=true}"
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.


# Deploy Nodejs Application to AWS EC2

This GitHub Action automates the deployment of a Node.js application to an AWS EC2 instance. The workflow is triggered by a push to the `master` branch. It checks out the code, installs dependencies, builds the project, and deploys it to the specified EC2 instance using SSH and PM2 for process management.

## Workflow Overview

1. **Checkout Code**: The workflow checks out the latest version of the code from the `master` branch.

2. **Setup Node.js**: It sets up Node.js version 20 to install dependencies and build the project.

3. **Install Dependencies**: The workflow installs the project's dependencies using `npm install`.

4. **Build the Project**: The project is built using `npm run build`, producing the necessary production files.

5. **Create Environment File**: An environment file (`production.env`) is created using secrets from GitHub. This file contains configuration values such as database credentials, JWT keys, and other environment variables.

6. **Configure SSH**: SSH configuration is set up by creating a secure key pair to authenticate with the EC2 instance.

7. **Test SSH Connection**: The workflow tests the SSH connection to ensure the EC2 instance is accessible.

8. **Transfer Environment File to EC2**: The generated `production.env` file is securely copied to the EC2 instance.

9. **Deploy to EC2**: The project is deployed to the EC2 instance by navigating to the project directory, pulling the latest code, installing dependencies, building the project, and starting the application using PM2.

10. **Check PM2 Status**: The workflow checks the status of the PM2 process to ensure the application is running successfully.

## Environment Variables and Secrets

- `PORT`: The port number on which the application will run.
- `HOST`: The host name or IP address of the server.
- `NODE_ENV`: The environment mode (e.g., production).
- `APP_KEY`: The application secret key.
- `APP_VER`: The application version.
- `DRIVE_DISK`: The drive disk setting.
- `DB_CONNECTION`: The database connection type (e.g., MySQL).
- `MYSQL_HOST`: The MySQL database host.
- `MYSQL_PORT`: The MySQL database port.
- `MYSQL_USER`: The MySQL database user.
- `MYSQL_PASSWORD`: The MySQL database password.
- `MYSQL_DB_NAME`: The MySQL database name.
- `JWT_PRIVATE_KEY`: The JWT private key.
- `JWT_PUBLIC_KEY`: The JWT public key.
- `SSH_PRIVATE_KEY`: The private SSH key for connecting to the EC2 instance.
- `GH_PAT`: GitHub Personal Access Token for cloning the repository.

## Setup Instructions

1. **Ensure AWS EC2 Instance is Running**: The EC2 instance should be set up and running with SSH access.

2. **Store Secrets in GitHub**: Store all the required secrets (listed above) in your GitHub repository under "Settings > Secrets and variables > Actions".

3. **Set Up PM2 on EC2**: Make sure PM2 is installed on your EC2 instance to manage the Node.js application process.

4. **Configure the Workflow File**: Add the workflow YAML file to your repository at `.github/workflows/deploy.yml`.

## Running the Workflow

This workflow runs automatically when a push is made to the `master` branch. The workflow will connect to the EC2 instance, deploy the latest code, and start the application using PM2.

```
name: Deploy to AWS EC2

on:
  push:
    branches:
      - master

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout code
      uses: actions/checkout@v3

    - name: Setup Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '20'

    - name: Install dependencies
      run: npm install

    - name: Build the project
      run: npm run build

    - name: Create env file
      run: |
        echo PORT=${{ secrets.PORT }} >> production.env
        echo HOST=${{ secrets.HOST }} >> production.env
        echo NODE_ENV=production >> production.env
        echo APP_KEY=${{ secrets.APP_KEY }} >> production.env
        echo APP_VER=${{ secrets.APP_VER }} >> production.env
        echo DRIVE_DISK=${{ secrets.DRIVE_DISK }} >> production.env
        echo DB_CONNECTION=${{ secrets.DB_CONNECTION }} >> production.env
        echo MYSQL_HOST=${{ secrets.MYSQL_HOST }} >> production.env
        echo MYSQL_PORT=${{ secrets.MYSQL_PORT }} >> production.env
        echo MYSQL_USER=${{ secrets.MYSQL_USER }} >> production.env
        echo MYSQL_PASSWORD=${{ secrets.MYSQL_PASSWORD }} >> production.env
        echo MYSQL_DB_NAME=${{ secrets.MYSQL_DB_NAME }} >> production.env
        echo -e "JWT_PRIVATE_KEY=\"${{ secrets.JWT_PRIVATE_KEY }}\"" >> production.env
        echo -e "JWT_PUBLIC_KEY=\"${{ secrets.JWT_PUBLIC_KEY }}\"" >> production.env
        cat production.env  # Print the file content for debugging purposes
      env:
        PORT: ${{ secrets.PORT }}
        HOST: ${{ secrets.HOST }}
        NODE_ENV: "production"
        APP_KEY: ${{ secrets.APP_KEY }}
        APP_VER: ${{ secrets.APP_VER }}
        DRIVE_DISK: ${{ secrets.DRIVE_DISK }}
        DB_CONNECTION: ${{ secrets.DB_CONNECTION }}
        MYSQL_HOST: ${{ secrets.MYSQL_HOST }}
        MYSQL_PORT: ${{ secrets.MYSQL_PORT }}
        MYSQL_USER: ${{ secrets.MYSQL_USER }}
        MYSQL_PASSWORD: ${{ secrets.MYSQL_PASSWORD }}
        MYSQL_DB_NAME: ${{ secrets.MYSQL_DB_NAME }}
        JWT_PRIVATE_KEY: ${{ secrets.JWT_PRIVATE_KEY }}
        JWT_PUBLIC_KEY: ${{ secrets.JWT_PUBLIC_KEY }}

    - name: Configure SSH
      run: |
        mkdir -p ~/.ssh
        echo "${{ secrets.SSH_PRIVATE_KEY }}" > ~/.ssh/id_rsa
        chmod 600 ~/.ssh/id_rsa
        ssh-keyscan -H ${{ vars.EC2_HOST }} >> ~/.ssh/known_hosts

    - name: Test SSH Connection
      run: |
        ssh -i ~/.ssh/id_rsa ${{ vars.EC2_USER }}@${{ vars.EC2_HOST }} "echo SSH connection test successful"

    - name: Transfer env file to EC2
      run: |
        scp -i ~/.ssh/id_rsa production.env ${{ vars.EC2_USER }}@${{ vars.EC2_HOST }}:/home/ubuntu/folder/your-app/production.env

    - name: Deploy to EC2
      uses: appleboy/ssh-action@v0.1.5
      with:
        host: ${{ vars.EC2_HOST }}
        username: ${{ vars.EC2_USER }}
        key: ${{ secrets.SSH_PRIVATE_KEY }}
        script: |
          set -e  # Exit on any error
          set -x  # Print each command before executing it
          echo "Stopping and deleting all existing PM2 processes"
          pm2 delete all || true  # Ensure any previous PM2 processes are stopped and deleted
          echo "Navigating to the application directory"
          cd /home/ubuntu/folder
          echo "Checking for the repository"
          if [ -d "jps-adonis" ]; then
            echo "Repository found. Pulling the latest changes."
            cd jps-adonis
            git pull origin master
          else
            echo "Repository not found. Cloning the repository."
            git clone https://${{ secrets.GH_PAT }}@github.com/user-name/your-repo.git jps-adonis
            cd jps-adonis
          fi
          # echo "Moving the env file to the application directory"
          mv /home/ubuntu/folder/your-app/production.env .env
          echo "Installing dependencies"
          npm install
          echo "Building the project"
          npm run build
          echo "Managing the application process with PM2"
          pm2 start build/server.js --name your-app
    - name: Check PM2 Status
      uses: appleboy/ssh-action@v0.1.5
      with:
        host: ${{ vars.EC2_HOST }}
        username: ${{ vars.EC2_USER }}
        key: ${{ secrets.SSH_PRIVATE_KEY }}
        script: |
            pm2 describe your-app

```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.



