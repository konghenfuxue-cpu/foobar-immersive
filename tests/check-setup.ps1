$ErrorActionPreference='Stop'
. (Join-Path $PSScriptRoot '..\scripts\SetupHelpers.ps1')
$root=Join-Path ([IO.Path]::GetTempPath()) ('foobar 中文 test '+[guid]::NewGuid())
try {
 New-Item -ItemType Directory -Path $root | Out-Null
 $profile=Join-Path $root 'profile'
 New-Item -ItemType Directory -Path $profile | Out-Null
 [IO.File]::WriteAllText((Join-Path $profile 'keep.txt'),'original')
 $backup=Backup-FoobarProfile $profile
 if([IO.File]::ReadAllText((Join-Path $backup 'keep.txt')) -ne 'original'){throw 'backup mismatch'}
 $player=Join-Path $root 'player'
 New-Item -ItemType Directory -Path $player | Out-Null
 New-Item -ItemType File -Path (Join-Path $player 'portable_mode_enabled') | Out-Null
 if((Get-FoobarProfile $player) -ne (Join-Path $player 'profile')){throw 'portable detection failed'}
 if((Get-SetupPlan -HasPlayer $false -HasFoobox $false) -notcontains 'player'){throw 'missing player step'}
 if((Get-SetupPlan -HasPlayer $true -HasFoobox $true) -contains 'player'){throw 'unexpected player step'}
 Add-Type -AssemblyName System.IO.Compression.FileSystem
 $archive=Join-Path $root 'test.zip'
 $zip=[IO.Compression.ZipFile]::Open($archive,[IO.Compression.ZipArchiveMode]::Create)
 $entry=$zip.CreateEntry('x64/foo_test.dll')
 $writer=[IO.StreamWriter]::new($entry.Open());$writer.Write('fixture');$writer.Dispose();$zip.Dispose()
 $packageDir=Join-Path $profile 'user-components-x64\foo_test\samples'
 New-Item -ItemType Directory -Path $packageDir -Force | Out-Null
 [IO.File]::WriteAllText((Join-Path $packageDir 'keep.js'),'keep')
 Install-X64Component $archive $profile 'foo_test'
 if([IO.File]::ReadAllText((Join-Path $packageDir 'keep.js')) -ne 'keep'){throw 'samples lost'}
 if([IO.File]::ReadAllText((Join-Path $profile 'user-components-x64\foo_test\foo_test.dll')) -ne 'fixture'){throw 'component extraction failed'}
 'PASS: setup backup, portable path, plan and component preservation'
} finally {if(Test-Path -LiteralPath $root){Remove-Item -LiteralPath $root -Recurse -Force}}
