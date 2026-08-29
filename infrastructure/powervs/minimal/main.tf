locals {
  workspace_name = "${var.name_prefix}-workspace"
  network_name   = "${var.name_prefix}-net"
  ssh_key_name    = "${var.name_prefix}-ssh-key"
  instance_name  = "${var.name_prefix}-aix01"
  volume_name    = "${var.name_prefix}-data01"

  selected_catalog_image_matches = var.enable_live_resources ? [
    for image in data.ibm_pi_catalog_images.stock[0].images : image
    if image.image_id == var.aix_stock_image_id && image.name == var.aix_stock_image_name
  ] : []
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

data "ibm_pi_catalog_images" "stock" {
  count = var.enable_live_resources ? 1 : 0

  pi_cloud_instance_id = ibm_pi_workspace.this[0].id
}

resource "ibm_pi_image" "aix" {
  count = var.enable_live_resources ? 1 : 0

  pi_cloud_instance_id = ibm_pi_workspace.this[0].id
  pi_image_id          = var.aix_stock_image_id

  depends_on = [data.ibm_pi_catalog_images.stock]

  lifecycle {
    precondition {
      condition     = length(local.selected_catalog_image_matches) == 1
      error_message = "aix_stock_image_id and aix_stock_image_name must match exactly one catalog image in the target PowerVS workspace."
    }
  }
}

resource "ibm_pi_key" "aix" {
  count = var.enable_live_resources ? 1 : 0

  pi_cloud_instance_id = ibm_pi_workspace.this[0].id
  pi_key_name          = local.ssh_key_name
  pi_ssh_key           = var.ssh_public_key
  pi_visibility        = var.ssh_key_visibility
}

data "ibm_pi_public_network" "validation" {
  count = (
    var.enable_live_resources && var.aix_evidence_reachability_mode == "public-network"
  ) ? 1 : 0

  pi_cloud_instance_id = ibm_pi_workspace.this[0].id
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
  pi_image_id          = ibm_pi_image.aix[0].image_id
  pi_key_pair_name     = ibm_pi_key.aix[0].pi_key_name
  pi_memory            = var.aix_instance_memory_gb
  pi_processors        = var.aix_instance_processors
  pi_proc_type         = var.aix_processor_type
  pi_sys_type          = var.aix_system_type
  pi_pin_policy        = "none"
  pi_storage_type      = var.data_volume_type
  pi_volume_ids        = [ibm_pi_volume.data[0].volume_id]
  pi_user_tags         = var.tags

  lifecycle {
    precondition {
      condition     = var.aix_evidence_reachability_mode != "public-network" || var.public_network_exposure_reviewed
      error_message = "public-network reachability requires public_network_exposure_reviewed = true before live plan/apply."
    }
  }

  pi_network {
    network_id = ibm_pi_network.private[0].network_id
  }

  dynamic "pi_network" {
    for_each = (
      var.aix_evidence_reachability_mode == "public-network"
    ) ? [data.ibm_pi_public_network.validation[0].id] : []

    content {
      network_id = pi_network.value
    }
  }
}
