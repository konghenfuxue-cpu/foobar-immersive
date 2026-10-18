# SPDX-License-Identifier: GPL-3.0-only
[CmdletBinding()]
param([string]$PlayerDirectory,[switch]$CheckOnly)
$ErrorActionPreference='Stop'
. (Join-Path $PSScriptRoot 'scripts\SetupHelpers.ps1')
try {
 [Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12
 Write-Host 'foobar 沉浸主题中文安装助手' -ForegroundColor Cyan
 Write-Host '请先退出播放器。助手会保留完整配置备份，不包含歌曲。'
 if(-not $PlayerDirectory){
  $candidates=@("$env:ProgramFiles\foobar2000","${env:ProgramFiles(x86)}\foobar2000")
  foreach($candidate in $candidates){if(Test-Path -LiteralPath (Join-Path $candidate 'foobar2000.exe')){$PlayerDirectory=$candidate;break}}
 }
 while(-not $PlayerDirectory -or -not (Test-Path -LiteralPath (Join-Path $PlayerDirectory 'foobar2000.exe'))){
  Write-Host '尚未找到播放器。请从作者页面安装普通 x64 版，完成后返回这里。'
  Write-Host 'https://www.cnblogs.com/asionwu/p/21537446'
  if(-not $CheckOnly){Start-Process 'https://www.cnblogs.com/asionwu/p/21537446'}
  $PlayerDirectory=(Read-Host '粘贴播放器安装文件夹路径（不是 EXE 文件）').Trim('"')
 }
 $PlayerDirectory=(Resolve-Path -LiteralPath $PlayerDirectory).ProviderPath
 $profile=Get-FoobarProfile $PlayerDirectory
 Write-Host "播放器：$PlayerDirectory"
 Write-Host "配置：$profile"
 if($CheckOnly){Write-Host '只检查结束，未下载或修改配置。';exit 0}
 $cache=Join-Path $env:LOCALAPPDATA 'foobar-immersive\downloads'
 [IO.Directory]::CreateDirectory($cache) | Out-Null
 if(Get-Process -Name foobar2000 -ErrorAction SilentlyContinue){throw '播放器仍在运行，请通过菜单退出后重试。'}
 if(Test-Path -LiteralPath $profile){$backup=Backup-FoobarProfile $profile;Write-Host "完整备份：$backup"}
 if(-not (Test-Path -LiteralPath (Join-Path $profile 'foobox\script\js_panels\bottombar.js'))){
  $base=Get-VerifiedAsset 'dream7180/foobox-cn' '8.8' 'foobox_x64.cn.v8.8-1.exe' $cache 'abbfdd8e51a681df261a1b9df985e64bec2ff0bbaf3e952e69a94f0623419793'
  Write-Host '即将打开 foobox 官方安装窗口，请选择上面显示的播放器位置。'
  Start-Process -FilePath $base -Wait
  Read-Host '安装完成后，打开播放器一次，再完全退出，回到这里按回车' | Out-Null
 }
 if(Get-Process -Name foobar2000 -ErrorAction SilentlyContinue){throw '请完全退出播放器后重新运行。'}
 # Run prerequisite layout checks before replacing any component.
 if(-not (Test-Path -LiteralPath (Join-Path $profile 'foobox\script\js_common\splitterve.js'))){throw '基础主题布局不兼容。请安装 foobox 8.8，不能使用 8.14。'}
 $esl=Get-VerifiedAsset 'ESLyric/release' '1.0.6.2' 'foo_uie_eslyric_1.0.6.2.fb2k-component' $cache 'ab05bd9132808131580b5679de83490f46e34c85c1c39611631268aad56ac8bf'
 $js=Get-VerifiedAsset 'dima-lur/jsplitter' 'v4.3.4' 'foo_uie_jsplitter_4.3.4.fb2k-component' $cache 'bdae183482638700cb20cdf3cf687d65306b68153bdc6b1fbe391e0defd56b97'
 if(-not $backup){$backup=Backup-FoobarProfile $profile;Write-Host "完整备份：$backup"}
 Install-X64Component $esl $profile 'foo_uie_eslyric'
 Install-X64Component $js $profile 'foo_uie_jsplitter'
 & (Join-Path $PSScriptRoot 'Install.ps1') -ProfilePath $profile
 & (Join-Path $PSScriptRoot 'Install.ps1') -ProfilePath $profile -Apply
 Write-Host '安装完成：默认深色，顶部四个页面。将自己的歌曲拖入播放器即可开始。' -ForegroundColor Green
 Write-Host "遇到问题可退出播放器，用此备份恢复配置：$backup"
 if((Read-Host '现在启动播放器？直接回车启动，输入 N 暂不启动') -ne 'N'){Start-Process -FilePath (Join-Path $PlayerDirectory 'foobar2000.exe')}
} catch {Write-Host ("未完成："+$_.Exception.Message) -ForegroundColor Red;exit 1}
