# 当前交接

最后更新：2026-09-22

## 当前目标

完成 M0 项目基线，并在下一台电脑开始 M1 的 Flutter 垂直切片。

## 已完成

- 创建并克隆独立的 `jevpet` 仓库。
- 写明产品定位、MVP 范围、性能目标和动态 UI 原则。
- 定义 Jev → Action Registry → Validator → Executor 的架构边界。
- 确定 Flutter + Flame；动画资产在序列帧与 Rive 之间做小型验证后决定。
- 添加路线图、决策记录、环境模板和提交前检查脚本。
- 保存第一张房间/宠物概念图及其来源、尺寸和哈希记录。
- 新增 `docs/DISCOVERY.md`，沉淀 Jev 调研、早期方案演化和视觉讨论。

## 下一步（按顺序）

1. 在 `app` 目录初始化 Flutter 项目：

   ```powershell
   Set-Location app
   flutter create --platforms=android,windows,web --org com.xiongzhenglong .
   ```

2. 运行默认测试，记录本机 Flutter/Dart 版本；考虑使用 FVM 固定版本。
3. 添加 Flame，建立一个固定尺寸的房间场景与可点击的宠物占位组件。
4. 只实现点击 → 即时反馈这一条路径，暂不连接 Jev。

## 待确认问题

- M1 动画对比：序列帧 atlas 与 Rive 各做多小的样例才足以判断。
- 服务端技术栈尚未决定；M1 不依赖服务端。
- 宠物正式外观和房间美术暂不阻塞程序垂直切片。

## 验证状态

- 文档和必需文件检查：待首个提交前运行 `scripts/check.ps1`。
- Flutter 构建与测试：尚未初始化 Flutter 工程，因此未运行。
- Jev 调用：未接入，不需要 API Key。

## 继续工作时给 Codex

```text
阅读 AGENTS.md、docs/PRODUCT.md、docs/ARCHITECTURE.md、
docs/DISCOVERY.md、docs/DECISIONS.md 和 docs/HANDOFF.md。
检查 git status 和最近提交，
从“下一步”第一项开始完成 M1 的最小垂直切片。不要接入 Jev，
先保证点击后的本地即时反馈可运行、可测试。停止前更新本文件。
```
