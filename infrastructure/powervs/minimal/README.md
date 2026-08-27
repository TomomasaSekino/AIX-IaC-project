# PowerVS Minimal Terraform Adapter

This directory bootstraps the Phase 1 PowerVS Minimal IaC MVP for `PVS-IAC-001`.
It is intentionally non-destructive by default and does not create, change, or
delete IBM Cloud resources unless `enable_live_resources = true` is explicitly
set in a later approved live validation task.

## Scope

In scope for this adapter:

- PowerVS workspace
- PowerVS private network
- AIX PowerVS instance
- shareable PowerVS volume
- non-destructive preflight checks
- `terraform fmt`, `terraform init`, and `terraform validate`

Out of scope for this adapter:

- `terraform apply` or `terraform destroy` in `PVS-IAC-001`
- PowerHA
- NIM
- HMC, VIOS, or SAN live control
- Evidence RAG or Release Promotion implementation

## Provider And Resource Selection

Official provider:

- Terraform Registry provider: `IBM-Cloud/ibm`
- Adopted version constraint: `~> 2.5`
- Current official provider release observed on 2026-08-27: `v2.5.0`
- Provider 2.x recommends Terraform 1.5.1 or later.

Selected official PowerVS resources:

- `ibm_pi_workspace` for the PowerVS workspace/service instance.
- `ibm_pi_network` for the PowerVS network.
- `ibm_pi_instance` for the AIX VM/LPAR in Power Virtual Server.
- `ibm_pi_volume` for the shareable data volume.

Primary source references:

- IBM provider repository: <https://github.com/IBM-Cloud/terraform-provider-ibm>
- IBM provider latest release: <https://github.com/IBM-Cloud/terraform-provider-ibm/releases/tag/v2.5.0>
- `ibm_pi_workspace`: <https://github.com/IBM-Cloud/terraform-provider-ibm/blob/master/website/docs/r/pi_workspace.html.markdown>
- `ibm_pi_network`: <https://github.com/IBM-Cloud/terraform-provider-ibm/blob/master/website/docs/r/pi_network.html.markdown>
- `ibm_pi_instance`: <https://github.com/IBM-Cloud/terraform-provider-ibm/blob/master/website/docs/r/pi_instance.html.markdown>
- `ibm_pi_volume`: <https://github.com/IBM-Cloud/terraform-provider-ibm/blob/master/website/docs/r/pi_volume.html.markdown>

IBM PowerVS resource docs identify zone-specific provider settings. For a
workspace in a zone such as `lon04`, the IBM provider should use
`region = "lon"` and `zone = "lon04"`.

## Architecture Boundary

This adapter models only the `PowerVS Live Validation Platform` from the
repository architecture:

- PowerVS workspace
- AIX VSI/LPAR
- CPU, memory, network
- PowerVS volume/shareable volume

HMC, VIOS, SEA, physical FC Fabric, and SAN are not represented as live PowerVS
resources here. They remain `Virtual Reference Platform` concerns and must use
documented or simulated Evidence until a future on-prem or provider-supported
adapter can collect live Evidence.

## Credentials

Do not put credentials in Terraform files, example files, state samples, or
logs. Use environment variables at execution time:

```bash
export IC_API_KEY="..."
```

PowerVS live validation also requires non-secret account inputs such as region,
zone, resource group ID, SSH key name, and image ID.

## Non-Destructive Preflight

From this directory:

```bash
./scripts/preflight.sh
./scripts/preflight.sh path/to/live-validation.tfvars
```

On Windows PowerShell:

```powershell
./scripts/preflight.ps1
./scripts/preflight.ps1 -TfVarsPath path\to\live-validation.tfvars
```

The preflight checks:

- Terraform CLI availability and version
- required Terraform files
- default safety switch in `terraform.tfvars.example`
- presence, but not value, of `IC_API_KEY`
- required live validation inputs when a non-example tfvars file is supplied:
  `ibm_region`, `powervs_zone`, `resource_group_id`, `ssh_key_name`, and
  `aix_image_id`

When run with the repository `terraform.tfvars.example`, preflight treats the
file as a safe template check and explicitly reports that it is not live-ready.
The safe example placeholders, including the all-zero resource group ID,
all-zero AIX image ID, and `existing-powervs-key`, must not pass live-ready
input validation. Supply a separate tfvars file for the later approved live
validation task.

The preflight does not call `terraform apply`, `terraform destroy`, or IBM Cloud
resource mutation APIs.

## Terraform Validation

From this directory:

```bash
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
```

Or from the repository root:

```bash
terraform -chdir=infrastructure/powervs/minimal fmt -check -recursive
terraform -chdir=infrastructure/powervs/minimal init -backend=false -input=false
terraform -chdir=infrastructure/powervs/minimal validate
```

`terraform init -backend=false` downloads only the provider plugin and writes
local Terraform metadata such as `.terraform/` and `.terraform.lock.hcl`.
`terraform validate` checks configuration syntax and provider schemas. Neither
command creates resources.

## Known Provider/Product Constraints

- PowerVS workspaces are zone/datacenter-specific; provider `region` and `zone`
  must match the target PowerVS location.
- AIX images must already be available/imported in the target workspace before
  `ibm_pi_instance` can use `pi_image_id`.
- The private network uses `ibm_pi_network` with `pi_network_type = "vlan"`.
- HMC, VIOS, SEA, FC Fabric, and SAN are IBM-managed or outside direct PowerVS
  user control in this research environment and must not be reported as live
  PowerVS Evidence.
- The default `enable_live_resources = false` keeps this task as bootstrap only.
