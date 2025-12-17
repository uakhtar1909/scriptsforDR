param(
  [Parameter(Mandatory)] [string]$StorageAccountName,
  [string]$ContainerName = "dr-events",
  [Parameter(Mandatory)] [string]$PipelineRunId
)

$evidenceDir = "$(System.DefaultWorkingDirectory)/evidence"
New-Item -ItemType Directory -Force -Path $evidenceDir | Out-Null

# Download only blobs from THIS pipeline run
$blobs = az storage blob list `
  --account-name $StorageAccountName `
  --container-name $ContainerName `
  --auth-mode login `
  | ConvertFrom-Json

$matchingBlobs = $blobs | Where-Object {
  $_.name -match $PipelineRunId
}

foreach ($blob in $matchingBlobs) {
  az storage blob download `
    --account-name $StorageAccountName `
    --container-name $ContainerName `
    --name $blob.name `
    --file "$evidenceDir/$(Split-Path $blob.name -Leaf)" `
    --auth-mode login `
    --overwrite
}

Write-Host "Downloaded DR evidence for pipeline run $PipelineRunId"
