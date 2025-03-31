# Simple Python App

A FastAPI application that provides a REST API to manage content in a PostgreSQL database. The application is designed to run on Google Cloud Platform (GCP) and connect to a Cloud SQL instance.

## Features

- REST API with CRUD operations for content
- Google Cloud SQL PostgreSQL database integration
- Containerized with Docker
- Deployable to GCP

## Prerequisites

- Python 3.12 or higher
- Poetry for dependency management
- Docker for containerization
- Access to a Google Cloud Platform project
- A Cloud SQL PostgreSQL instance

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

## Project Structure

- `src/simple_python_app/app.py`: Main application code
- `Dockerfile`: Docker configuration
- `pyproject.toml`: Poetry configuration and dependencies
- `requirements.txt`: Generated requirements for Docker

## Dependencies

- FastAPI: Web framework
- SQLModel: SQL database interface
- Google Auth: GCP authentication
- pg8000: PostgreSQL driver
- Poetry: Dependency management
- PoetHePoet: Task runner
```
