#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="$HOME/.codex-backup-$(date +%Y%m%d-%H%M%S)"

mkdir -p "$HOME/.local/bin" "$HOME/.codex/templates" "$BACKUP_DIR"

backup_if_exists() {
  local target="$1"
  if [[ -e "$target" ]]; then
    mkdir -p "$BACKUP_DIR/$(dirname "${target#$HOME/}")"
    cp -R "$target" "$BACKUP_DIR/${target#$HOME/}"
  fi
}

copy_item() {
  local src="$1"
  local dst="$2"
  mkdir -p "$(dirname "$dst")"
  rm -rf "$dst"
  cp -R "$src" "$dst"
}

backup_if_exists "$HOME/.local/bin/codex-init-project"
backup_if_exists "$HOME/.codex/AGENTS.md"
backup_if_exists "$HOME/.codex/instruction.md"
backup_if_exists "$HOME/.codex/settings.local.json"
backup_if_exists "$HOME/.codex/skills"
backup_if_exists "$HOME/.codex/templates/project-bootstrap"

copy_item "$ROOT/bin/codex-init-project" "$HOME/.local/bin/codex-init-project"
copy_item "$ROOT/codex/AGENTS.md" "$HOME/.codex/AGENTS.md"
copy_item "$ROOT/codex/instruction.md" "$HOME/.codex/instruction.md"
copy_item "$ROOT/codex/settings.local.json" "$HOME/.codex/settings.local.json"
copy_item "$ROOT/codex/skills" "$HOME/.codex/skills"
copy_item "$ROOT/codex/templates/project-bootstrap" "$HOME/.codex/templates/project-bootstrap"

chmod +x "$HOME/.local/bin/codex-init-project"

if [[ -f "$HOME/.zshrc" ]]; then
  grep -qs 'export PATH="$HOME/.local/bin:$PATH"' "$HOME/.zshrc" || \
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc"
fi

if [[ -f "$HOME/.bashrc" ]]; then
  grep -qs 'export PATH="$HOME/.local/bin:$PATH"' "$HOME/.bashrc" || \
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
fi

echo "Installed."
echo "Backup: $BACKUP_DIR"
echo "Next:"
echo "  source ~/.zshrc  # or ~/.bashrc"
echo "  command -v codex-init-project"
echo "  codex-init-project --help"
echo "  codex mcp list"
