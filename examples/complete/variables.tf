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

variable "aws_vpc_cidr_block" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "172.16.0.0/16"
}

variable "aws_vpc_public_subnets" {
  description = "A list of public subnets inside the VPC."
  type        = list(string)
  default     = ["172.16.0.0/24", "172.16.1.0/24", "172.16.2.0/24"]
}

variable "aws_vpc_private_subnets" {
  description = "A list of private subnets inside the VPC."
  type        = list(string)
  default     = ["172.16.3.0/24"]
}

# NOTE: If set to 'false', ensure to have a proper private access with 'cluster_endpoint_private_access = true'.
variable "aws_eks_endpoint_private_access" {
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled."
  type        = bool
  default     = false
}

# NOTE: If set to 'false', ensure to have a proper private access with 'cluster_endpoint_private_access = true'.
variable "aws_eks_endpoint_public_access" {
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled."
  type        = bool
  default     = true
}

variable "aws_eks_endpoint_public_access_cidrs" {
  description = "List of CIDR blocks which can access the EKS public API server endpoint."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "aws_eks_desired_node_count" {
  description = "Desired number of EKS worker nodes."
  type        = number
  default     = 2
}

variable "aws_eks_min_node_count" {
  description = "Minimum number of EKS worker nodes."
  type        = number
  default     = 1
}

variable "aws_eks_max_node_count" {
  description = "Maximum number of EKS worker nodes."
  type        = number
  default     = 3
}

variable "aws_eks_instance_type" {
  description = "AWS EKS Node Group instance type."
  type        = list(string)
  default     = ["t2.large"]
}

# valid aws eks versions are: 1.24, 1.25, 1.26, 1.27, and 1.28.
variable "aws_eks_kubernetes_version" {
  description = "Kubernetes version to use for the EKS cluster."
  type        = string
  default     = "1.27"
}

variable "ssh_pub_key_name" {
  description = "Name of SSH public key for EKS worker nodes."
  type        = string
}

variable "resource_name_prefix" {
  description = "Resource name prefix."
  type        = string
  default     = "AppD-EKS-Addon"
}

variable "resource_environment_home_tag" {
  description = "Resource environment home tag."
  type        = string
  default     = "AppDynamics EKS Blueprints Addon - Complete"
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
