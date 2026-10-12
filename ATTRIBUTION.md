# 来源、署名与文件对照

整理日期：2026-10-12。区分“实际包含的衍生代码”“本机借鉴”“依赖组件”。引用或致谢不等于取得再分发许可。

## 1. foobox-cn：实际代码基底

- 作者：**dream7180 / dreamawake**。
- 项目：https://github.com/dream7180/foobox-cn
- 上游许可证：GPL-3.0。本仓库保留完整 LICENSE 与上游 README。
- 包含的衍生文件：
  - `overlay/foobox/script/js_panels/bottombar.js`：保留播放器控制，实现主页面导航接入并去除独立可视化入口。
  - `overlay/foobox/script/js_common/splitterh.js`：沉浸页展开与原分栏比例恢复。
  - `overlay/foobox/script/js_common/splitterve.js`：沉浸页隐藏上方信息区域，退出后恢复。
  - `overlay/foobox/script/js_common/splitterESLProp.js`：ESLyric 页面控制、封面强调色与深浅背景。
- 本项目新增 `js_panels/main_pages.js`，与上述代码组成同一 GPL 覆盖层。
- 上游另致谢 br3tt、always_beta、Jensen、Asion、Wil-B 等作者；详见保留的 `UPSTREAM-README.md` 与各文件原有署名。

## 2. foocolor：歌词页与颜色参考

- 主要制作／分享：**B站 UP 主雾隐凝霜（锦瑟）**。
- 包内日志另列制作人：**隔壁老王66662、jk**。
- 本地参考包：`foocolor 4.2 (FB2K 2.25.5)` 与 `foocolor 4.2 X64(FB2K 2.25.5)`。内层目录仍标 `foocolor 4.1- 86` / `foocolor 4.1- 64`，不据此将外层版本改写为 4.1。
- 原作者介绍：https://www.bilibili.com/opus/813390565902123015
- 后续作者文章：https://www.bilibili.com/opus/1003289456819568678
- 作者演示：https://www.bilibili.com/video/BV1myzoY2EBH/
- 本机借鉴：左歌词右封面、模糊背景、底部频谱、明暗配色；私人配置曾使用 `Cover Shadow.png`、`default.png` 和“深灰 + 橙.fth”。
- **本仓库不包含上述原始图片、原主题文件、完整布局或整合包。** 公开版 XML 使用无第三方图片的替代实现，配色文件由独立颜色定义生成。
- 原包提醒免费分享且限制倒卖盈利；作者页面带转载限制。这里保留来源，不将这些主题转为 GPL。

## 3. LY：多布局和明暗适配参考

- 主要制作／分享：**雾隐凝霜（锦瑟）**。
- 参考包：`LY_1.4.9 N1(FB2K v2.24.2)`。
- 参考文件：包内 `流萤UI使用协议 LICENSE.txt`、`themes/` 的深色配色及界面脚本。
- 借鉴方向：主布局切换、深浅图标和颜色适配。
- 原协议声明界面设计及相关代码保留权利，禁止以该界面谋取商业利益；本仓库不分发 LY 源码、素材或主程序。

## 4. HDVN10：旧主题及背景参考

- 制作／分享者：**贴吧用户得闲饮茶吃个包**（收藏者提供的归属）。
- 参考包：`foobar2000-HDVN10-1.6.2汉化个人音效版`，内层 `foobar2000音效版`。
- 发布帖（用户提供）：https://tieba.baidu.com/p/9638280932?fr=frs
- 参考文件：`themes/HD10.fcl`、`themes/DarkOne_v4.0/`、`themes/Dark/` 及包内背景图。
- 借鉴方向：深色界面层次、背景呈现和旧组件用途。本次未重新核实发布帖内容，不把个人分享者写成全部组件的原作者。
- 本仓库不分发其背景图片、DSP 音效包、DLL 或整合包。

## 5. DarkOne4Mod VIP 参考

- 制作／分享署名：**贴吧闲云哥**。
- 用户提供的完整标题：**【闲云哥出品】2025-11-19更新foobar2000-v2.25.3[x86]-VIP特别定制版**。
- 本地参考文件夹标识：`DarkOne4Mod-v2.25.3CN-VIP/foobar2000`（最初收藏于用户指定的 Program Files 位置）。
- 本地文件夹存在；版本标题与分享者归属依据用户补充。尚未找到可确认的原始发布帖直链，未编造链接。
- 与其他主题及整合包在同一阶段用于研究布局与组件配置。当前改造基线是 foobox / DUI / x64，未将 VIP 整合包整体移植或上传。
- DarkOne 原主题、汉化、组件等仍分别属于对应作者；闲云哥的整合与分享身份不替代其署名。

## 6. 在线参考与运行依赖

- RVG / RivaGe：https://github.com/r1vage/RVG-for-foobar2000 ，参考主页面、深浅主题与封面强调色的设计方式；未包含 RVG 源码。
- ESLyric：https://github.com/ESLyric/release ，使用其原生歌词布局、内置频谱和 COM 控制接口，DLL 不打包。
- foobar2000：https://www.foobar2000.org/ ，主程序单独安装。
- JSplitter：按 foobox 上游依赖说明安装匹配架构的版本。

## 7. Asion：本机播放器汉化版来源

- 汉化作者：**Asion / asionwu**；foobar2000 原作者为 Peter Pawlowski 与贡献者。
- 发布文章：[foobar2000 v2.25.10 汉化版（更新日期：2026-08-24）](https://www.cnblogs.com/asionwu/p/21537446)。文章首次发布于 2026-07-16；更新日期与文章发布日期分别记录。
- 本次使用：`FB_2.25.10_x64_Asion_20260824150803.exe`，普通 x64 汉化版；2026-10-12 用户“关于”截图确认运行版本为 2.25.10 x64。
- 作者文章另介绍 Plus 版及其 foobox、JSplitter 等组件。本文列出的本机普通版来源不表示安装了 Plus，也不表示其中组件已全部升级。
- 作者保留汉化内容权利，限制未经许可的商业用途，要求传播时保持汉化文件完整。本仓库仅标注来源，不镜像安装包、汉化二进制或修改作者原始说明；GPL 许可证不涵盖其汉化作品。
- 原播放器与汉化、foobox 界面、第三方组件分别署名，不能归为本项目原创。

## 8. 公开包排除项

不单独分发歌曲、歌词正文、歌单、私人路径配置、数据库、浏览器数据、账号凭据、在线缓存、艺术家照片、专辑封面、第三方整合包、组件 DLL、字体、DSP 包或个人 crash dump。

`docs/screenshots/` 包含用户提供的实机界面截图，其中可见歌曲封面、歌词和简介，仅用于界面演示；不作为独立音乐、歌词或封面素材分发，也不改变其权利归属。
