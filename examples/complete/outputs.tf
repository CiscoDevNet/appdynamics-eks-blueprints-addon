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

output "cnao_client_id" {
  description = "Defines the client ID for authenticating with Cloud Native Application Observability."
  value       = var.cnao_client_id
  sensitive   = true
}

output "cnao_client_secret" {
  description = "Defines the secret string in plaintext for authenticating with Cloud Native Application Observability."
  value       = var.cnao_client_secret
  sensitive   = true
}

output "cnao_cluster_name" {
  description = "The name of the cluster that is displayed in the UI."
  value       = var.cnao_cluster_name
}

output "cnao_collector_endpoint" {
  description = "Defines the endpoint the collector uses to send data for the Appdynamics Collectors."
  value       = var.cnao_collector_endpoint
}

output "cnao_operators_endpoint" {
  description = "Defines the endpoint the collector uses to send data for the Appdynamics Operators."
  value       = var.cnao_operators_endpoint
}

output "cnao_install_log_collector" {
  description = "Set this option to 'true' to install log collector monitoring (default is 'true')."
  value       = var.cnao_install_log_collector
}

output "cnao_tenant_id" {
  description = "Tenant ID for the AppDynamics Cloud Native Application Observability tenant."
  value       = var.cnao_tenant_id
}

output "cnao_token_url" {
  description = "Authentication token for the AppDynamics Cloud Native Application Observability tenant."
  value       = var.cnao_token_url
  sensitive   = true
}
