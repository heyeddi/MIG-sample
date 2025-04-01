variable "project_id" {
  type        = string
  description = "Project ID"
}

variable "database_name" {
  type        = string
  description = "Name for the database"
  default = "mig-database"
}

variable "registry_name" {
  type        = string
  description = "Artifact registry name"
}

variable "image_name" {
  type        = string
  description = "Docker Image name and tag"
}

variable "db_password" {
  type        = string
  ephemeral   = true
  description = "Database password"
}
