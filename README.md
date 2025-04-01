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

### Decisions and notes

- I went with Instance Groups because Autoscaling was mentioned, and It had to be GCE, otherwise I would have used Cloud Run, which had a native integration with CloudSQL, it would have been way simpler.
- I put the MIG and CloudSQL in the VPC, so no one can access those from outside the subnetwork, so secure and simple.
- For the Firewall, I allowed only the GCE Port and SSH port
- For DB, I mendtioned, I went with CloudSQL, it's a simple MySQL and Posgre compatible managed db.
- To deploy code I decided a docker image in a GCP Artifact registry would be simple.
- To allow secure access, I used IAP, and a firewal rule to allow ingress trafic from known IAP ips
  - all you have to do is sue this command `gcloud compute ssh INSTANCE_NAME --tunnel-through-iap --project=PROJECT --zone=ZONE`, you will be loggedin
- I did not setup logging, monitoring, alerts, etc. Decided taht was too much for this demo.

### Challenges and Lessons

During developement I faced a few issues, I had fun and learned a lot.

- IAM users in CloudSQL do not have access to Create Tables, or Write data
  - The way to fix that is to login to the DB and grant rights to the user, which is not a pretty process.
  - Hence, I decided to switch the approach and create a normal CloudSQL user whiuch logins with a user and password
  - Once that was done, the project flow was better, and I observed security by not storing the password on the Terraform State or log file
- A simple Python APP is not as simple when on the cloud.
  - I implemented CloudSQL connector and reading the db pasword  from Secret Manager.
  I have to say I did copy most of  the code, but to make it work with CloudSQL I had to adapt it, I left links of documents I read throught the project.
- To make this simpler as a devlopent process, I would have used Terraform Workspaces, to have a `Dev` and `Prod` environments, with different configurations, I got stuck a few times but I was too deep to implement workspaces, I handled with temporary settings and environment variables, even with some custom config I deleted the end.

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
