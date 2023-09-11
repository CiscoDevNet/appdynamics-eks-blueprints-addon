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

output "aws_eks_kubernetes_version" {
  description = "Kubernetes version to use for the EKS cluster."
  value       = var.aws_eks_kubernetes_version
}

output "aws_eks_cluster_name" {
  description = "Dynamically-generated AWS EKS Cluster name."
  value       = local.cluster_name
}

output "aws_eks_desired_node_count" {
  description = "Desired number of EKS worker nodes."
  value       = var.aws_eks_desired_node_count
}

output "aws_eks_instance_type" {
  description = "AWS EKS Node Group instance type."
  value       = var.aws_eks_instance_type
}

output "aws_eks_cluster_endpoint" {
  description = "Endpoint for EKS control plane."
  value       = module.eks.cluster_endpoint
}

output "aws_eks_configure_kubectl" {
  description = "Configure kubectl: Using the correct AWS profile, run the following command to update your kubeconfig:"
  value       = "aws eks --region ${var.aws_region} update-kubeconfig --name ${module.eks.cluster_name}"
}

output "ssh_pub_key_name" {
  description = "Name of SSH public key for EKS worker nodes."
  value       = var.ssh_pub_key_name
}

output "resource_tags" {
  description = "Tag names for AWS resources."
  value       = local.resource_tags
}
