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

# Providers ----------------------------------------------------------------------------------------
provider "aws" {
  region = var.aws_region
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

provider "kubectl" {
  apply_retry_count      = 10
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  load_config_file       = false
  token                  = data.aws_eks_cluster_auth.this.token
}

# Locals -------------------------------------------------------------------------------------------
locals {
  # format random string for uniqueness.
  unique_string = lower(random_string.suffix.result)

  # define resource names here to ensure standardized naming conventions.
  vpc_name     = "${var.resource_name_prefix}-${local.unique_string}-VPC"
  cluster_name = "${var.resource_name_prefix}-${local.unique_string}-EKS"

  # create the cisco cloud observability operators values content from the helm chart template.
  operators_values_content = templatefile("${path.module}/templates/operators-values.yaml.tmpl", {
                               client_id          = var.cco_client_id
                               client_secret      = var.cco_client_secret
                               cluster_name       = var.cco_cluster_name
                               operators_endpoint = var.cco_operators_endpoint
                               tenant_id          = var.cco_tenant_id
                               token_url          = var.cco_token_url
                             })

  # create the cisco cloud observability collectors values content from the helm chart template.
  collectors_values_content = templatefile("${path.module}/templates/collectors-values.yaml.tmpl", {
                                client_id                   = var.cco_client_id
                                client_secret               = var.cco_client_secret
                                cluster_name                = var.cco_cluster_name
                                collector_endpoint          = var.cco_collector_endpoint
                                token_url                   = var.cco_token_url
                                security_monitoring_enabled = var.cco_security_monitoring_enabled
                                agent_id                    = var.cco_agent_id
                                shared_secret               = var.cco_shared_secret
                              })

  # define common tag names for aws resources.
  resource_tags = {
    EnvironmentHome = var.resource_environment_home_tag
    CreatedBy       = data.aws_caller_identity.current.arn
    Project         = var.resource_project_tag
  }
}

# Data Sources -------------------------------------------------------------------------------------
# find the user currently in use by aws.
data "aws_caller_identity" "current" {
}

# availability zones to use in our solution.
data "aws_availability_zones" "available" {
  state = "available"
}

# retrieve eks cluster configuration.
data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_name
}

# retrieve authentication token to communicate with the eks cluster.
data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
}

# Modules ------------------------------------------------------------------------------------------
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = ">= 5.4"

  name = local.vpc_name
  cidr = var.aws_vpc_cidr_block

  azs             = data.aws_availability_zones.available.names
  public_subnets  = var.aws_vpc_public_subnets
  private_subnets = var.aws_vpc_private_subnets

  enable_nat_gateway         = true
  single_nat_gateway         = true
  enable_dns_hostnames       = true
  manage_default_network_acl = false
  map_public_ip_on_launch    = true

  tags = local.resource_tags

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = ">= 19.21.0"

  cluster_name    = local.cluster_name
  cluster_version = var.aws_eks_kubernetes_version
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.public_subnets

  cluster_endpoint_private_access      = var.aws_eks_endpoint_private_access
  cluster_endpoint_public_access       = var.aws_eks_endpoint_public_access
  cluster_endpoint_public_access_cidrs = var.aws_eks_endpoint_public_access_cidrs
  cluster_enabled_log_types            = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  tags = local.resource_tags

  # eks managed node groups.
  eks_managed_node_groups = {
    managed = {
      instance_types  = var.aws_eks_instance_type
      capacity_type   = "ON_DEMAND"
      ami_type        = "AL2_x86_64"
      subnet_ids      = module.vpc.public_subnets

      # scaling configuration.
      desired_size = var.aws_eks_desired_node_count
      min_size     = var.aws_eks_min_node_count
      max_size     = var.aws_eks_max_node_count

      labels = {
        GithubRepo = "terraform-aws-eks"
        GithubOrg  = "terraform-aws-modules"
      }

      additional_tags = local.resource_tags

      # use default launch template to adjust disk size and allow remote access to worker nodes.
      use_custom_launch_template = false
      disk_size                  = var.aws_eks_instance_disk_size

      remote_access = {
        ec2_ssh_key               = var.ssh_pub_key_name
        source_security_group_ids = null
      }
    }
  }

  manage_aws_auth_configmap = true
}

module "addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = ">= 1.12"

  cluster_name      = data.aws_eks_cluster.cluster.id
  cluster_endpoint  = data.aws_eks_cluster.cluster.endpoint
  cluster_version   = data.aws_eks_cluster.cluster.version
  oidc_provider_arn = module.eks.oidc_provider_arn

  # eks add-ons.
  eks_addons = {
    coredns = {}
    vpc-cni = {}
    kube-proxy = {}
  }

  # blueprints add-ons.
  enable_metrics_server = false
  enable_cert_manager   = true

  # cisco cloud observability helm charts for kubernetes and app service monitoring.
  helm_releases = {
    # install cisco cloud observability operators.
    cco-operators = {
      description      = "A Helm chart for the Cisco Cloud Observability Operators."
      namespace        = "appdynamics"
      create_namespace = true
      chart            = "appdynamics-operators"
#     chart_version    = "1.17.244"
      repository       = "https://appdynamics.jfrog.io/artifactory/appdynamics-cloud-helmcharts"
      wait             = true
      wait_for_jobs    = true

      values = [
        local.operators_values_content
      ]

#     # use this syntax to import your own 'operators-values.yaml' file without the template file.
#     values = [
#       "${file("operators-values.yaml")}"
#     ]
    }
  }

  tags = local.resource_tags
}

# Resources ----------------------------------------------------------------------------------------
resource "random_string" "suffix" {
  length  = 5
  special = false
}

# install cisco cloud observability collectors.
resource "helm_release" "cisco_cloud_observability_collectors" {
  name             = "cco-collectors"
  description      = "A Helm chart for the Cisco Cloud Observability Collectors."
  namespace        = "appdynamics"
  create_namespace = true
  chart            = "appdynamics-collectors"
# version          = "1.17.880"
  repository       = "https://appdynamics.jfrog.io/artifactory/appdynamics-cloud-helmcharts"
  wait             = true
  wait_for_jobs    = true

  values = [
    local.collectors_values_content
  ]

# # use this syntax to import your own 'collectors-values.yaml' file without the template file.
# values = [
#   "${file("collectors-values.yaml")}"
# ]

  # note: the cisco cloud observability collectors deployment depends on the the cisco cloud observability operators.
  # wait for eks blueprints addons to be installed first.
  depends_on = [
    module.addons
  ]
}

# uncomment the following 'local_file' resource definitions as needed for debugging.
# persist the files generated from the helm chart templates to the local directory for viewing.
# generate the cisco cloud observability operators values file from the helm chart template.
#resource "local_file" "operators_values_file" {
#  filename = "generated-operators-values.yaml"
#  content  = local.operators_values_content
#  file_permission = "0644"
#}

# generate the cisco cloud observability collectors values file from the helm chart template.
#resource "local_file" "collectors_values_file" {
#  filename = "generated-collectors-values.yaml"
#  content  = local.collectors_values_content
#  file_permission = "0644"
#}
