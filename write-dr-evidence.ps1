param (
    [Parameter(Mandatory)] [string] $Stage,           # Start / Complete
    [Parameter(Mandatory)] [string] $AppName,
    [Parameter(Mandatory)] [string] $PrimaryRegion,
    [Parameter(Mandatory)] [string] $SecondaryRegion,
    [Parameter(Mandatory)] [string] $PipelineRunId
)

$eventTime = (Get-Date).Show

$record = [ordered]@{
    Timestamp        = $eventTime
    Stage            = $Stage
    AppName          = $AppName
    PrimaryRegion    = $PrimaryRegion
    SecondaryRegion  = $SecondaryRegion
    PipelineRunId    = $PipelineRunId
}

$evidencePath = "$(System.DefaultWorkingDirectory)/evidence/dr-evidence.json"

if (-not (Test-Path $evidencePath)) {
    @($record) | ConvertTo-Json -Depth 3 | Out-File $evidencePath
}
else {
    $existing = Get-Content $evidencePath | ConvertFrom-Json
    $existing += $record
    $existing | ConvertTo-Json -Depth 3 | Out-File $evidencePath
}

Write-Host "DR Evidence recorded: $Stage"
