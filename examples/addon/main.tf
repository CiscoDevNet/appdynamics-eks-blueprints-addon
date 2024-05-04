/**
 * Copyright 2024 Cisco Systems, Inc. and its affiliates
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
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

provider "kubectl" {
  apply_retry_count      = 10
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  load_config_file       = false
  token                  = data.aws_eks_cluster_auth.this.token
}

# Locals -------------------------------------------------------------------------------------------
locals {
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

# retrieve eks cluster configuration.
data "aws_eks_cluster" "cluster" {
  name = var.aws_eks_cluster_name
}

# retrieve authentication token to communicate with the eks cluster.
data "aws_eks_cluster_auth" "this" {
  name = var.aws_eks_cluster_name
}

# retrieve openid connect provider.
# note: data source creation will fail if oidc provider is not available.
data "aws_iam_openid_connect_provider" "oidc_provider" {
  url = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

# Modules ------------------------------------------------------------------------------------------
module "addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = ">= 1.16"

  cluster_name      = data.aws_eks_cluster.cluster.id
  cluster_endpoint  = data.aws_eks_cluster.cluster.endpoint
  cluster_version   = data.aws_eks_cluster.cluster.version
  oidc_provider_arn = try(data.aws_iam_openid_connect_provider.oidc_provider.arn, null)

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
#     chart_version    = "1.21.368"
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
# install cisco cloud observability collectors.
resource "helm_release" "cisco_cloud_observability_collectors" {
  name             = "cco-collectors"
  description      = "A Helm chart for the Cisco Cloud Observability Collectors."
  namespace        = "appdynamics"
  create_namespace = true
  chart            = "appdynamics-collectors"
# version          = "1.21.1264"
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
