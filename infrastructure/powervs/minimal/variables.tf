variable "enable_live_resources" {
  description = "Safety switch. Keep false for non-live validation; set true only for a separately approved PVS-IAC-002 live plan."
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

variable "ssh_public_key" {
  description = "SSH public key material for the Terraform-managed PowerVS key. Never store the matching private key in this repository."
  type        = string
  default     = "ssh-rsa AAAA0000000000000000000000000000000000000000000000000000000000000000 pvs-iac-placeholder"
  sensitive   = false

  validation {
    condition     = can(regex("^ssh-rsa [A-Za-z0-9+/=]+( .*)?$", trimspace(var.ssh_public_key)))
    error_message = "ssh_public_key must be an SSH RSA public key string."
  }
}

variable "ssh_key_visibility" {
  description = "Visibility for the Terraform-managed PowerVS SSH public key."
  type        = string
  default     = "workspace"

  validation {
    condition     = contains(["workspace", "account"], var.ssh_key_visibility)
    error_message = "ssh_key_visibility must be workspace or account."
  }
}

variable "aix_stock_image_id" {
  description = "Explicit IBM stock AIX catalog image ID to import into the newly created PowerVS workspace."
  type        = string
  default     = "00000000-0000-0000-0000-000000000000"

  validation {
    condition     = length(trimspace(var.aix_stock_image_id)) > 0
    error_message = "aix_stock_image_id must not be empty."
  }
}

variable "aix_stock_image_name" {
  description = "Explicit IBM stock AIX catalog image name expected to match aix_stock_image_id exactly during live plan."
  type        = string
  default     = "AIX-stock-image-placeholder"

  validation {
    condition     = length(trimspace(var.aix_stock_image_name)) > 0
    error_message = "aix_stock_image_name must not be empty."
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

variable "aix_evidence_reachability_mode" {
  description = "Network path intended for AIX read-only Evidence after apply. Public network mode requires explicit exposure review before live apply."
  type        = string
  default     = "private-network"

  validation {
    condition     = contains(["private-network", "public-network"], var.aix_evidence_reachability_mode)
    error_message = "aix_evidence_reachability_mode must be private-network or public-network."
  }
}

variable "public_network_exposure_reviewed" {
  description = "Must be true only when Human has reviewed public SSH exposure, access controls, and validation duration for the exact live plan."
  type        = bool
  default     = false
}

variable "private_network_route_reviewed" {
  description = "Must be true only when Human has confirmed the private route, VPN, bastion, or equivalent path for AIX Evidence collection."
  type        = bool
  default     = false
}

variable "aix_evidence_ssh_user" {
  description = "AIX login user intended for read-only post-apply Evidence collection."
  type        = string
  default     = "root"

  validation {
    condition     = length(trimspace(var.aix_evidence_ssh_user)) > 0
    error_message = "aix_evidence_ssh_user must not be empty."
  }
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
  default     = ["project:aix-iac", "task:pvs-iac-002", "evidence-origin:live"]
}
