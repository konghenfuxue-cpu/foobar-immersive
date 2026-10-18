# SPDX-License-Identifier: GPL-3.0-only
function Get-FoobarProfile([string]$PlayerDirectory) {
 if(Test-Path -LiteralPath (Join-Path $PlayerDirectory 'portable_mode_enabled')) {return Join-Path $PlayerDirectory 'profile'}
 return Join-Path $env:APPDATA 'foobar2000-v2'
}
function Get-SetupPlan([bool]$HasPlayer,[bool]$HasFoobox) {
 if(-not $HasPlayer){'player'}
 if(-not $HasFoobox){'foobox'}
 'components'; 'backup'; 'overlay'
}
function Backup-FoobarProfile([string]$Profile) {
 $source=(Resolve-Path -LiteralPath $Profile).ProviderPath.TrimEnd('\')
 $backup=$source+'.before-immersive-'+(Get-Date -Format 'yyyyMMdd-HHmmssfff')
 if(Test-Path -LiteralPath $backup){throw '备份目录已存在，请稍后再试。'}
 Copy-Item -LiteralPath $source -Destination $backup -Recurse -ErrorAction Stop
 $files=@(Get-ChildItem -LiteralPath $source -File -Recurse)
 foreach($file in $files){
  $copy=Join-Path $backup $file.FullName.Substring($source.Length).TrimStart('\')
  if((Get-FileHash -LiteralPath $file.FullName).Hash -ne (Get-FileHash -LiteralPath $copy).Hash){throw "备份校验失败：$copy"}
 }
 return $backup
}
function Get-VerifiedAsset([string]$Repository,[string]$Tag,[string]$Name,[string]$Cache,[string]$ExpectedHash='',[string]$OfflineDirectory=(Join-Path $PSScriptRoot '..\dependencies')) {
 # Check bundled originals before contacting any network API.
 if($ExpectedHash){
  $bundled=Join-Path $OfflineDirectory $Name
  if(Test-Path -LiteralPath $bundled -PathType Leaf){
   if((Get-FileHash -LiteralPath $bundled).Hash -ne $ExpectedHash){throw "包内依赖校验失败：$Name，请重新下载安装包。"}
   Write-Host "使用包内依赖：$Name"
   return $bundled
  }
  $cached=Join-Path $Cache $Name
  if((Test-Path -LiteralPath $cached -PathType Leaf) -and (Get-FileHash -LiteralPath $cached).Hash -eq $ExpectedHash){return $cached}
 }
 $headers=@{'User-Agent'='foobar-immersive-setup';'Accept'='application/vnd.github+json'}
 $release=Invoke-RestMethod -Uri "https://api.github.com/repos/$Repository/releases/tags/$Tag" -Headers $headers
 $asset=@($release.assets | Where-Object name -eq $Name)
 if($asset.Count -ne 1){throw "找不到固定版本下载：$Name"}
 $hash=$ExpectedHash
 if(-not $hash -and $asset[0].digest -match '^sha256:([a-fA-F0-9]{64})$'){$hash=$Matches[1]}
 if(-not $hash){throw "上游未提供校验值，停止自动安装：$Name"}
 $destination=Join-Path $Cache $Name
 if(Test-Path -LiteralPath $destination){
  if((Get-FileHash -LiteralPath $destination).Hash -eq $hash){return $destination}
 }
 $part=$destination+'.part'
 Write-Host "正在下载：$Name"
 Invoke-WebRequest -Uri $asset[0].browser_download_url -OutFile $part -UseBasicParsing
 if((Get-FileHash -LiteralPath $part).Hash -ne $hash){throw "下载校验失败：$Name，请重新运行助手。"}
 Move-Item -LiteralPath $part -Destination $destination -Force
 return $destination
}
function Install-X64Component([string]$Archive,[string]$Profile,[string]$Component) {
 Add-Type -AssemblyName System.IO.Compression.FileSystem
 $zip=[IO.Compression.ZipFile]::OpenRead($Archive)
 $target=Join-Path $Profile ('user-components-x64\'+$Component)
 try {
  $entries=@($zip.Entries | Where-Object {$_.FullName -like 'x64/*' -and $_.Name})
  if(-not ($entries | Where-Object Name -eq ($Component+'.dll'))){throw "组件包缺少 x64 DLL：$Component"}
  foreach($entry in $entries){
   $relative=$entry.FullName.Substring(4)
   $path=[IO.Path]::GetFullPath((Join-Path $target $relative))
   if(-not $path.StartsWith(([IO.Path]::GetFullPath($target)+'\'),[StringComparison]::OrdinalIgnoreCase)){throw '组件包路径越界'}
   [IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($path)) | Out-Null
   [IO.Compression.ZipFileExtensions]::ExtractToFile($entry,$path,$true)
  }
 } finally {$zip.Dispose()}
}
