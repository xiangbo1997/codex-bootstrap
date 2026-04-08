#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="$HOME/.codex-backup-$(date +%Y%m%d-%H%M%S)"
MCP_INSTALL_ERRORS=0

mkdir -p "$HOME/.local/bin" "$HOME/.codex/templates" "$BACKUP_DIR"

require_repo_file() {
  local path="$1"
  if [[ ! -e "$path" ]]; then
    echo "Missing required repo file: $path" >&2
    exit 1
  fi
}

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

ensure_path_line() {
  local rc_file="$1"
  local line='export PATH="$HOME/.local/bin:$PATH"'

  [[ -f "$rc_file" ]] || touch "$rc_file"
  grep -qsF "$line" "$rc_file" || printf '\n%s\n' "$line" >> "$rc_file"
}

have_command() {
  command -v "$1" >/dev/null 2>&1
}

MCP_ADD_MODE=""

detect_mcp_add_mode() {
  [[ -n "$MCP_ADD_MODE" ]] && return 0

  local help_output=""
  help_output="$(codex mcp add --help 2>/dev/null || true)"
  # 兼容不同 Codex CLI 版本：新版本直接 `codex mcp add <name> -- ...`，老版本可能仍要求 scope 参数。
  if printf '%s\n' "$help_output" | grep -Eq -- '(^|[[:space:]])-s,|--scope'; then
    MCP_ADD_MODE="legacy_scope"
  else
    MCP_ADD_MODE="current"
  fi
}

run_codex_mcp_add() {
  local name="$1"
  shift

  detect_mcp_add_mode

  if [[ "$MCP_ADD_MODE" == "legacy_scope" ]]; then
    codex mcp add "$name" -s user -- "$@"
  else
    codex mcp add "$name" -- "$@"
  fi
}

ensure_mcp_server() {
  local current="$1"
  local name="$2"
  shift 2

  if printf '%s\n' "$current" | grep -Eq "^${name}[[:space:]]"; then
    echo "MCP already present: $name"
    return 0
  fi

  echo "Installing MCP server: $name"
  if ! run_codex_mcp_add "$name" "$@"; then
    echo "Failed to install MCP server: $name" >&2
    MCP_INSTALL_ERRORS=$((MCP_INSTALL_ERRORS + 1))
  fi
}

install_core_mcp() {
  local current=""

  if ! have_command codex; then
    echo "Warning: codex command not found; skipped MCP auto-install." >&2
    return 0
  fi

  current="$(codex mcp list 2>/dev/null || true)"

  ensure_mcp_server "$current" sequential-thinking \
    npx -y @modelcontextprotocol/server-sequential-thinking
  ensure_mcp_server "$current" desktop-commander \
    npx -y @wonderwhy-er/desktop-commander
  ensure_mcp_server "$current" context7 \
    npx -y @upstash/context7-mcp
  ensure_mcp_server "$current" playwright \
    npx -y @playwright/mcp@latest
  ensure_mcp_server "$current" exa \
    npx -y exa-mcp-server
}

require_repo_file "$ROOT/bin/codex-init-project"
require_repo_file "$ROOT/codex/AGENTS.md"
require_repo_file "$ROOT/codex/instruction.md"
require_repo_file "$ROOT/codex/settings.local.json"
require_repo_file "$ROOT/codex/skills"
require_repo_file "$ROOT/codex/templates/project-bootstrap"

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

ensure_path_line "$HOME/.zshrc"
ensure_path_line "$HOME/.bashrc"

install_core_mcp

echo "Installed."
echo "Backup: $BACKUP_DIR"
echo "Next:"
echo "  source ~/.zshrc  # or ~/.bashrc"
echo "  command -v codex-init-project"
echo "  codex-init-project --help"
echo "  codex mcp list"

if [[ -x "$ROOT/bootstrap-check.sh" ]]; then
  echo
  echo "Running post-install verification..."
  "$ROOT/bootstrap-check.sh" --smoke-test
fi

if [[ "$MCP_INSTALL_ERRORS" -gt 0 ]]; then
  echo "Install finished with MCP installation errors." >&2
  exit 1
fi
