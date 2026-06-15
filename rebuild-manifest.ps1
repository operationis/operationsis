# Regenerates data-manifest.json by scanning the local "Data Source" folder.
# Run this whenever you add / remove / rename CSV files before re-uploading.
param([string]$Root = (Split-Path -Parent $PSCommandPath))
$dataDir = Join-Path $Root 'Data Source'
if (-not (Test-Path $dataDir)) { Write-Host "Data Source folder not found at $dataDir"; exit 1 }
$files = Get-ChildItem -Path $dataDir -Filter '*.csv' | Sort-Object Name | ForEach-Object { $_.Name }
$manifest = [ordered]@{
  generated_at = (Get-Date).ToString('o')
  base_path    = 'Data Source'
  files        = $files
}
$out = Join-Path $Root 'data-manifest.json'
$manifest | ConvertTo-Json -Depth 5 | Out-File -FilePath $out -Encoding utf8 -Force
Write-Host "Wrote $out with $($files.Count) file(s)."
foreach ($f in $files) { Write-Host "  - $f" }
