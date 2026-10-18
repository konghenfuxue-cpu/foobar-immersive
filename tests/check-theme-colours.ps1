$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot '..\scripts\ThemeColours.ps1')
$repo = Split-Path $PSScriptRoot -Parent
$dark = [IO.File]::ReadAllBytes((Join-Path $repo 'overlay\foobox\配色\深色-仅颜色.fth'))
$light = [IO.File]::ReadAllBytes((Join-Path $repo 'overlay\foobox\配色\浅色-仅颜色.fth'))
function New-Fixture([byte[]]$palette, [int]$copies = 1) {
    $stream = [IO.MemoryStream]::new()
    $writer = [IO.BinaryWriter]::new($stream)
    $writer.Write([byte[]]$palette[0..15]); $writer.Write([uint32](1 + $copies))
    $writer.Write([byte[]](1..16)); $data = [Text.Encoding]::ASCII.GetBytes('preserve-layout-and-fonts')
    $writer.Write([uint32]$data.Length)
    $md5 = [Security.Cryptography.MD5]::Create()
    try { $writer.Write($md5.ComputeHash($data)) } finally { $md5.Dispose() }
    $writer.Write($data)
    for ($i = 0; $i -lt $copies; $i++) { $writer.Write([byte[]]$palette[20..($palette.Length - 1)]) }
    $result = $stream.ToArray(); $writer.Dispose(); $stream.Dispose()
    return ,$result
}
function Assert-Bytes([byte[]]$actual, [byte[]]$expected, [string]$message) {
    if ([Convert]::ToBase64String($actual) -ne [Convert]::ToBase64String($expected)) { throw $message }
}
$source = New-Fixture $light
Assert-Bytes (Merge-FooboxThemeColours $source $dark) (New-Fixture $dark) 'Existing layout or colour section changed incorrectly'
Assert-Bytes (Merge-FooboxThemeColours (New-Fixture $light 0) $dark) (New-Fixture $dark) 'Missing colour section was not appended correctly'
$bad = $dark.Clone(); $bad[$bad.Length - 1] = $bad[$bad.Length - 1] -bxor 1
foreach ($case in @(@($source, $bad), @((New-Fixture $light 2), $dark))) {
    $rejected = $false
    try { $null = Merge-FooboxThemeColours $case[0] $case[1] } catch { $rejected = $true }
    if (-not $rejected) { throw 'Corrupt or ambiguous theme was accepted' }
}
'PASS: replace colours, preserve other sections, append missing colours, reject checksum corruption and duplicate sections'
