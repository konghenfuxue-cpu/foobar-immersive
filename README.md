# Foobar Immersive · 沉浸听歌

基于 [foobox-cn](https://github.com/dream7180/foobox-cn) 的个人界面改造：四个主页面、左歌词右封面、模糊封面背景、随封面变色的频谱，以及深浅配色。

**这是主题源码覆盖层，需要先安装兼容的 foobox；不包含 foobar2000 主程序、组件 DLL、歌曲或第三方整合包。**

## 界面预览

左边看歌词，右边看封面，让本地音乐也有一个适合专心听歌的界面。

![沉浸歌词：双语歌词、封面、模糊背景和随色频谱](docs/screenshots/immersive-bilingual.png)

> 以下为个人配置实机截图，展示改造方向。公开仓库是源码覆盖层，截图中的部分第三方素材、阴影与配置未包含在发布包内；安装后效果取决于原有 foobox 布局、组件、封面和歌词。歌曲封面、歌词及简介内容归相应权利人所有，截图仅用于界面演示，不代表音乐资源随项目提供。

### 深浅配色

同一首《遇见》的深浅模式对比。截图中的高亮色为实机设置示例，公开包提供独立定义的深灰橙色与浅色配色。

| 浅色模式 | 深色模式 |
| --- | --- |
| ![浅色沉浸歌词，正文高亮](docs/screenshots/immersive-light.png) | ![深色沉浸歌词，正文高亮](docs/screenshots/immersive-dark.png) |

点击图片可查看原图。

### 四个主页面

| 页面 | 用途 |
| --- | --- |
| 我的音乐 | 播放列表、歌曲信息与侧边歌词，适合日常选歌。 |
| 音乐库 | 按专辑封面浏览本地收藏。 |
| 沉浸歌词 | 左侧滚动歌词、右侧封面，底部显示实时频谱。 |
| 歌曲信息 | 查看艺术家或专辑简介，需要原布局提供 Biography 及相应内容来源。 |

<details>
<summary>展开查看：我的音乐、音乐库、歌曲信息</summary>

#### 我的音乐

![我的音乐：播放列表与侧边歌词](docs/screenshots/my-music.png)

#### 音乐库

![音乐库：专辑封面浏览](docs/screenshots/music-library.png)

#### 歌曲信息

![歌曲信息：专辑封面和简介](docs/screenshots/song-info.png)

</details>

## 功能

- 顶部切换“我的音乐 / 音乐库 / 沉浸歌词 / 歌曲信息”；简介页面在原布局提供 Biography 时显示。
- 沉浸页展开歌词区域，显示左侧歌词、右侧封面和底部 ESLyric 内置频谱。
- 进度条保留普通拖动定位；频谱显示在进度条上方，不是整首歌曲的静态波形。
- 频谱沿用 foobox 提取的封面强调色，并调整暗色强调色的可读性。
- 两份仅颜色的 `.fth`，可通过 foobar 原生导入切换，避免覆盖页面布局。
- 移除独立可视化页面的脚本入口；ESLyric 内置频谱保留。

## 安装

先阅读 [安装与使用](docs/INSTALL.md)。本机改造基线为 Windows、foobar2000 2.25.3 x64、foobox DUI、JSplitter 4.0.4.4-beta、ESLyric 1.0.6.2 Beta。其他 foobox 版本需核对面板名称与脚本入口。

2026-10-12 已通过用户“关于”截图确认主程序升级为 **foobar2000 2.25.10 x64 · Asion 汉化版**，来源为 [Asion 发布文章（2026-08-24 更新）](https://www.cnblogs.com/asionwu/p/21537446)。上述 2.25.3 是最初改造基线；主程序版本确认不等于全部组件已更新或长期稳定性验证完成。

```powershell
# 只检查，默认不写入。先关闭 foobar。
.\Install.ps1 -ProfilePath "$env:APPDATAoobar2000-v2"

# 确认输出的文件列表后应用覆盖层。
.\Install.ps1 -ProfilePath "$env:APPDATAoobar2000-v2" -Apply
```

发布版歌词布局采用不带第三方图片的简洁实现。私人配置中的 foocolor 阴影图和默认封面没有打包，因此不会与私人截图逐像素相同。公开配色是独立定义的深灰橙色与浅色，不分发原作者的主题文件。

## 来源与致谢

本项目属于配置整合与局部改造，不把参考主题称为原创成果。完整来源、参考版本、涉及文件与分发边界见 [ATTRIBUTION.md](ATTRIBUTION.md)。

特别致谢 **Asion、dream7180 / dreamawake、雾隐凝霜（锦瑟）、jk、隔壁老王66662、得闲饮茶吃个包、贴吧闲云哥**，以及各组件、脚本和汉化作者。

最早参考的整合包也保留署名：**【闲云哥出品】2025-11-19 更新 foobar2000-v2.25.3[x86]-VIP 特别定制版**，由贴吧闲云哥分享。

## 文件

- `overlay/foobox/script/`：需要替换或增加的五份 JS 源码，保留上游署名。
- `overlay/eslyric-data/layout/`：公开版沉浸布局和日常歌词布局。
- `overlay/foobox/配色/`：独立颜色定义生成的深浅 `.fth`，不含布局。
- `Install.ps1`：默认只检查的安装入口。
- `docs/VALIDATION.md`：已验证内容与尚未验证的边界。

## 许可证

foobox 衍生脚本遵循 **GPL-3.0**，本项目新增代码也按 GPL-3.0 发布，见 [LICENSE](LICENSE)。第三方软件及参考主题的权利归各自作者；本仓库许可证不替他们授权。

### JSplitter 升级记录 · 2026-10-12

独立便携测试环境将 JSplitter 从 4.0.4.4-beta 升级到 **4.3.4 x64**；用户反馈持续播放正常后，已将相同组件文件迁入正式配置，主程序为 foobar2000 2.25.10 x64。正式版长期稳定性仍继续观察，不据此宣称历史崩溃已根治。升级方式及简介包注意事项见 [安装说明](docs/INSTALL.md#升级-jsplitter)。组件请从 [JSplitter 官方发布页](https://github.com/dima-lur/jsplitter/releases/tag/v4.3.4) 获取，本仓库不分发 DLL 或私人测试配置。
