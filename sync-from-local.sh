#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"

mkdir -p "$ROOT/bin" "$ROOT/codex/templates"

cp "$HOME/.local/bin/codex-init-project" "$ROOT/bin/codex-init-project"
cp "$HOME/.codex/AGENTS.md" "$ROOT/codex/AGENTS.md"
cp "$HOME/.codex/instruction.md" "$ROOT/codex/instruction.md"
cp "$HOME/.codex/settings.local.json" "$ROOT/codex/settings.local.json"

rm -rf "$ROOT/codex/skills" "$ROOT/codex/templates/project-bootstrap"
cp -R "$HOME/.codex/skills" "$ROOT/codex/skills"
cp -R "$HOME/.codex/templates/project-bootstrap" "$ROOT/codex/templates/project-bootstrap"

chmod +x "$ROOT/bin/codex-init-project"

echo "Synced from local Codex config into repo snapshot."
