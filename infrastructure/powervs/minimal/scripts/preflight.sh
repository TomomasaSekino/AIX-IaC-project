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
  sed -n -E "s/^[[:space:]]*${key}[[:space:]]*=[[:space:]]*\"([^\"]*)\".*$/\1/p; s/^[[:space:]]*${key}[[:space:]]*=[[:space:]]*([^#[:space:]]+).*$/\1/p" "$TFVARS_PATH" | tail -n 1
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

require_true() {
  key="$1"
  message="$2"
  value="$(tfvar_value "$key")"

  if [ "$value" != "true" ]; then
    echo "Live-ready preflight failed: $message" >&2
    exit 1
  fi

  echo "$key is explicitly true for live validation."
}

echo "PVS-IAC-002 preparation preflight: non-destructive checks only"

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
require_text "main.tf" 'ibm_pi_catalog_images' "main.tf must define a PowerVS catalog image lookup."
require_text "main.tf" 'ibm_pi_image' "main.tf must define a PowerVS image import resource."
require_text "main.tf" 'ibm_pi_key' "main.tf must define a Terraform-managed PowerVS SSH public key."
require_text "main.tf" 'ibm_pi_instance' "main.tf must define a PowerVS AIX instance resource."
require_text "main.tf" 'ibm_pi_volume' "main.tf must define a PowerVS volume resource."

if [ "$(basename "$TFVARS_PATH")" = "terraform.tfvars.example" ]; then
  require_text "$TFVARS_PATH" 'enable_live_resources[[:space:]]*=[[:space:]]*false' "Safe example must keep enable_live_resources = false."
  echo "Safe template preflight: terraform.tfvars.example is intentionally not live-ready."
  echo "Live-ready result: false. Supply a separate tfvars file for the later approved live validation task."
else
  require_true "enable_live_resources" "enable_live_resources must be true in a live-ready tfvars file."
  require_live_input "ibm_region" ""
  require_live_input "powervs_zone" ""
  require_live_input "resource_group_id" "00000000000000000000000000000000"
  require_live_input "ssh_public_key" "ssh-rsa AAAA0000000000000000000000000000000000000000000000000000000000000000 pvs-iac-placeholder"
  require_live_input "aix_stock_image_id" "00000000-0000-0000-0000-000000000000"
  require_live_input "aix_stock_image_name" "AIX-stock-image-placeholder"
  require_live_input "aix_evidence_reachability_mode" ""

  reachability_mode="$(tfvar_value "aix_evidence_reachability_mode")"
  if [ "$reachability_mode" = "public-network" ]; then
    public_reviewed="$(tfvar_value "public_network_exposure_reviewed")"
    if [ "$public_reviewed" != "true" ]; then
      echo "Live-ready preflight failed: public-network reachability requires public_network_exposure_reviewed = true after Human exposure review." >&2
      exit 1
    fi
    echo "public-network reachability selected; exposure review flag is present. Public identifiers are not displayed."
  elif [ "$reachability_mode" = "private-network" ]; then
    require_true "private_network_route_reviewed" "private-network reachability requires private_network_route_reviewed = true after Human route/VPN/bastion confirmation."
    echo "private-network reachability selected; Human route confirmation flag is present."
  else
    echo "Live-ready preflight failed: aix_evidence_reachability_mode must be private-network or public-network." >&2
    exit 1
  fi

  if [ -z "${IC_API_KEY:-}" ]; then
    echo "Live-ready preflight failed: IC_API_KEY must exist in the local execution environment; value must not be displayed." >&2
    exit 1
  fi
  echo "IC_API_KEY is set for live-ready validation; value intentionally not displayed."

  echo "Live-ready input preflight passed for required non-secret inputs."
fi

if [ "$(basename "$TFVARS_PATH")" = "terraform.tfvars.example" ]; then
  if [ -z "${IC_API_KEY:-}" ]; then
    echo "Warning: IC_API_KEY is not set. This is acceptable for fmt/validate but must be set for the later approved live task." >&2
  else
    echo "IC_API_KEY is set; value intentionally not displayed."
  fi
fi

echo "Preflight completed. No resources were created, changed, or deleted."
