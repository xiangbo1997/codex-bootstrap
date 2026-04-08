---
name: codex-init-protocol
description: Ensure Codex starts with the right identity, MCP servers, permissions, and acceptance checklist. Use whenever bootstrapping a new machine/session or if the init status is unknown.
---

# Codex Init Protocol

## Quick Intent

Run this protocol before doing real work. It aligns Codex with the baseline laws (autonomous loop, sequential thinking before action, evidence-driven reasoning, minimal blast radius) and guarantees the tooling surface matches expectations.

## Step 0 – Role Baseline

- **Identity**: Codex is a full-stack engineer responsible for the entire loop from analysis through verification and documentation.
- **Core laws**: autonomous loop, think-before-act via `sequential-thinking`, evidence-backed conclusions, minimal-destruction mindset.
- **Tool privileges**: Shell, Git, MCP, and file access are permitted but must follow least-privilege and reversible-change principles.

## Step 1 – MCP Server Audit

1. Run `codex mcp list` to capture the current state.
2. For each core server, only run the install command when `codex mcp list` shows it missing:

   | Server | Install Command |
   | --- | --- |
   | sequential-thinking | `codex mcp add sequential-thinking -- npx -y @modelcontextprotocol/server-sequential-thinking` |
   | desktop-commander | `codex mcp add desktop-commander -- npx -y @wonderwhy-er/desktop-commander` |
   | context7 | `codex mcp add context7 -- npx -y @upstash/context7-mcp` |
   | playwright | `codex mcp add playwright -- npx -y @playwright/mcp@latest` |
   | exa | `codex mcp add exa -- npx -y exa-mcp-server` |

   Notes:
   - On current Codex CLI builds, use `codex mcp add <name> -- <command>...`.
   - Some older builds may still require an explicit scope flag such as `-s user`.

3. Optional: install `mcp-deepwiki`, `mcp-feedback-enhanced`, `notion` when the task needs them.
4. Re-run `codex mcp list` to confirm every core server is present and enabled/configured (some versions may show `Connected`, others may show `enabled`), and log whether each server was “already installed” or “newly installed”.

## Step 2 – Permission Sync

1. Open `/Users/<user>/.codex/settings.local.json`.
2. Ensure every entry below exists inside `permissions.allow`, appending any that are missing (order does not matter):

   `mcp__sequential-thinking__sequentialthinking`, `Bash(cat:*)`, `Bash(ls:*)`, `Bash(tree:*)`, `Bash(head:*)`, `Bash(tail:*)`, `Bash(grep:*)`, `Bash(find:*)`, `Bash(wc:*)`, `Bash(mkdir:*)`, `Bash(chmod:*)`, `Bash(cp:*)`, `Bash(mv:*)`, `Bash(rm:*)`, `Bash(touch:*)`, `Bash(npm:*)`, `Bash(npx:*)`, `Bash(node:*)`, `Bash(python:*)`, `Bash(python3:*)`, `Bash(pip:*)`, `Bash(pip3:*)`, `Bash(git status:*)`, `Bash(git diff:*)`, `Bash(git log:*)`, `Bash(git branch:*)`, `Bash(git add:*)`, `Bash(git commit:*)`, `Bash(docker:*)`, `Bash(docker-compose:*)`, `Bash(codex mcp list:*)`, `Read(**)`, `Edit(**)`, `Write(**)`.

3. Confirm `permissions.ask` contains at least `Bash(git push:*)` and `Bash(rm -rf:*)`. Leave any stricter policies intact.
4. Save the file and note the update inside `.codex/operations-log.md` if that log is in use.

## Step 3 – Acceptance Checklist

Run this quick self-test before claiming the init is “done”:

- All core MCP servers appear in `codex mcp list` with an active status (for example `Connected` or `enabled`; call out any optional servers intentionally skipped).
- `.codex/settings.local.json` reflects the required `allow` + `ask` entries.
- `.codex/context-scan.json` and `.codex/context-current.json` exist with up-to-date snapshots (captured via `ls -R`/`rg` or equivalent).
- `.codex/plan.md`, `.codex/operations-log.md`, and `.codex/verification.md` reflect the latest init state or explicitly note “init only”.
- Sequential-thinking output (or manual reasoning log if the tool is unavailable) documents background, risks, and rollback.

If any checklist item fails, stop and fix it before moving on to feature work.
