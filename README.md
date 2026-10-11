# Foobar Immersive · 沉浸听歌

基于 [foobox-cn](https://github.com/dream7180/foobox-cn) 的个人界面改造：四个主页面、左歌词右封面、模糊封面背景、随封面变色的频谱，以及深浅配色。

**这是主题源码覆盖层，需要先安装兼容的 foobox；不包含 foobar2000 主程序、组件 DLL、歌曲或第三方整合包。**

## 功能

- 顶部切换“我的音乐 / 音乐库 / 沉浸歌词 / 歌曲信息”；简介页面在原布局提供 Biography 时显示。
- 沉浸页展开歌词区域，显示左侧歌词、右侧封面和底部 ESLyric 内置频谱。
- 进度条保留普通拖动定位；频谱显示在进度条上方，不是整首歌曲的静态波形。
- 频谱沿用 foobox 提取的封面强调色，并调整暗色强调色的可读性。
- 两份仅颜色的 `.fth`，可通过 foobar 原生导入切换，避免覆盖页面布局。
- 移除独立可视化页面的脚本入口；ESLyric 内置频谱保留。

## 安装

先阅读 [安装与使用](docs/INSTALL.md)。本机改造基线为 Windows、foobar2000 2.25.3 x64、foobox DUI、JSplitter 4.0.4.4-beta、ESLyric 1.0.6.2 Beta。其他 foobox 版本需核对面板名称与脚本入口。

```powershell
# 只检查，默认不写入。先关闭 foobar。
.\Install.ps1 -ProfilePath "$env:APPDATAoobar2000-v2"

# 确认输出的文件列表后应用覆盖层。
.\Install.ps1 -ProfilePath "$env:APPDATAoobar2000-v2" -Apply
```

发布版歌词布局采用不带第三方图片的简洁实现。私人配置中的 foocolor 阴影图和默认封面没有打包，因此不会与私人截图逐像素相同。公开配色是独立定义的深灰橙色与浅色，不分发原作者的主题文件。

## 来源与致谢

本项目属于配置整合与局部改造，不把参考主题称为原创成果。完整来源、参考版本、涉及文件与分发边界见 [ATTRIBUTION.md](ATTRIBUTION.md)。

特别致谢 **dream7180 / dreamawake、雾隐凝霜（锦瑟）、jk、隔壁老王66662、得闲饮茶吃个包、贴吧闲云哥**，以及各组件、脚本和汉化作者。

最早参考的整合包也保留署名：**【闲云哥出品】2025-11-19 更新 foobar2000-v2.25.3[x86]-VIP 特别定制版**，由贴吧闲云哥分享。

## 文件

- `overlay/foobox/script/`：需要替换或增加的五份 JS 源码，保留上游署名。
- `overlay/eslyric-data/layout/`：公开版沉浸布局和日常歌词布局。
- `overlay/foobox/配色/`：独立颜色定义生成的深浅 `.fth`，不含布局。
- `Install.ps1`：默认只检查的安装入口。
- `docs/VALIDATION.md`：已验证内容与尚未验证的边界。

## 许可证

foobox 衍生脚本遵循 **GPL-3.0**，本项目新增代码也按 GPL-3.0 发布，见 [LICENSE](LICENSE)。第三方软件及参考主题的权利归各自作者；本仓库许可证不替他们授权。
