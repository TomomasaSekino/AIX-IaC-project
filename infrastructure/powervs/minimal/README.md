# PowerVS Minimal Terraform Adapter

This directory bootstraps the Phase 1 PowerVS Minimal IaC MVP for `PVS-IAC-001`
and carries the `PVS-IAC-002` Stage Gate 1 preparation changes.
It is intentionally non-destructive by default and does not create, change, or
delete IBM Cloud resources unless `enable_live_resources = true` is explicitly
set in a later approved live validation task.

## Scope

In scope for this adapter:

- PowerVS workspace
- PowerVS private network
- IBM stock AIX image lookup and workspace import
- Terraform-managed PowerVS SSH public key
- AIX PowerVS instance
- shareable PowerVS volume
- non-destructive preflight checks
- `terraform fmt`, `terraform init`, and `terraform validate`

Out of scope for this adapter:

- `terraform apply` or `terraform destroy` in this preparation PR
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
- `ibm_pi_catalog_images` for catalog image visibility in the target workspace.
- `ibm_pi_image` to import the explicit IBM stock AIX image into the workspace.
- `ibm_pi_key` to upload the SSH public key to the workspace.
- `ibm_pi_public_network` only when the later live plan explicitly selects
  public reachability and public exposure has been reviewed.
- `ibm_pi_instance` for the AIX VM/LPAR in Power Virtual Server.
- `ibm_pi_volume` for the shareable data volume.

Primary source references:

- IBM provider repository: <https://github.com/IBM-Cloud/terraform-provider-ibm>
- IBM provider latest release: <https://github.com/IBM-Cloud/terraform-provider-ibm/releases/tag/v2.5.0>
- `ibm_pi_workspace`: <https://github.com/IBM-Cloud/terraform-provider-ibm/blob/master/website/docs/r/pi_workspace.html.markdown>
- `ibm_pi_network`: <https://github.com/IBM-Cloud/terraform-provider-ibm/blob/master/website/docs/r/pi_network.html.markdown>
- `ibm_pi_catalog_images`: <https://github.com/IBM-Cloud/terraform-provider-ibm/blob/v2.5.0/website/docs/d/pi_catalog_images.html.markdown>
- `ibm_pi_image`: <https://github.com/IBM-Cloud/terraform-provider-ibm/blob/v2.5.0/website/docs/r/pi_image.html.markdown>
- `ibm_pi_key`: <https://github.com/IBM-Cloud/terraform-provider-ibm/blob/v2.5.0/website/docs/r/pi_key.html.markdown>
- `ibm_pi_public_network`: <https://github.com/IBM-Cloud/terraform-provider-ibm/blob/v2.5.0/website/docs/d/pi_public_network.html.markdown>
- `ibm_pi_instance`: <https://github.com/IBM-Cloud/terraform-provider-ibm/blob/v2.5.0/website/docs/r/pi_instance.html.markdown>
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
zone, resource group ID, explicit stock AIX image ID/name, SSH public key, and
network reachability parameters.

The matching SSH private key, live `terraform.tfvars`, Terraform state, plan
binary, raw live Evidence, hostnames, IP addresses, resource IDs, CRNs, account
identifiers, and credential values must not be committed or pasted into Issues,
Pull Requests, or workflow logs.

## Image And SSH Key Lifecycle

`PVS-IAC-002` creates a new PowerVS workspace, so the AIX instance cannot point
directly at a stock catalog image. IBM provider `v2.5.0` documents that
`ibm_pi_instance.pi_image_id` can use only images belonging to the target
project/workspace. This adapter therefore uses the following dependency graph:

```text
ibm_pi_workspace
  -> data.ibm_pi_catalog_images.stock
  -> ibm_pi_image.aix
  -> ibm_pi_instance.aix
```

The live tfvars file must provide both `aix_stock_image_id` and
`aix_stock_image_name`. The configuration checks that they match exactly one
catalog image before importing it. It does not select the first matching image
from a list.

SSH access uses `ibm_pi_key` and `ssh_public_key`. Only public key material is
accepted by Terraform. The private key remains in the Human-controlled execution
environment and is used only for later read-only AIX Evidence collection.

## AIX Evidence Reachability

Default reachability is `private-network`. The later live execution environment
must have an approved private route, bastion, or equivalent path to the AIX VSI
before apply is requested. If that route is not available, the live gate stops
before `terraform apply`.

`public-network` can be selected only in a later live plan after Human review of
public exposure, access controls, expected duration, and stop conditions. When
`public-network` is selected, `public_network_exposure_reviewed = true` must be
set in the live tfvars file; otherwise preflight and Terraform preconditions
stop the run. Public network selection may attach the provider-reported public
network to the validation instance and must be treated as temporary validation
exposure, not as a default architecture.

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
  `ibm_region`, `powervs_zone`, `resource_group_id`, `ssh_public_key`,
  `aix_stock_image_id`, `aix_stock_image_name`, and
  `aix_evidence_reachability_mode`
- explicit rejection of repository safe placeholders in live-ready mode
- public-network exposure review flag when public reachability is selected

When run with the repository `terraform.tfvars.example`, preflight treats the
file as a safe template check and explicitly reports that it is not live-ready.
The safe example placeholders, including the all-zero resource group ID,
all-zero AIX stock image ID, `AIX-stock-image-placeholder`, and the placeholder
SSH public key, must not pass live-ready input validation. Supply a separate
untracked tfvars file for the later approved live validation task.

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

The provider lock file is committed at
`infrastructure/powervs/minimal/.terraform.lock.hcl` and pins IBM Cloud
provider `2.5.0` for reproducible non-live validation.

## Later Live Gate Procedure

The following steps are preparation guidance only. They are not approval for
apply or destroy.

1. Create an untracked live tfvars file outside Git-managed examples.
2. Set only non-secret parameters in that file, including region, zone,
   resource group ID, stock image ID/name, SSH public key, sizing, and
   reachability mode.
3. Temporarily inject `IC_API_KEY` into the Human-controlled local shell.
4. Run preflight, `terraform init`, `terraform validate`, and `terraform plan`.
5. Review selected AIX image identity, expected resources, CPU/memory/storage,
   network exposure, estimated cost, validation duration, retry policy, and
   stop conditions.
6. Request a separate Human bounded approval for the exact `terraform apply`
   command and exact plan. Issue creation, PR merge, and plan review are not
   apply approval.
7. After apply, collect only read-only Terraform and AIX Evidence. Public
   summaries must redact or hash IP addresses, hostnames, resource IDs, CRNs,
   and account identifiers.
8. Request a separate Human bounded approval for the exact `terraform destroy`
   command after post-apply Evidence review. Apply approval does not authorize
   destroy.

## Known Provider/Product Constraints

- PowerVS workspaces are zone/datacenter-specific; provider `region` and `zone`
  must match the target PowerVS location.
- `ibm_pi_instance.pi_image_id` can use only images belonging to the target
  PowerVS project/workspace. Stock images are imported with `ibm_pi_image`
  before instance creation.
- The stock AIX image is selected by explicit ID and name. Ambiguous first-match
  selection is intentionally not used.
- SSH key lifecycle is Terraform-managed by `ibm_pi_key` using public key
  material only.
- The private network uses `ibm_pi_network` with `pi_network_type = "vlan"`.
- Public network reachability is disabled by default. If selected for temporary
  validation, exposure review is mandatory before plan/apply.
- HMC, VIOS, SEA, FC Fabric, and SAN are IBM-managed or outside direct PowerVS
  user control in this research environment and must not be reported as live
  PowerVS Evidence.
- The default `enable_live_resources = false` keeps non-live validation from
  creating, changing, or deleting IBM Cloud resources.
