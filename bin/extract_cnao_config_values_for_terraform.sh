#!/bin/bash -eu
#---------------------------------------------------------------------------------------------------
# Extract CNAO configuration values for use with Terraform.
#
# The AppDynamics Kubernetes and App Service Monitoring with Cloud Native Application Observability
# (CNAO) provides a solution to monitor applications and infrastructure with correlation using Helm
# Charts.
#
# To simplify deployment of these Helm Charts, this script will extract key values from the
# downloaded 'operators-values.yaml' and 'collectors-values.yaml' for ease of deployment with the
# AppDynamics EKS Blueprints Addon via Terraform.
#
# To execute this script, you will need the following:
#   'operators-values.yaml' file:      Download to your local Terraform directory from CNAO.
#   'collectors-values.yaml' file:     Download to your local Terraform directory from CNAO.
#   'terraform.tfvars.example' file:   Used to load Terraform variable definitions for CNAO.
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

# validate helm charts have been generated and downloaded. -----------------------------------------
# check if 'operators-values.yaml' file exists.
if [ ! -f "operators-values.yaml" ]; then
  echo "ERROR: 'operators-values.yaml' file NOT found."
  echo "Please generate and download from your AppDynamics CNAO Tenant."
  echo "For more information, visit:"
  echo "  https://docs.appdynamics.com/fso/cloud-native-app-obs/en/kubernetes-and-app-service-monitoring"
  exit 1
fi

# check if 'collectors-values.yaml' file exists.
if [ ! -f "collectors-values.yaml" ]; then
  echo "ERROR: 'collectors-values.yaml' file NOT found."
  echo "Please generate and download from your AppDynamics CNAO Tenant."
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

# extract cnao configuration values for use with terraform. ----------------------------------------
# extract helm chart values from 'operators-values' and 'collectors-values.yaml'.
echo "Extracting CNAO configuration values..."
client_id=$(yq '.appdynamics-otel-collector.clientId' collectors-values.yaml)
client_secret=$(yq '.appdynamics-otel-collector.clientSecret' collectors-values.yaml)
cluster_name=$(yq '.global.clusterName' collectors-values.yaml)
collector_endpoint=$(yq '.appdynamics-otel-collector.endpoint' collectors-values.yaml)
operators_endpoint=$(yq '.fso-agent-mgmt-client.solution.endpoint' operators-values.yaml)
tenant_id=$(yq '.fso-agent-mgmt-client.oauth.tenantId' operators-values.yaml)
token_url=$(yq '.appdynamics-otel-collector.tokenUrl' collectors-values.yaml)

# escape forward slashes '/' in chart values before substitution.
client_id_escaped=$(echo ${client_id} | sed 's/\//\\\//g')
client_secret_escaped=$(echo ${client_secret} | sed 's/\//\\\//g')
cluster_name_escaped=$(echo ${cluster_name} | sed 's/\//\\\//g')
collector_endpoint_escaped=$(echo ${collector_endpoint} | sed 's/\//\\\//g')
operators_endpoint_escaped=$(echo ${operators_endpoint} | sed 's/\//\\\//g')
tenant_id_escaped=$(echo ${tenant_id} | sed 's/\//\\\//g')
token_url_escaped=$(echo ${token_url} | sed 's/\//\\\//g')

# substitute the helm chart variables. -------------------------------------------------------------
echo "Substituting Helm Chart variables..."
sed -i.bak -e "/^#cnao_client_id =/s/^.*$/cnao_client_id = \"${client_id_escaped}\"/" terraform.tfvars
sed -i.bak -e "/^#cnao_client_secret =/s/^.*$/cnao_client_secret = \"${client_secret_escaped}\"/" terraform.tfvars
sed -i.bak -e "/^#cnao_cluster_name =/s/^.*$/cnao_cluster_name = \"${cluster_name_escaped}\"/" terraform.tfvars
sed -i.bak -e "/^#cnao_collector_endpoint =/s/^.*$/cnao_collector_endpoint = \"${collector_endpoint_escaped}\"/" terraform.tfvars
sed -i.bak -e "/^#cnao_operators_endpoint =/s/^.*$/cnao_operators_endpoint = \"${operators_endpoint_escaped}\"/" terraform.tfvars
sed -i.bak -e "/^#cnao_tenant_id =/s/^.*$/cnao_tenant_id = \"${tenant_id_escaped}\"/" terraform.tfvars
sed -i.bak -e "/^#cnao_token_url =/s/^.*$/cnao_token_url = \"${token_url_escaped}\"/" terraform.tfvars

# remove temporary backup file.
echo "Removing temporary backup file..."
rm -f terraform.tfvars.bak

# print completion message.
echo "CNAO configuration values extraction complete."
