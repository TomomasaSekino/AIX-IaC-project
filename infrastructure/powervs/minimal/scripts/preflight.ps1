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
    $pattern = '^\s*' + [regex]::Escape($Name) + '\s*=\s*"?([^"#\s]+)"?.*$'
    foreach ($line in $content) {
        if ($line -match $pattern) {
            return $Matches[1]
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

Write-Host "PVS-IAC-001 preflight: non-destructive checks only"

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
    Test-LiveInput -Name "ssh_key_name" -Placeholder "existing-powervs-key"
    Test-LiveInput -Name "aix_image_id" -Placeholder "00000000-0000-0000-0000-000000000000"
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
