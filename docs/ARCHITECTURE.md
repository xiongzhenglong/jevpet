# 架构说明

## 总体结构

```text
Flutter UI / Flame Scene
          │ UserEvent
          ▼
    InteractionController
          │
          ├── ImmediateReaction（本地即时反馈）
          │
          ▼
      ContextBuilder
          │ PetState + WorldState + Memory
          ▼
        Planner
     ┌────┴────┐
 LocalPlanner  JevPlanner
     └────┬────┘
          ▼
      PlanValidator
          ▼
     BehaviorExecutor
          │
     ┌────┼────────┬─────────┐
 Animation  Audio  State  UI Patch
          │
          ▼
 Repository + EventLog + Replay
```

## 关键模型

### `PetState`

- `mood`：连续情绪值与当前情绪标签。
- `energy`：活动与休息消耗。
- `satiety`：饱腹状态。
- `bond`：关系亲密度，变化应缓慢。
- `location`：房间内的逻辑位置。
- `activeBehavior`：当前行为及可否被打断。
- `lastInteractionAt`：时间驱动行为的依据。

### `WorldState`

- 当前房间与时间段。
- 可交互物品及其位置、状态。
- 环境事件，例如昼夜、天气主题、特殊日期。

### `UserEvent`

输入统一转换为类型化事件，例如：

- `pet.tapped`
- `pet.called`
- `item.placed`
- `care.feed_requested`
- `dialogue.submitted`
- `clock.tick`

## 行为能力协议

所有可执行能力必须注册，不允许通过任意字符串寻找函数。初始能力示例：

| 能力 ID | 作用 | 关键限制 |
|---|---|---|
| `pet.look_at` | 看向目标 | 目标必须存在 |
| `pet.move_to` | 移动到逻辑位置 | 位置在房间可行走区域内 |
| `pet.play_animation` | 播放已登记动画 | 动画名必须在资产清单中 |
| `pet.vocalize` | 播放宠物短声音 | 只允许登记的声音 ID |
| `pet.speak` | 展示一句话 | 字数、频率和内容需校验 |
| `state.adjust` | 调整状态 | 每项变化有上下限 |
| `ui.show_card` | 展示动态卡片 | 模板必须在 UI Registry 中 |
| `wait` | 行为间停顿 | 有最大时长 |

动作 schema 应放在 Domain 层，由本地规则与 Jev 适配器共同使用。

## 行为计划示例

```json
{
  "version": 1,
  "intent": "care.play",
  "actions": [
    { "type": "pet.look_at", "target": "user" },
    { "type": "pet.play_animation", "name": "happy_jump" },
    { "type": "pet.vocalize", "sound": "chirp_02" },
    { "type": "state.adjust", "field": "bond", "delta": 1 }
  ],
  "fallback": "reaction.happy_acknowledge"
}
```

计划必须满足：

- schema 版本可识别。
- 动作数量不超过预算。
- 每个类型已注册且参数合法。
- 总预计时长不超过上限。
- 状态变更在允许范围内。
- 必须存在本地 fallback。

## Planner 路由

优先级从快到慢：

1. 明确、高频事件直接命中本地规则。
2. 多义输入、复杂状态或多步组合交给 Jev。
3. Jev 超时、错误、无密钥或计划校验失败时使用本地 fallback。

Jev 的价值是从不断增加的能力中做上下文匹配和流程组合，而不是代替渲染引擎或业务代码。

## 行为执行器

Executor 负责副作用与并发控制：

- 串行动作与可并行动作。
- 行为优先级和打断规则。
- 动画完成、超时与取消。
- 应用进入后台后的暂停与恢复。
- 执行前后状态写入。
- 失败后的补偿与回退。

第一版保持执行模型简单：同一宠物只有一个主行为队列；即时反应可以作为不改变核心状态的覆盖动画。

## 动态 UI DSL

Planner 只能返回受限 UI Patch：

```json
{
  "surface": "room.overlay",
  "operation": "show",
  "component": "choice_card",
  "props": {
    "title": "它想和你玩",
    "options": ["逗猫棒", "纸团"]
  },
  "ttlMs": 8000
}
```

客户端组件目录负责字体、颜色、动效、布局和无障碍。外部决策不能传入 Widget 代码、CSS、脚本或任意 URL。

## 数据与回放

建议至少保存：

- `pet_snapshot`：当前宠物快照。
- `world_snapshot`：房间状态。
- `interaction_event`：归一化输入事件。
- `behavior_plan`：Planner 输出与来源。
- `action_result`：每个动作的结果、耗时和错误。

事件日志用于调试和产品分析；快照用于快速启动。Schema 变更必须有迁移版本。

## 服务边界

客户端只能调用自有服务端，不直接携带 Jev 或语言模型密钥。服务端职责：

- 认证、限流和请求预算。
- Jev/模型适配。
- 输入裁剪与敏感信息过滤。
- 输出 schema 校验的第一道防线。
- 缓存可复用决策。

客户端仍需再次校验，因为服务返回也属于外部输入。

## 测试策略

- Domain：状态变化与边界值单元测试。
- Planner：同一上下文的确定性 fallback 测试。
- Validator：未知能力、越界参数、超长计划的拒绝测试。
- Executor：顺序、并发、取消、超时测试。
- Scene：关键交互的组件测试与截图回归。
- Replay：给定事件日志重建相同最终状态。
