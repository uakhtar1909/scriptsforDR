param(
    [string]$WorkspaceId,
    [string]$SharedKey,
    [string]$LogType = "DRActivity",
    [string]$RunType,
    [string]$AppName,
    [string]$PrimaryRegion,
    [string]$SecondaryRegion,
    [string]$Status,
    [string]$TriggeredBy,
    [string]$CorrelationId = ""
)

$TimeStamp = (Get-Date).ToUniversalTime().ToString("o")

$Body = @(
    @{
        TimeGenerated   = $TimeStamp
        RunType         = $RunType
        AppName         = $AppName
        PrimaryRegion   = $PrimaryRegion
        SecondaryRegion = $SecondaryRegion
        Status          = $Status
        TriggeredBy     = $TriggeredBy
        CorrelationId   = $CorrelationId
    }
) | ConvertTo-Json

$BodyBytes = [System.Text.Encoding]::UTF8.GetBytes($Body)
$ContentLength = $BodyBytes.Length
$Method = "POST"
$ContentType = "application/json"
$Resource = "/api/logs"
$Date = [DateTime]::UtcNow.ToString("r")

$StringToHash = "$Method`n$ContentLength`n$ContentType`n"x-ms-date:$Date"`n$Resource"
$BytesToHash = [Text.Encoding]::UTF8.GetBytes($StringToHash)
$KeyBytes = [Convert]::FromBase64String($SharedKey)
$HmacSha256 = New-Object System.Security.Cryptography.HMACSHA256
$HmacSha256.Key = $KeyBytes
$HashedBytes = $HmacSha256.ComputeHash($BytesToHash)
$Signature = [Convert]::ToBase64String($HashedBytes)

$Authorization = "SharedKey $WorkspaceId:$Signature"
$Uri = "https://$WorkspaceId.ods.opinsights.azure.com$Resource?api-version=2016-04-01"

$Headers = @{
    "Authorization" = $Authorization
    "Log-Type"      = $LogType
    "x-ms-date"     = $Date
    "time-generated-field" = "TimeGenerated"
}

Invoke-RestMethod -Uri $Uri -Method Post -Headers $Headers -ContentType $ContentType -Body $Body
