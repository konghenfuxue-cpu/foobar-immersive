# Foobar Immersive · 沉浸听歌

基于 [foobox-cn](https://github.com/dream7180/foobox-cn) 的 foobar2000 主题整合与局部改造：四页导航、左歌词右封面、模糊封面背景、随封面变色的实时频谱，以及深浅配色。

**[下载离线正式版](https://github.com/konghenfuxue-cpu/foobar-immersive/releases/latest)** · **[新手安装教程](docs/BEGINNER.md)** · [变化记录](CHANGELOG.md)

下载名称含 **offline** 的 ZIP，右键“全部提取”，双击 **一键安装.cmd**。按中文提示选择播放器目录，不用输入 PowerShell 命令。

离线包已包含固定版本的 foobox 基础主题、ESLyric 和 JSplitter 原包，安装这些依赖不用再次下载；助手会备份配置、更新组件、启用歌词脚本控制并应用默认深色。**播放器主程序仍需单独安装**，首次安装 foobox 时仍需完成上游安装向导。

## 安装后效果

以下两张来自本轮新装播放器的实际验证：添加自己的歌曲后，显示歌词、封面、背景和频谱。

![新装播放器实测：左歌词右封面、模糊背景及实时频谱](docs/screenshots/verified-immersive-installed.png)

![新装播放器实测：播放列表、专辑封面与侧栏歌词](docs/screenshots/verified-music-installed.png)

界面强调色可随歌曲封面变化。封面与歌词需要歌曲标签或可用歌词来源；本包不附带音乐、歌词或私人音乐库。歌曲封面、歌词及简介内容归相应权利人所有，截图仅用于界面说明。

### 四个页面

| 页面 | 用途 |
| --- | --- |
| 我的音乐 | 播放列表、歌曲信息与侧栏歌词。 |
| 音乐库 | 按专辑封面浏览收藏，需选择正确的播放列表或媒体库数据源。 |
| 沉浸歌词 | 左侧歌词、右侧封面，底部实时频谱。 |
| 歌曲信息 | Biography 艺术家或专辑资料，在线内容取决于来源是否可用。 |

<details>
<summary>更多界面：音乐库、深浅配色和个人默认插画</summary>

![独立配置实测音乐库](docs/screenshots/verified-library-dark.png)

| 浅色示例 | 深色示例 |
| --- | --- |
| ![浅色沉浸界面](docs/screenshots/immersive-light.png) | ![深色沉浸界面](docs/screenshots/immersive-dark.png) |

以下为个人配置的默认插画展示，**该插画不随公开安装包提供**，安装后不会自动出现。

![个人配置：耳机少女与猫默认封面](docs/screenshots/immersive-default-art.png)

插画参考自 HDVN10 音效版的 `NoBack.png`，分享者为得闲饮茶吃个包，原画作者尚未确认。私人阴影等素材同样不打包。来源见 [ATTRIBUTION.md](ATTRIBUTION.md)。

</details>

## 安装与使用

1. 安装 Windows **x64** 播放器。中文用户从 [Asion 汉化版作者发布页](https://www.cnblogs.com/asionwu/p/21537446) 获取普通 x64 版；原版从 [foobar2000 官网](https://www.foobar2000.org/download) 获取。本轮验证版本为 **2.25.10 x64**。
2. 到 [Releases](https://github.com/konghenfuxue-cpu/foobar-immersive/releases/latest) 下载 **offline ZIP**，解压后双击 **一键安装.cmd**。已有播放器先完全退出。
3. 确认目标目录。foobox 上游向导可能自动找到另一套播放器，务必改为本次 `foobar2000.exe` 所在目录，**不要选 `profile` 子目录**。
4. 安装完成后启动，拖入自己的歌曲。批量导入使用 `Ctrl+P → 媒体库` 添加音乐文件夹。

固定组合为 **foobox 8.8 + JSplitter 4.3.4 + ESLyric 1.0.6.2**，不要用布局结构不同的 foobox 8.14 替代。上游原包、署名和校验保留；维护者已确认取得打包分发同意，见 [离线依赖说明](docs/OFFLINE-DEPENDENCIES.md)。不包含播放器主程序、汉化安装器、歌曲或私人配置。

托盘播放：`Ctrl+P → 显示 → 默认用户界面 → 后台与通知`，选择“最小化：隐藏到系统托盘，关闭：退出”。点击窗口“—”隐藏，右下角托盘图标恢复。此设置需手动开启。

停止或尚未播放时，沉浸页可能无歌词与封面，开始播放后显示；真正暂停与停止是不同状态。进度条可拖动，底部频谱是实时声音显示，不是整首歌的波形。

完整步骤与备份恢复见 [新手教程](docs/BEGINNER.md)；技术细节和手动覆盖方式见 [安装说明](docs/INSTALL.md)。GitHub 自动生成的 Source code 是源码包，不包含离线依赖，普通用户请选择 offline 资源包。

## 近期更新 · 2026-10-19

- 发布中文离线安装助手，设为正式发布与 Latest 下载入口。
- 修复 Windows PowerShell 5.1 安装清单数组错误。
- 补齐首次安装 ESLyric 脚本控制初始化，修复歌词白底和沉浸布局未启用。
- 修复冷启动列表、封面偶发空白；启动阶段有限同步当前页面，无常驻轮询。
- 本轮用户已逐步验证新装播放器、主要页面效果和托盘恢复。长期稳定性、其他屏幕尺寸和全新操作系统仍不在已完成结论内。

完整变化见 [CHANGELOG.md](CHANGELOG.md)，验证证据与边界见 [docs/VALIDATION.md](docs/VALIDATION.md)。公开包未包含仍在本机测试的托盘内存优化，不承诺固定内存值。

## 来源与致谢

本项目属于配置整合与局部改造，不把参考主题称为原创成果。完整来源、参考版本、涉及文件与分发边界见 [ATTRIBUTION.md](ATTRIBUTION.md)。

特别致谢 **Asion、dream7180 / dreamawake、雾隐凝霜（锦瑟）、jk、隔壁老王66662、得闲饮茶吃个包、贴吧闲云哥**，以及各组件、脚本和汉化作者。

同期参考的整合包包括：**【闲云哥出品】2025-11-19 更新 foobar2000-v2.25.3[x86]-VIP 特别定制版**，由贴吧闲云哥分享。

## 文件与许可证

- `Setup.ps1`、`一键安装.cmd`：中文安装助手。
- `Install.ps1`：默认只检查的覆盖层安装器。
- `overlay/`：五份 JS 脚本、公开歌词布局及只含颜色的主题文件。
- `docs/`：安装教程、来源说明、截图和验证记录。

foobox 衍生脚本及本项目新增代码按 **GPL-3.0** 发布，见 [LICENSE](LICENSE)。第三方软件与素材的权利归各自作者，本仓库许可证不替他们授权。
