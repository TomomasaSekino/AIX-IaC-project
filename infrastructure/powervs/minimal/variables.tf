variable "enable_live_resources" {
  description = "Safety switch. Keep false for PVS-IAC-001; set true only in the approved live apply/destroy task."
  type        = bool
  default     = false
}

variable "ibm_region" {
  description = "IBM Cloud region used by the provider. For a PowerVS zone such as lon04, use the region prefix such as lon."
  type        = string
  default     = "jp-tok"

  validation {
    condition     = length(trimspace(var.ibm_region)) > 0
    error_message = "ibm_region must not be empty."
  }
}

variable "powervs_zone" {
  description = "PowerVS target zone or datacenter, for example tok04, lon04, or us-east."
  type        = string
  default     = "tok04"

  validation {
    condition     = length(trimspace(var.powervs_zone)) > 0
    error_message = "powervs_zone must not be empty."
  }
}

variable "resource_group_id" {
  description = "IBM Cloud resource group ID for the PowerVS workspace. Use preflight to check that it is provided before live apply."
  type        = string
  default     = "00000000000000000000000000000000"
  sensitive   = false

  validation {
    condition     = length(trimspace(var.resource_group_id)) > 0
    error_message = "resource_group_id must not be empty."
  }
}

variable "name_prefix" {
  description = "Prefix used for all PowerVS resources created by the follow-up live validation task."
  type        = string
  default     = "aix-iac-pvs-mvp"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,40}$", var.name_prefix))
    error_message = "name_prefix must be lowercase, start with a letter, and contain only letters, numbers, and hyphens."
  }
}

variable "ssh_key_name" {
  description = "Existing PowerVS SSH key pair name. Do not store private keys or API keys in Terraform files."
  type        = string
  default     = "existing-powervs-key"

  validation {
    condition     = length(trimspace(var.ssh_key_name)) > 0
    error_message = "ssh_key_name must not be empty."
  }
}

variable "aix_image_id" {
  description = "PowerVS image ID already imported into the workspace. Stock images must be imported into the workspace before instance creation."
  type        = string
  default     = "00000000-0000-0000-0000-000000000000"

  validation {
    condition     = length(trimspace(var.aix_image_id)) > 0
    error_message = "aix_image_id must not be empty."
  }
}

variable "network_cidr" {
  description = "Private PowerVS VLAN CIDR for follow-up live validation."
  type        = string
  default     = "192.168.100.0/24"
}

variable "network_gateway" {
  description = "Gateway address in network_cidr."
  type        = string
  default     = "192.168.100.1"
}

variable "network_dns" {
  description = "DNS servers for the private PowerVS network."
  type        = list(string)
  default     = ["9.9.9.9"]
}

variable "network_ip_start" {
  description = "First usable address for the PowerVS network IP range."
  type        = string
  default     = "192.168.100.10"
}

variable "network_ip_end" {
  description = "Last usable address for the PowerVS network IP range."
  type        = string
  default     = "192.168.100.200"
}

variable "aix_instance_memory_gb" {
  description = "Memory in GiB for the minimal AIX VSI."
  type        = number
  default     = 4

  validation {
    condition     = var.aix_instance_memory_gb >= 2
    error_message = "aix_instance_memory_gb must be at least 2."
  }
}

variable "aix_instance_processors" {
  description = "Processor count for the minimal AIX VSI."
  type        = number
  default     = 0.25

  validation {
    condition     = var.aix_instance_processors > 0
    error_message = "aix_instance_processors must be greater than 0."
  }
}

variable "aix_processor_type" {
  description = "PowerVS processor type."
  type        = string
  default     = "shared"

  validation {
    condition     = contains(["shared", "capped", "dedicated"], var.aix_processor_type)
    error_message = "aix_processor_type must be shared, capped, or dedicated."
  }
}

variable "aix_system_type" {
  description = "Power Systems machine type for the AIX instance."
  type        = string
  default     = "s922"
}

variable "data_volume_size_gb" {
  description = "Size in GiB for the minimal shareable data volume."
  type        = number
  default     = 20

  validation {
    condition     = var.data_volume_size_gb >= 10
    error_message = "data_volume_size_gb must be at least 10."
  }
}

variable "data_volume_type" {
  description = "PowerVS volume type. Current provider docs default to tier3 when omitted."
  type        = string
  default     = "tier3"
}

variable "tags" {
  description = "Non-secret tags applied to resources created by the follow-up live validation task."
  type        = list(string)
  default     = ["project:aix-iac", "task:pvs-iac-001", "evidence-origin:live"]
}
