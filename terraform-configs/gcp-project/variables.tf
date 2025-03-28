variable "billing_account_id" {
  type        = string
  description = "The ID of the billing account to associate with the project."
}

variable "project_id" {
  type        = string
  description = "GCP Project ID"
}

variable "project_name" {
  type        = string
  description = "GCP Friendly project name"
}
