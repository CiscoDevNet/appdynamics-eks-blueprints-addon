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

# Outputs ------------------------------------------------------------------------------------------
output "aws_region" {
  description = "AWS region."
  value       = var.aws_region
}

output "aws_eks_cluster_name" {
  description = "AWS EKS Cluster name."
  value       = var.aws_eks_cluster_name
}

output "aws_eks_cluster_oidc_provider" {
  description = "URL for OpenID Connect Provider."
  value       = data.aws_iam_openid_connect_provider.oidc_provider.url
}

output "aws_eks_configure_kubectl" {
  description = "Configure kubectl: Using the correct AWS profile, run the following command to update your kubeconfig:"
  value       = "aws eks --region ${var.aws_region} update-kubeconfig --name ${data.aws_eks_cluster.cluster.id}"
}

output "resource_tags" {
  description = "Tag names for AWS resources."
  value       = local.resource_tags
}

output "cco_client_id" {
  description = "Defines the client ID for authenticating with Cisco Cloud Observability."
  value       = var.cco_client_id
  sensitive   = true
}

output "cco_client_secret" {
  description = "Defines the secret string in plaintext for authenticating with Cisco Cloud Observability."
  value       = var.cco_client_secret
  sensitive   = true
}

output "cco_cluster_name" {
  description = "The name of the cluster that is displayed in the UI."
  value       = var.cco_cluster_name
}

output "cco_collector_endpoint" {
  description = "Defines the endpoint the collector uses to send data for the Appdynamics Collectors."
  value       = var.cco_collector_endpoint
}

output "cco_operators_endpoint" {
  description = "Defines the endpoint the collector uses to send data for the Appdynamics Operators."
  value       = var.cco_operators_endpoint
}

output "cco_tenant_id" {
  description = "Tenant ID for the Cisco Cloud Observability tenant."
  value       = var.cco_tenant_id
}

output "cco_token_url" {
  description = "Authentication token for the Cisco Cloud Observability tenant."
  value       = var.cco_token_url
  sensitive   = true
}
