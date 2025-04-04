# Simple Python App

A FastAPI application that provides a REST API to manage content in a PostgreSQL database. The application is designed to run on Google Cloud Platform (GCP) and connect to a Cloud SQL instance.

## Features

- REST API with CRUD operations for content
- Google Cloud SQL PostgreSQL database integration
- Secret Manager integration for secure credential management
- Containerized with Docker
- Deployable to GCP
- Health check endpoint

## Prerequisites

- Python 3.12 or higher
- Poetry for dependency management
- Docker for containerization
- Access to a Google Cloud Platform project
- A Cloud SQL PostgreSQL instance
- Secret Manager with database password stored

## Setup

1. Clone the repository:
   ```
   git clone [repository-url]
   cd simple-python-app
   ```

2. Install dependencies:
   ```
   poetry install
   ```

3. Generate requirements.txt (for Docker build):
   ```
   poe reqs
   ```

## Configuration

The application connects to a Cloud SQL instance with the following configuration (defined in `app.py`):

- Project ID: `eddi-sample-project`
- Region: `us-east1`
- Instance Name: `mig-database`
- Database Name: `mig-database`
- Secret Name: `mig-db-password` (used to retrieve database password)
- IP Type: Configurable via `PUBLIC_IP` environment variable (public or private IP)

Update these values in the code to match your GCP setup.

## Running Locally

Start the server using poethepoet:

```
poe serve
```

The API will be available at `http://localhost:5000`

## API Endpoints

- `POST /content/`: Create new content
- `GET /content/`: List all content (with pagination)
- `GET /content/{content_id}`: Get a specific content item by ID
- `DELETE /content/{content_id}`: Delete a specific content item by ID
- `GET /health`: Health check endpoint that returns status

### Sample cURL Commands
```bash
# Create new content
curl -X POST http://localhost:5000/content/ \
  -H "Content-Type: application/json" \
  -d '{"content": "This is sample content"}'

# List all content
curl -X GET "http://localhost:5000/content/"

# Get a specific content item by ID
curl -X GET http://localhost:5000/content/1

# Delete a specific content item by ID
curl -X DELETE http://localhost:5000/content/1

# Health check
curl -X GET http://localhost:5000/health
```

## Docker

### Building and Pushing the Docker Image

```
poe deploy-docker
```

This command builds the Docker image and pushes it to GCP Artifact Registry.

## Cloud Deployment

The application is designed to be deployed to Google Cloud Platform and connect to a Cloud SQL instance using IAM authentication.

Make sure your service account has the necessary permissions to:
- Connect to the Cloud SQL instance
- Read/write to the database
- Access Secret Manager secrets

## Project Structure

- `src/simple_python_app/app.py`: Main application code
- `Dockerfile`: Docker configuration
- `pyproject.toml`: Poetry configuration and dependencies
- `requirements.txt`: Generated requirements for Docker

## Dependencies

- FastAPI: Web framework
- SQLModel: SQL database interface
- Google Auth: GCP authentication
- Google Cloud SQL Connector: For database connections
- Google Cloud Secret Manager: For secure credential management
- pg8000: PostgreSQL driver
- Poetry: Dependency management
- PoetHePoet: Task runner
