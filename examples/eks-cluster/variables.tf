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

# valid aws eks versions are: 1.23, 1.24, 1.25, 1.26, and 1.27.
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
  default     = "AppDynamics EKS Blueprints Addon - EKS Cluster"
}

variable "resource_project_tag" {
  description = "Resource project tag."
  type        = string
  default     = "AppDynamics EKS Blueprints Addon"
}