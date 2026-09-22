# AGENTS.md

本文件是所有 Codex 任务必须遵循的项目级说明。

## 每次开始任务

1. 阅读 `README.md`。
2. 阅读 `docs/PRODUCT.md`、`docs/ARCHITECTURE.md`、`docs/DISCOVERY.md` 和 `docs/DECISIONS.md`。
3. 阅读 `docs/HANDOFF.md`，确认当前目标与下一步。
4. 运行 `git status --short` 和 `git log -5 --oneline`，不要覆盖用户未提交的改动。
5. 只处理当前目标；如果目标会改变产品范围或核心架构，先记录问题，不要自行扩张范围。

## 产品原则

- 宠物首先是一个持续存在、能被观察和互动的角色，不是带宠物皮肤的聊天框。
- 高频互动必须即时响应。网络决策可以晚到，但本地动画反馈不能等待网络。
- 无网络、无 API Key、Jev 不可用时，核心互动仍应成立。
- 情绪和动作应由连续状态驱动，避免每轮对话像一个全新的角色。
- 动态 UI 来自受限组件目录和 DSL，不允许模型生成任意客户端代码。

## 架构硬约束

- UI 层不得直接调用 Jev 或模型 API。
- Domain 层使用纯 Dart 模型，不能依赖 Flutter Widget、Flame Component 或网络客户端。
- Planner 只能输出 `ActionRegistry` 中已注册的类型化动作。
- Executor 是唯一可以执行动画、声音、导航、状态写入等副作用的层。
- 禁止 `eval`、动态脚本执行、把模型文本当作函数名反射调用。
- 所有外部计划必须经过 schema、参数范围、动作数量和超时校验。
- 每个复杂行为必须有确定性的本地回退方案。
- 状态变更与行为计划应可记录，便于回放和测试。
- API Key 只存在于服务端环境或本机安全配置中，绝不能编译进客户端。

## 预期模块

```text
app/lib/
├─ app/            # 路由、主题、依赖装配
├─ domain/         # PetState、WorldState、事件、动作协议
├─ planner/        # 本地规则、Jev 适配器、计划校验
├─ executor/       # 动画/声音/移动/状态动作执行
├─ scene/          # Flame 房间与宠物组件
├─ ui/             # Flutter 页面、面板、动态 UI 组件目录
├─ persistence/    # SQLite 仓储与迁移
└─ observability/  # 事件日志、回放和调试面板
```

## 工作方式

- 优先做最小垂直切片，不提前建设庞大的通用框架。
- 一个提交只表达一个清晰意图；提交信息使用 `feat:`、`fix:`、`docs:`、`test:`、`refactor:`、`chore:`。
- 新增能力时，同时补充动作 schema、校验、执行器和测试。
- 新增产品或架构决策时更新 `docs/DECISIONS.md`。
- 每次停止工作前更新 `docs/HANDOFF.md`：完成内容、验证结果、阻塞项、下一步和重点文件。

## 验证

统一入口：

```powershell
.\scripts\check.ps1
```

Flutter 工程创建后，至少运行：

```powershell
Set-Location app
flutter analyze
flutter test
```

如果因环境或成本无法执行某项检查，要在 `docs/HANDOFF.md` 中明确记录，没有运行的检查不能写成已通过。

## 文件与秘密

- 不提交 `.env`、密钥、令牌、本地数据库、日志、构建产物或 IDE 用户配置。
- `.env.example` 只能包含变量名和无敏感性的示例值。
- 不随意改动无关文件，不清理或回滚用户已有改动。
