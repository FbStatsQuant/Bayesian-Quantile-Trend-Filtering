$ErrorActionPreference = 'Stop'
$taskRoot = 'G:/My Drive/Quantile Regression/PMALA version Tex Project'
$taskBackup = Join-Path $PSScriptRoot 'before'
$taskUtf8 = New-Object System.Text.UTF8Encoding($false)
function Normalize-Source([string]$text) { return $text.Replace(([string][char]13+[char]10),([string][char]10)).TrimEnd()+[char]10 }
function Source-Hash([string]$text) {
    $hash = [System.Security.Cryptography.SHA256]::Create()
    return [BitConverter]::ToString($hash.ComputeHash([Text.Encoding]::UTF8.GetBytes($text))).Replace('-','').ToLower()
}
$taskChanges = Get-Content -Raw -LiteralPath (Join-Path $PSScriptRoot 'changes.json') | ConvertFrom-Json
$taskPrepared = @()
foreach ($change in $taskChanges) {
    $path = Join-Path $taskRoot ('sections/'+$change.file)
    $original = Normalize-Source ([IO.File]::ReadAllText($path))
    if ((Source-Hash $original) -eq $change.after) { Write-Output ($change.file+' already synchronized'); continue }
    if ((Source-Hash $original) -ne $change.before) { throw ('Local edits detected in '+$path) }
    $lines = New-Object 'System.Collections.Generic.List[string]'
    $lines.AddRange([string[]]$original.Split([char]10))
    foreach ($op in ($change.ops | Sort-Object start -Descending)) {
        $lines.RemoveRange([int]$op.start,[int]$op.remove)
        $lines.InsertRange([int]$op.start,[string[]]$op.add)
    }
    $updated = $lines -join [char]10
    if ((Source-Hash $updated) -ne $change.after) { throw ('Result mismatch in '+$change.file) }
    $taskPrepared += [pscustomobject]@{Path=$path; Name=$change.file; Text=$updated}
}
New-Item -ItemType Directory -Force -Path $taskBackup | Out-Null
foreach ($file in $taskPrepared) {
    $backupFile = Join-Path $taskBackup $file.Name
    if (!(Test-Path -LiteralPath $backupFile)) { Copy-Item -LiteralPath $file.Path -Destination $backupFile }
    [IO.File]::WriteAllText($file.Path,$file.Text,$taskUtf8)
    Write-Output ($file.Name+' synchronized and SHA-256 verified')
}
$taskPdf = Join-Path $taskRoot 'main.pdf'
$taskPdfBackup = Join-Path $taskBackup 'main.pdf'
if ((Test-Path -LiteralPath $taskPdf) -and !(Test-Path -LiteralPath $taskPdfBackup)) {
    Copy-Item -LiteralPath $taskPdf -Destination $taskPdfBackup
}
