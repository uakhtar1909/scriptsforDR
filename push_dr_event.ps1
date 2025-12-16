param(
    [string]$StorageAccountName,
    [string]$ContainerName = "dr-events",
    [string]$AppName,
    [string]$PrimaryRegion,
    [string]$SecondaryRegion,
    [string]$RunType,
    [string]$Stage,
    [string]$Status,
    [string]$PipelineRunId
)

$EventTime = (Get-Date).ToUniversalTime()
$Timestamp = $EventTime.ToString("yyyy-MM-ddTHH-mm-ssZ")
$DateFolder = $EventTime.ToString("yyyy-MM-dd")

$BlobName = "$DateFolder/$RunType-$Stage-$Timestamp.json"

$Payload = @{
    EventTime       = $EventTime.ToString("o")
    RunType         = $RunType
    Stage           = $Stage
    AppName         = $AppName
    PrimaryRegion   = $PrimaryRegion
    SecondaryRegion = $SecondaryRegion
    Status          = $Status
    TriggeredBy     = "AzureDevOps"
    PipelineRunId   = $PipelineRunId
}

$tempFile = New-TemporaryFile
$Payload | ConvertTo-Json -Depth 5 | Out-File $tempFile -Encoding utf8

az storage blob upload `
  --account-name $StorageAccountName `
  --container-name $ContainerName `
  --name $BlobName `
  --file $tempFile `
  --auth-mode login `
  --overwrite true

Remove-Item $tempFile
