# MIG-Sample Project

## Overview

This project demonstrates how to deploy a simple Python FastAPI application on Google Cloud Platform (GCP) using Managed Instance Groups (MIG) for scalability and high availability. The application connects to a Cloud SQL PostgreSQL database and is exposed through a global HTTP load balancer.

## Architecture

The architecture consists of:

- **Simple Python FastAPI Application**: A REST API that performs CRUD operations on a database
- **Google Cloud SQL**: PostgreSQL database for data storage
- **Managed Instance Group**: Auto-scaling VM instances running the containerized application
- **Global Load Balancer**: HTTP load balancer for traffic distribution
- **VPC Network**: Private network for secure communication
- **Artifact Registry**: For storing Docker images
- **Secret Manager**: Securely storing database credentials

## Project Structure

```
MIG-sample/
├── .env               # Environment variables for local development
├── simple-python-app  # Python FastAPI application code
└── terraform-configs  # Infrastructure as code
    ├── gcp-project    # GCP project setup
    ├── backend-bucket # Terraform state storage
    ├── artifact-registry # Docker image repository
    └── MIG            # Managed Instance Group and related resources
```

## Setup Instructions

1. **Prerequisites**
   - Google Cloud Platform account with billing enabled
   - Terraform installed (v1.11.1+)
   - Docker installed
   - gcloud CLI configured

2. **Initial Setup**
   ```bash
   # Configure environment variables
   cp .env_sample .env
   # Edit .env with your values
   ```

3. **Create Infrastructure**
   ```bash
   # Initialize and apply Terraform for project setup
   cd terraform-configs/gcp-project
   terraform init
   terraform apply

   # Set up storage bucket for Terraform state
   cd ../backend-bucket
   terraform init
   terraform apply

   # Set up Artifact Registry
   cd ../artifact-registry
   terraform init
   terraform apply

4. **Build and Push Docker Image**
   ```bash
   cd ../../simple-python-app
   poetry install
   # Build and push Docker image
   poetry run poe deploy-docker
   ```

5. **Deploy Application**
   ```bash
   cd ../terraform-configs/MIG
   terraform init
   terraform apply
   ```

6. **Accessing the Application**

   After deployment completes, you can access the application at the Load Balancer IP address:
   ```bash
   terraform output load_balancer_ip
   ```

## Development

To run the application locally:

```bash
cd simple-python-app
cp docker.env.sample docker.env
# Fill in the variables
poetry install
poetry run run-docker
```

## Cleanup

To destroy all resources when done:

```bash
cd terraform-configs/MIG
terraform destroy

cd ../artifact-registry
terraform destroy

cd ../backend-bucket
terraform destroy

cd ../gcp-project
terraform destroy
```

## LIVE DEMO
Here are some example commands to interact with the live API:

### Health Check
```bash
curl http://35.241.20.250:80/health
```

### Create Content
```bash
curl -X POST http://35.241.20.250:80/content/ \
     -H "Content-Type: application/json" \
     -d '{"content": "This is a test message"}'
```

### List All Content
```bash
curl http://35.241.20.250:80/content/
```

### Get Specific Content by ID
```bash
curl http://35.241.20.250:80/content/1
```

### Delete Content by ID
```bash
curl -X DELETE http://35.241.20.250:80/content/1
```
