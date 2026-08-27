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

Test-RequiredText -Path $TfVarsPath -Pattern 'enable_live_resources\s*=\s*false' -Message "Safe example must keep enable_live_resources = false."
Test-RequiredText -Path "versions.tf" -Pattern 'IBM-Cloud/ibm' -Message "versions.tf must require the official IBM Cloud provider."
Test-RequiredText -Path "main.tf" -Pattern 'ibm_pi_workspace' -Message "main.tf must define a PowerVS workspace resource."
Test-RequiredText -Path "main.tf" -Pattern 'ibm_pi_network' -Message "main.tf must define a PowerVS network resource."
Test-RequiredText -Path "main.tf" -Pattern 'ibm_pi_instance' -Message "main.tf must define a PowerVS AIX instance resource."
Test-RequiredText -Path "main.tf" -Pattern 'ibm_pi_volume' -Message "main.tf must define a PowerVS volume resource."

$requiredEnv = @("IC_API_KEY")
foreach ($name in $requiredEnv) {
    $value = [Environment]::GetEnvironmentVariable($name)
    if ([string]::IsNullOrWhiteSpace($value)) {
        Write-Warning "$name is not set. This is acceptable for fmt/validate but must be set for the later approved live task."
    } else {
        Write-Host "$name is set; value intentionally not displayed."
    }
}

Write-Host "Preflight passed. No resources were created, changed, or deleted."
