output "safety_mode" {
  description = "Indicates whether this configuration is in the non-creating default mode."
  value       = var.enable_live_resources ? "live-resources-enabled" : "no-live-resources"
}

output "workspace_id" {
  description = "PowerVS workspace ID after live apply."
  value       = try(ibm_pi_workspace.this[0].id, null)
  sensitive   = true
}

output "network_id" {
  description = "PowerVS private network ID after live apply."
  value       = try(ibm_pi_network.private[0].network_id, null)
  sensitive   = true
}

output "aix_stock_image_name" {
  description = "Explicit stock image name selected for live validation."
  value       = var.aix_stock_image_name
}

output "imported_aix_image_id" {
  description = "Workspace image ID imported from the selected stock image after live apply. Treat as identifier-sensitive in public Evidence."
  value       = try(ibm_pi_image.aix[0].image_id, null)
  sensitive   = true
}

output "ssh_key_name" {
  description = "Terraform-managed PowerVS SSH public key name after live apply."
  value       = try(ibm_pi_key.aix[0].pi_key_name, null)
}

output "aix_evidence_reachability_mode" {
  description = "Configured network reachability mode for AIX live Evidence collection."
  value       = var.aix_evidence_reachability_mode
}

output "aix_instance_id" {
  description = "PowerVS AIX instance ID after live apply."
  value       = try(ibm_pi_instance.aix[0].instance_id, null)
  sensitive   = true
}

output "data_volume_id" {
  description = "PowerVS shareable data volume ID after live apply."
  value       = try(ibm_pi_volume.data[0].volume_id, null)
  sensitive   = true
}

output "evidence_boundary" {
  description = "Architecture boundary for PVS-IAC-001."
  value = {
    live_validation = [
      "powervs_workspace",
      "powervs_network",
      "powervs_image_import",
      "powervs_ssh_public_key",
      "aix_vsi",
      "powervs_volume"
    ]
    virtual_reference_only = [
      "hmc",
      "vios",
      "san_fabric"
    ]
  }
}
