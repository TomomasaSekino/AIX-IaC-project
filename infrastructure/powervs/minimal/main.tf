locals {
  workspace_name = "${var.name_prefix}-workspace"
  network_name   = "${var.name_prefix}-net"
  instance_name  = "${var.name_prefix}-aix01"
  volume_name    = "${var.name_prefix}-data01"
}

resource "ibm_pi_workspace" "this" {
  count = var.enable_live_resources ? 1 : 0

  pi_name              = local.workspace_name
  pi_datacenter        = var.powervs_zone
  pi_resource_group_id = var.resource_group_id
  pi_plan              = "public"
  pi_user_tags         = var.tags
}

resource "ibm_pi_network" "private" {
  count = var.enable_live_resources ? 1 : 0

  pi_network_name      = local.network_name
  pi_cloud_instance_id = ibm_pi_workspace.this[0].id
  pi_network_type      = "vlan"
  pi_cidr              = var.network_cidr
  pi_dns               = var.network_dns
  pi_gateway           = var.network_gateway
  pi_enable_dhcp       = true
  pi_user_tags         = var.tags

  pi_ipaddress_range {
    pi_starting_ip_address = var.network_ip_start
    pi_ending_ip_address   = var.network_ip_end
  }
}

resource "ibm_pi_volume" "data" {
  count = var.enable_live_resources ? 1 : 0

  pi_cloud_instance_id = ibm_pi_workspace.this[0].id
  pi_volume_name       = local.volume_name
  pi_volume_size       = var.data_volume_size_gb
  pi_volume_type       = var.data_volume_type
  pi_volume_shareable  = true
  pi_user_tags         = var.tags
}

resource "ibm_pi_instance" "aix" {
  count = var.enable_live_resources ? 1 : 0

  pi_cloud_instance_id = ibm_pi_workspace.this[0].id
  pi_instance_name     = local.instance_name
  pi_image_id          = var.aix_image_id
  pi_key_pair_name     = var.ssh_key_name
  pi_memory            = var.aix_instance_memory_gb
  pi_processors        = var.aix_instance_processors
  pi_proc_type         = var.aix_processor_type
  pi_sys_type          = var.aix_system_type
  pi_pin_policy        = "none"
  pi_storage_type      = var.data_volume_type
  pi_volume_ids        = [ibm_pi_volume.data[0].volume_id]
  pi_user_tags         = var.tags

  pi_network {
    network_id = ibm_pi_network.private[0].network_id
  }
}
