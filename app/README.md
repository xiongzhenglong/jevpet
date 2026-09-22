# App

这里将存放 Flutter 客户端。

初始化命令：

```powershell
Set-Location app
flutter create --platforms=android,windows,web --org com.xiongzhenglong .
```

初始化后先保留默认测试可运行，再按 `AGENTS.md` 中的模块边界逐步建立 Domain、Planner、Executor、Scene 和 UI。
