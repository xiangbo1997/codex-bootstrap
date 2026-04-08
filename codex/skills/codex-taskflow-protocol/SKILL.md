---
name: codex-taskflow-protocol
description: Run this protocol for any non-trivial task. It enforces sequential thinking, context capture, planning, execution discipline, and verification via the `.codex` artifacts.
---

# Codex Taskflow Protocol

## Overview

Every substantial request (>1 step) must follow this loop: think → scan → plan → implement → verify → report. This skill defines what each stage must produce and how to keep the `.codex` evidence trail consistent.

## Stage Map

| Stage | Deliverables | Notes |
| --- | --- | --- |
| 0. Information Gathering | Sequential-thinking log, `.codex/context-scan.json`, `.codex/context-current.json` | Always trigger `sequential-thinking` (or log a manual substitute if the tool is unavailable). |
| 1. Planning | Updated `.codex/plan.md` checklist | Cover inputs/outputs, data changes, exception handling, acceptance criteria, rollback. |
| 2. Execution | Code + tests + `.codex/operations-log.md` entries | Prefer TDD, limit each atomic change to ≤30 lines when possible, reuse existing utilities. |
| 3. Verification | Test results in `.codex/verification.md`, ready-to-share summary | Tests/static checks run ≤3 attempts; document failures before asking user for help. |

## Stage 0 – Information Gathering

- Call `sequential-thinking` and capture background, risks, and rollback ideas before touching the repo.
- Inspect project structure with `ls -R`, `rg`, or focused equivalents.
- Write the snapshot outputs to `.codex/context-scan.json`; update `.codex/context-current.json` with what is relevant for this task (key files, open questions, dependencies).
- Only ask the user after exhausting self-service discovery.

## Stage 1 – Planning

- Record a checklist in `.codex/plan.md` containing:
  - Inputs/outputs and data model deltas.
  - Edge cases and exception handling strategy.
  - Acceptance criteria (how you will know work is done).
  - Rollback strategy if changes need to be reverted.
- Update the plan whenever scope changes, keeping at most one “in progress” step if you use the CLI plan tool.

## Stage 2 – Execution

- Favor TDD: write or update tests before/alongside the implementation.
- Keep individual edits small (target ≤30 modified lines) and reuse utilities from `util/`, `common/`, `helper/`, etc. instead of re-inventing code.
- When making key decisions (trade-offs, alternative paths, risk mitigation), append concise notes to `.codex/operations-log.md`.
- Annotate complex logic in Chinese comments when documentation is necessary.
- Never run destructive operations (schema drops, `rm -rf`, force pushes) without explicit user approval.

## Stage 3 – Verification & Delivery

- Run the relevant test or lint commands. Abort after 3 consecutive failures and record the fault analysis instead of brute forcing.
- Capture command invocations and results in `.codex/verification.md`.
- Ensure README/API docs are updated if functionality changed.
- Communicate status using the structured template:
  - ✅ Done
  - 🚧 In progress
  - ❌ Blockers / requests

## Recovery Patterns

- If a tool fails (e.g., Desktop Commander, exa), gracefully downgrade to shell/grep and document the fallback.
- For repeated build/test failures, halt, rerun `sequential-thinking` to reason about root causes, and summarize findings before asking the user.

Follow this protocol every time to keep work auditable and to minimize context tokens—load only this skill when you need the workflow details.
