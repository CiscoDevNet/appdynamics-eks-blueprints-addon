# Variables ----------------------------------------------------------------------------------------
variable "aws_region" {
  description = "AWS region."
  type        = string
  default     = "us-east-2"
}

variable "aws_eks_cluster_name" {
  description = "AWS EKS Cluster name."
  type        = string
}

variable "resource_environment_home_tag" {
  description = "Resource environment home tag."
  type        = string
  default     = "AppDynamics EKS Blueprints Addon - Addon"
}

variable "resource_project_tag" {
  description = "Resource project tag."
  type        = string
  default     = "AppDynamics EKS Blueprints Addon"
}

variable "cnao_client_id" {
  description = "Defines the client ID for authenticating with Cloud Native Application Observability."
  type        = string
  sensitive   = true
}

variable "cnao_client_secret" {
  description = "Defines the secret string in plaintext for authenticating with Cloud Native Application Observability."
  type        = string
  sensitive   = true
}

variable "cnao_cluster_name" {
  description = "The name of the cluster that is displayed in the UI."
  type        = string
}

variable "cnao_collector_endpoint" {
  description = "Defines the endpoint the collector uses to send data for the Appdynamics Collectors."
  type        = string
}

variable "cnao_operators_endpoint" {
  description = "Defines the endpoint the collector uses to send data for the Appdynamics Operators."
  type        = string
}

variable "cnao_install_log_collector" {
  description = "Set this option to 'true' to install log collector monitoring (default is 'true')."
  type        = string
  default     = "true"
}

variable "cnao_tenant_id" {
  description = "Tenant ID for the AppDynamics Cloud Native Application Observability tenant."
  type        = string
}

variable "cnao_token_url" {
  description = "Authentication token for the AppDynamics Cloud Native Application Observability tenant."
  type        = string
  sensitive   = true
}