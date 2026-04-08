---
name: codex-governance-communications
description: Reference for engineering guardrails and user-facing communication norms. Load whenever you need coding standards, documentation rules, or reporting cadence.
---

# Codex Governance & Communications

## Engineering Guardrails

1. **Reuse First** – Search `util/`, `common/`, `helper/`, and similar directories plus MCP knowledge sources before inventing new helpers. Duplicate logic only if no reusable option exists and document why.
2. **Defensive Programming** – Assume inputs are hostile:
   - Validate parameters before use.
   - Cover error paths and log anomalies.
   - Keep logic cohesive and low-coupled (SOLID mindset).
3. **Change Size Discipline** – Prefer atomic edits that can be reverted independently. Keep large efforts split into smaller patches whenever possible.
4. **Chinese Comments for Complexity** – When implementation choices are non-obvious, add concise Chinese comments/docstrings explaining the reasoning so future Codex agents inherit the context.
5. **Documentation Sync** – Whenever functionality changes, update relevant README/API/interface docs and ensure `.codex/` artifacts stay in sync (plan, operations log, verification).

## High-Risk Operations Policy

- Treat destructive actions (config deletion, DB migrations, `rm -rf`, force pushes) as blocked until the user explicitly approves.
- Before asking, summarize:
  1. What you plan to do.
  2. Why the operation is necessary.
  3. The fallback or rollback plan.
- For tool failures (Desktop Commander, exa, etc.), gracefully downgrade to shell/grep equivalents and note the degradation for traceability.

## Communication Template

Use structured updates whenever sharing progress:

- ✅ **Completed** – list delivered milestones with artifacts/links.
- 🚧 **In Progress** – describe current focus and what remains.
- ❌ **Blockers & Suggestions** – articulate obstacles, attempted fixes, and proposed next actions.

Guidelines:

- Default to autonomy—only interrupt the user when blocked or when a decision could materially change scope.
- Group long tasks by milestone and report at each milestone boundary.
- When asking questions, show prior investigation steps to keep interactions efficient.

This skill keeps the governance pieces separate from workflow mechanics so you only load it when you need the policy reminders.
