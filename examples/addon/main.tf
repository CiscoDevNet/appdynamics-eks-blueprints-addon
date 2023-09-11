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
  version = ">= 1.7"

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

  # appdynamics helm charts for cnao kubernetes and app service monitoring.
  helm_releases = {
    # install appdynamics operators.
    appdynamics-cnao-operators = {
      description      = "A Helm chart for the AppDynamics Operators."
      namespace        = "appdynamics"
      create_namespace = true
      chart            = "appdynamics-operators"
#     chart_version    = "1.14.168"
      repository       = "https://appdynamics.jfrog.io/artifactory/appdynamics-cloud-helmcharts"
      wait             = true
      wait_for_jobs    = true

      values = [
        templatefile("${path.module}/templates/operators-values.yaml.tmpl", {
          client_id          = var.cnao_client_id
          client_secret      = var.cnao_client_secret
          cluster_name       = var.cnao_cluster_name
          operators_endpoint = var.cnao_operators_endpoint
          tenant_id          = var.cnao_tenant_id
          token_url          = var.cnao_token_url
        })
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
# install appdynamics collectors.
resource "helm_release" "appdynamics_cnao_collectors" {
  name             = "appdynamics-cnao-collectors"
  description      = "A Helm chart for the AppDynamics Collectors."
  namespace        = "appdynamics"
  create_namespace = true
  chart            = "appdynamics-collectors"
# version          = "1.13.658"
  repository       = "https://appdynamics.jfrog.io/artifactory/appdynamics-cloud-helmcharts"
  wait             = true
  wait_for_jobs    = true

  values = [
    templatefile("${path.module}/templates/collectors-values.yaml.tmpl", {
      client_id             = var.cnao_client_id
      client_secret         = var.cnao_client_secret
      cluster_name          = var.cnao_cluster_name
      collector_endpoint    = var.cnao_collector_endpoint
      install_log_collector = var.cnao_install_log_collector
      token_url             = var.cnao_token_url
    })
  ]

# # use this syntax to import your own 'collectors-values.yaml' file without the template file.
# values = [
#   "${file("collectors-values.yaml")}"
# ]

  # note: the appdynamics collectors deployment depends on the the appdynamics operators.
  # wait for eks blueprints addons to be installed first.
  depends_on = [
    module.addons
  ]
}
