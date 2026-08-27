output "safety_mode" {
  description = "Indicates whether this configuration is in the non-creating default mode."
  value       = var.enable_live_resources ? "live-resources-enabled" : "no-live-resources"
}

output "workspace_id" {
  description = "PowerVS workspace ID after live apply."
  value       = try(ibm_pi_workspace.this[0].id, null)
}

output "network_id" {
  description = "PowerVS private network ID after live apply."
  value       = try(ibm_pi_network.private[0].network_id, null)
}

output "aix_instance_id" {
  description = "PowerVS AIX instance ID after live apply."
  value       = try(ibm_pi_instance.aix[0].instance_id, null)
}

output "data_volume_id" {
  description = "PowerVS shareable data volume ID after live apply."
  value       = try(ibm_pi_volume.data[0].volume_id, null)
}

output "evidence_boundary" {
  description = "Architecture boundary for PVS-IAC-001."
  value = {
    live_validation = [
      "powervs_workspace",
      "powervs_network",
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
