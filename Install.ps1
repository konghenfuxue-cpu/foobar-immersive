# SPDX-License-Identifier: GPL-3.0-only
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$ProfilePath,
    [switch]$Apply
)
$ErrorActionPreference = 'Stop'
$profileRoot = (Resolve-Path -LiteralPath $ProfilePath).ProviderPath
$overlayRoot = Join-Path $PSScriptRoot 'overlay'
$required = @(
    'foobox\script\js_panels\bottombar.js',
    'foobox\script\js_common\common.js',
    'foobox\script\js_common\splitterh.js',
    'foobox\script\js_common\splitterve.js',
    'foobox\script\js_common\splitterESLProp.js'
)
foreach ($relative in $required) {
    if (-not (Test-Path -LiteralPath (Join-Path $profileRoot $relative) -PathType Leaf)) {
        throw "Not a compatible foobox profile: missing $relative"
    }
}
$items = @(Get-ChildItem -LiteralPath $overlayRoot -Recurse -File)
$manifest = @(Get-Content -LiteralPath (Join-Path $PSScriptRoot 'manifest.json') -Raw -Encoding UTF8 | ConvertFrom-Json)
foreach ($entry in $manifest) {
    $sourceFile = Join-Path $PSScriptRoot $entry.path
    if ((Get-FileHash -LiteralPath $sourceFile -Algorithm SHA256).Hash.ToLowerInvariant() -ne $entry.sha256) {
        throw "Package integrity check failed: $($entry.path)"
    }
}
if ($items.Count -ne $manifest.Count) { throw 'Manifest file count mismatch.' }
if ($Apply -and @(Get-Process -Name foobar2000 -ErrorAction SilentlyContinue).Count -gt 0) {
    throw 'Close foobar2000 before applying the overlay.'
}
foreach ($item in $items) {
    $relative = $item.FullName.Substring($overlayRoot.Length).TrimStart('\','/')
    $destination = [IO.Path]::GetFullPath((Join-Path $profileRoot $relative))
    $prefix = $profileRoot.TrimEnd('\','/') + [IO.Path]::DirectorySeparatorChar
    if (-not $destination.StartsWith($prefix, [StringComparison]::OrdinalIgnoreCase)) {
        throw "Destination outside profile: $relative"
    }
    Write-Output ("{0}: {1}" -f $(if ($Apply) { 'COPY' } else { 'CHECK' }), $relative)
    if ($Apply) {
        [IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($destination)) | Out-Null
        Copy-Item -LiteralPath $item.FullName -Destination $destination -Force
    }
}
if ($Apply) { Write-Output 'Overlay copied. Enable FooboxImmersive in ESLyric and import the colour-only theme if desired.' }
else { Write-Output 'No files changed. Run with -Apply to install.' }
