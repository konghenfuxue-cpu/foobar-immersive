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
# File names alone do not establish runtime compatibility. Check the DLL versions
# supplied by the selected upstream profile before copying any overlay files.
$runtimeRequirements = @(
    @{ Folder = 'foo_uie_eslyric'; Name = 'ESLyric'; Minimum = [version]'1.0.6.2'; Url = 'https://github.com/ESLyric/release/releases/tag/1.0.6.2' },
    @{ Folder = 'foo_uie_jsplitter'; Name = 'JSplitter'; Minimum = [version]'4.3.4'; Url = 'https://github.com/dima-lur/jsplitter/releases/tag/v4.3.4' }
)
foreach ($runtime in $runtimeRequirements) {
    $candidates = @('user-components-x64', 'user-components') | ForEach-Object {
        Join-Path $profileRoot (Join-Path $_ ($runtime.Folder + '\' + $runtime.Folder + '.dll'))
    }
    $dll = @($candidates | Where-Object { Test-Path -LiteralPath $_ -PathType Leaf })
    if ($dll.Count -ne 1) {
        throw "Cannot identify one $($runtime.Name) component in this profile. Install it via foobar Preferences > Components, restart and exit, then retry. See $($runtime.Url)"
    }
    $versionText = (Get-Item -LiteralPath $dll[0]).VersionInfo.FileVersion
    if ($versionText -notmatch '^\d+(\.\d+){1,3}') {
        throw "Cannot read $($runtime.Name) version: $($dll[0])"
    }
    $version = [version]$Matches[0]
    if ($version -lt $runtime.Minimum) {
        throw "$($runtime.Name) $version is too old. Required: $($runtime.Minimum) or later; pinned tutorial version: $($runtime.Minimum). Install from $($runtime.Url), restart and exit, then retry. No overlay files copied."
    }
    Write-Output ("COMPONENT: {0} {1}" -f $runtime.Name, $version)
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
