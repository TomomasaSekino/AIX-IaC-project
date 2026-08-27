#!/usr/bin/env sh
set -eu

TFVARS_PATH="${1:-terraform.tfvars.example}"

require_file() {
  if [ ! -f "$1" ]; then
    echo "Required file not found: $1" >&2
    exit 1
  fi
}

require_text() {
  file="$1"
  pattern="$2"
  message="$3"
  if ! grep -Eq "$pattern" "$file"; then
    echo "$message" >&2
    exit 1
  fi
}

echo "PVS-IAC-001 preflight: non-destructive checks only"

if ! command -v terraform >/dev/null 2>&1; then
  echo "Terraform CLI is required but was not found in PATH." >&2
  exit 1
fi

terraform version

require_file "versions.tf"
require_file "providers.tf"
require_file "main.tf"
require_file "variables.tf"
require_file "outputs.tf"
require_file "$TFVARS_PATH"

require_text "$TFVARS_PATH" 'enable_live_resources[[:space:]]*=[[:space:]]*false' "Safe example must keep enable_live_resources = false."
require_text "versions.tf" 'IBM-Cloud/ibm' "versions.tf must require the official IBM Cloud provider."
require_text "main.tf" 'ibm_pi_workspace' "main.tf must define a PowerVS workspace resource."
require_text "main.tf" 'ibm_pi_network' "main.tf must define a PowerVS network resource."
require_text "main.tf" 'ibm_pi_instance' "main.tf must define a PowerVS AIX instance resource."
require_text "main.tf" 'ibm_pi_volume' "main.tf must define a PowerVS volume resource."

if [ -z "${IC_API_KEY:-}" ]; then
  echo "Warning: IC_API_KEY is not set. This is acceptable for fmt/validate but must be set for the later approved live task." >&2
else
  echo "IC_API_KEY is set; value intentionally not displayed."
fi

echo "Preflight passed. No resources were created, changed, or deleted."
