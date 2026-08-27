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

tfvar_value() {
  key="$1"
  sed -n -E "s/^[[:space:]]*${key}[[:space:]]*=[[:space:]]*\"?([^\"#[:space:]]+)\"?.*$/\1/p" "$TFVARS_PATH" | tail -n 1
}

require_live_input() {
  key="$1"
  placeholder="$2"
  value="$(tfvar_value "$key")"

  if [ -z "$value" ]; then
    echo "Live-ready preflight failed: $key must be explicitly set in $TFVARS_PATH." >&2
    exit 1
  fi

  if [ -n "$placeholder" ] && [ "$value" = "$placeholder" ]; then
    echo "Live-ready preflight failed: $key is still set to the repository safe example placeholder." >&2
    exit 1
  fi

  echo "$key is explicitly supplied for live validation; value intentionally not displayed."
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

require_text "versions.tf" 'IBM-Cloud/ibm' "versions.tf must require the official IBM Cloud provider."
require_text "main.tf" 'ibm_pi_workspace' "main.tf must define a PowerVS workspace resource."
require_text "main.tf" 'ibm_pi_network' "main.tf must define a PowerVS network resource."
require_text "main.tf" 'ibm_pi_instance' "main.tf must define a PowerVS AIX instance resource."
require_text "main.tf" 'ibm_pi_volume' "main.tf must define a PowerVS volume resource."

if [ "$(basename "$TFVARS_PATH")" = "terraform.tfvars.example" ]; then
  require_text "$TFVARS_PATH" 'enable_live_resources[[:space:]]*=[[:space:]]*false' "Safe example must keep enable_live_resources = false."
  echo "Safe template preflight: terraform.tfvars.example is intentionally not live-ready."
  echo "Live-ready result: false. Supply a separate tfvars file for the later approved live validation task."
else
  require_live_input "ibm_region" ""
  require_live_input "powervs_zone" ""
  require_live_input "resource_group_id" "00000000000000000000000000000000"
  require_live_input "ssh_key_name" "existing-powervs-key"
  require_live_input "aix_image_id" "00000000-0000-0000-0000-000000000000"
  echo "Live-ready input preflight passed for required non-secret inputs."
fi

if [ -z "${IC_API_KEY:-}" ]; then
  echo "Warning: IC_API_KEY is not set. This is acceptable for fmt/validate but must be set for the later approved live task." >&2
else
  echo "IC_API_KEY is set; value intentionally not displayed."
fi

echo "Preflight completed. No resources were created, changed, or deleted."
