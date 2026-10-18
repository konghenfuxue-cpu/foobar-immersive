# SPDX-License-Identifier: GPL-3.0-only
# Pure byte transformation: preserves every non-colour FTH section.
function Read-FooboxTheme {
    param([Parameter(Mandatory)][byte[]]$Bytes)
    if ($Bytes.Length -lt 20) { throw 'Theme header is truncated.' }
    $magic = '98-BA-A0-AD-D4-36-16-4A-8E-14-41-5F-73-B4-CB-21'
    if ([BitConverter]::ToString($Bytes, 0, 16) -ne $magic) { throw 'Unrecognised FTH header.' }
    $stream = [IO.MemoryStream]::new($Bytes, $false)
    $reader = [IO.BinaryReader]::new($stream)
    $md5 = [Security.Cryptography.MD5]::Create()
    try {
        $header = $reader.ReadBytes(16)
        $count = $reader.ReadUInt32()
        if ($count -gt 128) { throw 'Unexpected FTH section count.' }
        $sections = @()
        for ($i = 0; $i -lt $count; $i++) {
            if ($stream.Length - $stream.Position -lt 36) { throw 'Truncated FTH section.' }
            $guid = $reader.ReadBytes(16)
            $length = $reader.ReadUInt32()
            $digest = $reader.ReadBytes(16)
            if ($length -gt $stream.Length - $stream.Position) { throw 'Invalid FTH section length.' }
            $data = $reader.ReadBytes([int]$length)
            if ([Convert]::ToBase64String($digest) -ne [Convert]::ToBase64String($md5.ComputeHash($data))) { throw 'FTH section checksum failed.' }
            $sections += [pscustomobject]@{ Guid = $guid; Key = [BitConverter]::ToString($guid); Data = $data; Digest = $digest }
        }
        if ($stream.Position -ne $stream.Length) { throw 'Unexpected trailing FTH bytes.' }
        return [pscustomobject]@{ Header = $header; Sections = $sections }
    } finally { $md5.Dispose(); $reader.Dispose(); $stream.Dispose() }
}
function Merge-FooboxThemeColours {
    param([Parameter(Mandatory)][byte[]]$ThemeBytes, [Parameter(Mandatory)][byte[]]$ColourBytes)
    $theme = Read-FooboxTheme $ThemeBytes
    $palette = Read-FooboxTheme $ColourBytes
    $colourKey = '8C-EE-8C-59-8D-8A-8D-48-AA-95-CA-5B-DA-02-62-2D'
    if ($palette.Sections.Count -ne 1 -or $palette.Sections[0].Key -ne $colourKey) { throw 'Expected a colour-only theme.' }
    $matches = @($theme.Sections | Where-Object { $_.Key -eq $colourKey })
    if ($matches.Count -gt 1) { throw 'Duplicate colour sections in destination theme.' }
    $sections = @($theme.Sections | ForEach-Object { if ($_.Key -eq $colourKey) { $palette.Sections[0] } else { $_ } })
    if ($matches.Count -eq 0) { $sections += $palette.Sections[0] }
    $stream = [IO.MemoryStream]::new()
    $writer = [IO.BinaryWriter]::new($stream)
    try {
        $writer.Write([byte[]]$theme.Header); $writer.Write([uint32]$sections.Count)
        foreach ($section in $sections) {
            $writer.Write([byte[]]$section.Guid); $writer.Write([uint32]$section.Data.Length)
            $writer.Write([byte[]]$section.Digest); $writer.Write([byte[]]$section.Data)
        }
        return ,$stream.ToArray()
    } finally { $writer.Dispose(); $stream.Dispose() }
}
