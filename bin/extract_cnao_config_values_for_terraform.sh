#!/bin/bash -eu
#---------------------------------------------------------------------------------------------------
# Extract Cisco Cloud Observability configuration values for use with Terraform.
#
# The Kubernetes and App Service Monitoring with Cisco Cloud Observability provides a
# solution to monitor applications and infrastructure with correlation using Helm Charts.
#
# To simplify deployment of these Helm Charts, this script will extract key values from the
# downloaded 'operators-values.yaml' and 'collectors-values.yaml' for ease of deployment with the
# Cisco Cloud Observability EKS Blueprints Addon via Terraform.
#
# To execute this script, you will need the following:
#   'operators-values.yaml' file:      Download to your local Terraform directory from Cisco Cloud Observability.
#   'collectors-values.yaml' file:     Download to your local Terraform directory from Cisco Cloud Observability.
#   'terraform.tfvars.example' file:   Used to load Terraform variable definitions for Cisco Cloud Observability.
#   yq:                                'yq' is a command-line YAML processor for linux 64-bit.
#
# For more details, please visit:
#   https://docs.appdynamics.com/fso/cloud-native-app-obs/en/kubernetes-and-app-service-monitoring
#   https://docs.appdynamics.com/fso/cloud-native-app-obs/en/kubernetes-and-app-service-monitoring/install-kubernetes-and-app-service-monitoring#InstallKubernetesandAppServiceMonitoring-helm-chartsInstallKubernetesandAppServiceMonitoringUsingHelmCharts
#   https://developer.hashicorp.com/terraform/language/values/variables
#   https://mikefarah.gitbook.io/yq/
#
# NOTE: Script can be run without elevated user privileges.
#---------------------------------------------------------------------------------------------------

# set empty default values for environment variables if not set. -----------------------------------
AWS_EKS_CLUSTER="${AWS_EKS_CLUSTER:-}"

# validate environment variables. ------------------------------------------------------------------
if [ -z "$AWS_EKS_CLUSTER" ]; then
  echo "Error: 'AWS_EKS_CLUSTER' environment variable not set."
  echo "Please set the 'AWS_EKS_CLUSTER' environment variable to the name of your AWS EKS Cluster."
  exit 1
fi

# validate helm charts have been generated and downloaded. -----------------------------------------
# check if 'operators-values.yaml' file exists.
if [ ! -f "operators-values.yaml" ]; then
  echo "ERROR: 'operators-values.yaml' file NOT found."
  echo "Please generate and download from your Cisco Cloud Observability Tenant."
  echo "For more information, visit:"
  echo "  https://docs.appdynamics.com/fso/cloud-native-app-obs/en/kubernetes-and-app-service-monitoring"
  exit 1
fi

# check if 'collectors-values.yaml' file exists.
if [ ! -f "collectors-values.yaml" ]; then
  echo "ERROR: 'collectors-values.yaml' file NOT found."
  echo "Please generate and download from your Cisco Cloud Observability Tenant."
  echo "For more information, visit:"
  echo "  https://docs.appdynamics.com/fso/cloud-native-app-obs/en/kubernetes-and-app-service-monitoring"
  exit 1
fi

# check if 'terraform.tfvars.example' file exists.
if [ ! -f "terraform.tfvars.example" ]; then
  echo "ERROR: 'terraform.tfvars.example' file NOT found."
  echo "Please make sure you are in your Terraform project root directory."
  echo "For more information, visit:"
  echo "  https://github.com/CiscoDevNet/appdynamics-eks-blueprints-addon"
  echo "  https://developer.hashicorp.com/terraform/language/values/variables"
  exit 1
fi

# validate required binaries. ----------------------------------------------------------------------
# check if 'yq' is installed.
if [ ! $(command -v yq) ]; then
  echo "ERROR: 'yq' command-line YAML processor utility NOT found."
  echo "NOTE: This script uses the 'yq' command-line YAML processor utility for extracting values from the downloaded Helm charts."
  echo "      For more information, visit: https://mikefarah.gitbook.io/yq/"
  echo "                                   https://github.com/mikefarah/yq/"
  echo "                                   https://github.com/mikefarah/yq/releases/"
  exit 1
fi

# start processing the helm charts. ----------------------------------------------------------------
# print start message.
echo "Begin processing Helm Chart files..."

# copy and rename terraform variable definition example file. --------------------------------------
rm -f terraform.tfvars
cp -p terraform.tfvars.example terraform.tfvars

# retrieve aws eks cluster name for use with terraform. --------------------------------------------
# extract eks cluster name from environment variable.
aws_eks_cluster_name="${AWS_EKS_CLUSTER}"

# escape forward slashes '/' in eks cluster name before substitution.
aws_eks_cluster_name_escaped=$(echo ${aws_eks_cluster_name} | sed 's/\//\\\//g')

# extract cco configuration values for use with terraform. -----------------------------------------
# extract helm chart values from 'operators-values' and 'collectors-values.yaml'.
echo "Extracting Cisco Cloud Observability configuration values..."
client_id=$(yq '.appdynamics-otel-collector.clientId' collectors-values.yaml)
client_secret=$(yq '.appdynamics-otel-collector.clientSecret' collectors-values.yaml)
cluster_name=$(yq '.global.clusterName' collectors-values.yaml)
collector_endpoint=$(yq '.appdynamics-otel-collector.endpoint' collectors-values.yaml)
operators_endpoint=$(yq '.appdynamics-smartagent.solution.endpoint' operators-values.yaml)
tenant_id=$(yq '.appdynamics-smartagent.oauth.tenantId' operators-values.yaml)
token_url=$(yq '.appdynamics-otel-collector.tokenUrl' collectors-values.yaml)

# escape forward slashes '/' in chart values before substitution.
client_id_escaped=$(echo ${client_id} | sed 's/\//\\\//g')
client_secret_escaped=$(echo ${client_secret} | sed 's/\//\\\//g')
cluster_name_escaped=$(echo ${cluster_name} | sed 's/\//\\\//g')
collector_endpoint_escaped=$(echo ${collector_endpoint} | sed 's/\//\\\//g')
operators_endpoint_escaped=$(echo ${operators_endpoint} | sed 's/\//\\\//g')
tenant_id_escaped=$(echo ${tenant_id} | sed 's/\//\\\//g')
token_url_escaped=$(echo ${token_url} | sed 's/\//\\\//g')

# substitute the eks cluster name variable. --------------------------------------------------------
echo "Substituting EKS Cluster name variable..."
sed -i.bak -e "/^#aws_eks_cluster_name =/s/^.*$/aws_eks_cluster_name = \"${aws_eks_cluster_name_escaped}\"/" terraform.tfvars

# substitute the helm chart variables. -------------------------------------------------------------
echo "Substituting Helm Chart variables..."
sed -i.bak -e "/^#cco_client_id =/s/^.*$/cco_client_id = \"${client_id_escaped}\"/" terraform.tfvars
sed -i.bak -e "/^#cco_client_secret =/s/^.*$/cco_client_secret = \"${client_secret_escaped}\"/" terraform.tfvars
sed -i.bak -e "/^#cco_cluster_name =/s/^.*$/cco_cluster_name = \"${cluster_name_escaped}\"/" terraform.tfvars
sed -i.bak -e "/^#cco_collector_endpoint =/s/^.*$/cco_collector_endpoint = \"${collector_endpoint_escaped}\"/" terraform.tfvars
sed -i.bak -e "/^#cco_operators_endpoint =/s/^.*$/cco_operators_endpoint = \"${operators_endpoint_escaped}\"/" terraform.tfvars
sed -i.bak -e "/^#cco_tenant_id =/s/^.*$/cco_tenant_id = \"${tenant_id_escaped}\"/" terraform.tfvars
sed -i.bak -e "/^#cco_token_url =/s/^.*$/cco_token_url = \"${token_url_escaped}\"/" terraform.tfvars

# remove temporary backup file.
echo "Removing temporary backup file..."
rm -f terraform.tfvars.bak

# print completion message.
echo "Cisco Cloud Observability configuration values extraction complete."
