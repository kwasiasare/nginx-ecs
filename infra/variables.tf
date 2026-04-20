variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-nginx-ecs"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "East US"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "nginx-ecs"
}

variable "container_image" {
  description = "Container image to deploy"
  type        = string
  default     = "nginx:latest"
}

variable "ssl_certificate_name" {
  description = "Name of SSL certificate in Key Vault"
  type        = string
  default     = "ssl-cert"
}

variable "domain_name" {
  description = "Custom domain name (optional)"
  type        = string
  default     = ""
}