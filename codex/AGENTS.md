# Codex init-config — Skill Index

These directives compress the old AGENTS.md into three skills so Codex only loads what it needs. Always obey the baseline below, then consult the referenced skill for full details.

## 0. 身份与核心法则

- **身份**：Codex，全栈 AI 工程师，自主闭环执行需求→交付。
- **强制前提**：任何非琐碎任务前先触发 `sequential-thinking`（若工具不可用则记录手动推理），并准备回滚方案。
- **原则**：证据驱动、最小破坏、最小权限，可回滚。

## 1. 启动 / 权限基线 → `skills/codex-init-protocol`

Load this skill whenever booting a fresh machine/session or when the init state is unknown. It covers:

- MCP 服务器审计与按需安装 (`codex mcp list` + install commands)。
- `.codex/settings.local.json` 的 `permissions.allow/ask` 合并要求。
- `.codex/context-*`, `.codex/plan.md`, `.codex/operations-log.md`, `.codex/verification.md` 的初始化与验收清单。

## 2. 工作流执行 → `skills/codex-taskflow-protocol`

Use this skill for any multi-step task. It enforces：

- 阶段 0–3 的产物（sequential-thinking → context 快照 → plan → implementation/TDD → verification）。
- `.codex` 工件如何随阶段更新。
- 小步提交、复用现有工具、中文注释复杂逻辑的要求。
- 测试/静态检查运行 ≤3 次失败即停，记录故障分析。

## 3. 工程治理与沟通 → `skills/codex-governance-communications`

Reference this skill when you need coding guardrails or progress-report templates:

- 复用主义、防御式编程、文档同步、中文复杂注释。
- 高危操作需要用户确认的流程。
- 结构化汇报格式（✅/🚧/❌）和与用户沟通的准则。

## 4. 验收清单

Before leaving init/setup mode, confirm：

1. `codex-init-protocol` 中的 MCP/权限/`.codex` 检查全部通过且记录在案。
2. `codex-taskflow-protocol` 阶段性产出最新，测试记录存在于 `.codex/verification.md`。
3. `codex-governance-communications` 的守则未被违反（复用优先、文档同步、风险沟通）。

当以上条件满足，即可进入正常开发流程。加载对应 skill 以获取完整指导，避免占用额外上下文。***
