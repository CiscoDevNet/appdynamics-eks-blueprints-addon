/**
 * Copyright 2023 Cisco Systems, Inc. and its affiliates
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

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
  default     = "Cisco Cloud Observability EKS Blueprints Addon - Addon"
}

variable "resource_project_tag" {
  description = "Resource project tag."
  type        = string
  default     = "Cisco Cloud Observability EKS Blueprints Addon"
}

variable "cco_client_id" {
  description = "Defines the client ID for authenticating with Cisco Cloud Observability."
  type        = string
  sensitive   = true
}

variable "cco_client_secret" {
  description = "Defines the secret string in plaintext for authenticating with Cisco Cloud Observability."
  type        = string
  sensitive   = true
}

variable "cco_cluster_name" {
  description = "The name of the cluster that is displayed in the UI."
  type        = string
}

variable "cco_collector_endpoint" {
  description = "Defines the endpoint the collector uses to send data for the Appdynamics Collectors."
  type        = string
}

variable "cco_operators_endpoint" {
  description = "Defines the endpoint the collector uses to send data for the Appdynamics Operators."
  type        = string
}

variable "cco_tenant_id" {
  description = "Tenant ID for the Cisco Cloud Observability tenant."
  type        = string
}

variable "cco_token_url" {
  description = "Authentication token for the Cisco Cloud Observability tenant."
  type        = string
  sensitive   = true
}

variable "cco_security_monitoring_enabled" {
  description = "Set to 'true' if Security Monitoring is enabled."
  type        = bool
  default     = false
}

variable "cco_shared_secret" {
  description = "Defines the secret string in plaintext for authenticating with Cisco Secure Application."
  type        = string
  default     = ""
  sensitive   = true
}

variable "cco_agent_id" {
  description = "Defines the agent ID for authenticating with Cisco Secure Application."
  type        = string
  default     = ""
  sensitive   = true
}
