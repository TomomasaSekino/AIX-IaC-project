param(
    [string]$TfVarsPath = "terraform.tfvars.example"
)

$ErrorActionPreference = "Stop"

function Test-RequiredFile {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) {
        throw "Required file not found: $Path"
    }
}

function Test-RequiredText {
    param(
        [string]$Path,
        [string]$Pattern,
        [string]$Message
    )
    $content = Get-Content -LiteralPath $Path -Raw
    if ($content -notmatch $Pattern) {
        throw $Message
    }
}

function Get-TfVarValue {
    param([string]$Name)

    $content = Get-Content -LiteralPath $TfVarsPath
    $pattern = '^\s*' + [regex]::Escape($Name) + '\s*=\s*(?:"([^"]*)"|([^#\s]+)).*$'
    foreach ($line in $content) {
        if ($line -match $pattern) {
            if ($Matches[1]) {
                return $Matches[1]
            }
            return $Matches[2]
        }
    }

    return $null
}

function Test-LiveInput {
    param(
        [string]$Name,
        [string]$Placeholder
    )

    $value = Get-TfVarValue -Name $Name
    if ([string]::IsNullOrWhiteSpace($value)) {
        throw "Live-ready preflight failed: $Name must be explicitly set in $TfVarsPath."
    }

    if (-not [string]::IsNullOrWhiteSpace($Placeholder) -and $value -eq $Placeholder) {
        throw "Live-ready preflight failed: $Name is still set to the repository safe example placeholder."
    }

    Write-Host "$Name is explicitly supplied for live validation; value intentionally not displayed."
}

Write-Host "PVS-IAC-002 preparation preflight: non-destructive checks only"

$terraform = Get-Command terraform -ErrorAction SilentlyContinue
if (-not $terraform) {
    throw "Terraform CLI is required but was not found in PATH."
}

terraform version

Test-RequiredFile "versions.tf"
Test-RequiredFile "providers.tf"
Test-RequiredFile "main.tf"
Test-RequiredFile "variables.tf"
Test-RequiredFile "outputs.tf"
Test-RequiredFile $TfVarsPath

Test-RequiredText -Path "versions.tf" -Pattern 'IBM-Cloud/ibm' -Message "versions.tf must require the official IBM Cloud provider."
Test-RequiredText -Path "main.tf" -Pattern 'ibm_pi_workspace' -Message "main.tf must define a PowerVS workspace resource."
Test-RequiredText -Path "main.tf" -Pattern 'ibm_pi_network' -Message "main.tf must define a PowerVS network resource."
Test-RequiredText -Path "main.tf" -Pattern 'ibm_pi_catalog_images' -Message "main.tf must define a PowerVS catalog image lookup."
Test-RequiredText -Path "main.tf" -Pattern 'ibm_pi_image' -Message "main.tf must define a PowerVS image import resource."
Test-RequiredText -Path "main.tf" -Pattern 'ibm_pi_key' -Message "main.tf must define a Terraform-managed PowerVS SSH public key."
Test-RequiredText -Path "main.tf" -Pattern 'ibm_pi_instance' -Message "main.tf must define a PowerVS AIX instance resource."
Test-RequiredText -Path "main.tf" -Pattern 'ibm_pi_volume' -Message "main.tf must define a PowerVS volume resource."

if ((Split-Path -Leaf $TfVarsPath) -eq "terraform.tfvars.example") {
    Test-RequiredText -Path $TfVarsPath -Pattern 'enable_live_resources\s*=\s*false' -Message "Safe example must keep enable_live_resources = false."
    Write-Host "Safe template preflight: terraform.tfvars.example is intentionally not live-ready."
    Write-Host "Live-ready result: false. Supply a separate tfvars file for the later approved live validation task."
} else {
    Test-LiveInput -Name "ibm_region" -Placeholder ""
    Test-LiveInput -Name "powervs_zone" -Placeholder ""
    Test-LiveInput -Name "resource_group_id" -Placeholder "00000000000000000000000000000000"
    Test-LiveInput -Name "ssh_public_key" -Placeholder "ssh-rsa AAAA0000000000000000000000000000000000000000000000000000000000000000 pvs-iac-placeholder"
    Test-LiveInput -Name "aix_stock_image_id" -Placeholder "00000000-0000-0000-0000-000000000000"
    Test-LiveInput -Name "aix_stock_image_name" -Placeholder "AIX-stock-image-placeholder"
    Test-LiveInput -Name "aix_evidence_reachability_mode" -Placeholder ""

    $reachabilityMode = Get-TfVarValue -Name "aix_evidence_reachability_mode"
    if ($reachabilityMode -eq "public-network") {
        $publicReviewed = Get-TfVarValue -Name "public_network_exposure_reviewed"
        if ($publicReviewed -ne "true") {
            throw "Live-ready preflight failed: public-network reachability requires public_network_exposure_reviewed = true after Human exposure review."
        }
        Write-Host "public-network reachability selected; exposure review flag is present. Public identifiers are not displayed."
    } elseif ($reachabilityMode -eq "private-network") {
        Write-Host "private-network reachability selected. Confirm the Human-controlled execution environment has an approved private route before apply."
    } else {
        throw "Live-ready preflight failed: aix_evidence_reachability_mode must be private-network or public-network."
    }

    Write-Host "Live-ready input preflight passed for required non-secret inputs."
}

$requiredEnv = @("IC_API_KEY")
foreach ($name in $requiredEnv) {
    $value = [Environment]::GetEnvironmentVariable($name)
    if ([string]::IsNullOrWhiteSpace($value)) {
        Write-Warning "$name is not set. This is acceptable for fmt/validate but must be set for the later approved live task."
    } else {
        Write-Host "$name is set; value intentionally not displayed."
    }
}

Write-Host "Preflight completed. No resources were created, changed, or deleted."
