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
 $offline=Join-Path $root 'offline'
 New-Item -ItemType Directory -Path $offline | Out-Null
 [IO.File]::WriteAllText((Join-Path $offline 'fixture.bin'),'offline')
 $hash=(Get-FileHash -LiteralPath (Join-Path $offline 'fixture.bin')).Hash
 function Invoke-RestMethod {throw 'Unexpected network access'}
 $local=Get-VerifiedAsset 'invalid/repo' 'none' 'fixture.bin' $root $hash $offline
 if($local -ne (Join-Path $offline 'fixture.bin')){throw 'offline file not selected'}
 $rejected=$false
 try {Get-VerifiedAsset 'invalid/repo' 'none' 'fixture.bin' $root ('0'*64) $offline | Out-Null} catch {$rejected=$_.Exception.Message -match '校验'}
 if(-not $rejected){throw 'corrupt offline file not rejected'}
 Remove-Item Function:\Invoke-RestMethod
 Add-Type -AssemblyName System.IO.Compression, System.IO.Compression.FileSystem
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
 $eslDir=Join-Path $profile 'user-components-x64\foo_uie_eslyric'
 New-Item -ItemType Directory -Path $eslDir -Force | Out-Null
 [IO.File]::WriteAllText((Join-Path $eslDir 'foo_uie_eslyric.dll'),'fixture')
 Enable-FoobarLyricControl $profile
 $marker=Join-Path $eslDir 'enable_script_control'
 if(-not (Test-Path -LiteralPath $marker) -or (Get-Item -LiteralPath $marker).Length -ne 0){throw 'script control marker missing'}
 Enable-FoobarLyricControl $profile
 'PASS: setup backup, portable path, plan and component preservation'
} finally {if(Test-Path -LiteralPath $root){Remove-Item -LiteralPath $root -Recurse -Force}}
