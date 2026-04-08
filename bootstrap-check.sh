#!/usr/bin/env bash
set -euo pipefail

RUN_SMOKE_TEST=0
KEEP_TEMP=0

PASS_COUNT=0
WARN_COUNT=0
FAIL_COUNT=0

if [[ -t 1 ]]; then
  GREEN="$(printf '\033[32m')"
  YELLOW="$(printf '\033[33m')"
  RED="$(printf '\033[31m')"
  RESET="$(printf '\033[0m')"
else
  GREEN=""
  YELLOW=""
  RED=""
  RESET=""
fi

usage() {
  cat <<'EOF'
Usage: ./bootstrap-check.sh [--smoke-test] [--keep-temp] [-h|--help]

Checks whether the current machine is ready to use codex-bootstrap directly.

Options:
  --smoke-test   Create a temp directory and run codex-init-project once
  --keep-temp    Keep the temp directory created by --smoke-test
  -h, --help     Show this help message
EOF
}

pass() {
  printf '%b[PASS]%b %s\n' "$GREEN" "$RESET" "$1"
  PASS_COUNT=$((PASS_COUNT + 1))
}

warn() {
  printf '%b[WARN]%b %s\n' "$YELLOW" "$RESET" "$1"
  WARN_COUNT=$((WARN_COUNT + 1))
}

fail() {
  printf '%b[FAIL]%b %s\n' "$RED" "$RESET" "$1"
  FAIL_COUNT=$((FAIL_COUNT + 1))
}

have_command() {
  command -v "$1" >/dev/null 2>&1
}

check_file() {
  local path="$1"
  local label="$2"
  if [[ -f "$path" ]]; then
    pass "$label -> $path"
  else
    fail "$label missing -> $path"
  fi
}

check_dir() {
  local path="$1"
  local label="$2"
  if [[ -d "$path" ]]; then
    pass "$label -> $path"
  else
    fail "$label missing -> $path"
  fi
}

check_command() {
  local cmd="$1"
  local label="$2"
  if have_command "$cmd"; then
    pass "$label -> $(command -v "$cmd")"
  else
    fail "$label not found in PATH"
  fi
}

check_git_identity() {
  local name=""
  local email=""
  name="$(git config --global --get user.name || true)"
  email="$(git config --global --get user.email || true)"

  if [[ -n "$name" && -n "$email" ]]; then
    pass "git identity -> $name <$email>"
  else
    warn "git identity incomplete; set user.name / user.email if you need commits"
  fi
}

check_gh_auth() {
  if ! have_command gh; then
    warn "gh not found; private repo pull/push may require manual git auth"
    return
  fi

  if gh auth status >/dev/null 2>&1; then
    pass "gh authenticated"
  else
    warn "gh installed but not authenticated; run: gh auth login -h github.com -p https && gh auth setup-git"
  fi
}

check_core_mcp() {
  local output=""
  local server=""

  if ! have_command codex; then
    fail "codex not found, cannot inspect MCP servers"
    return
  fi

  output="$(codex mcp list 2>/dev/null || true)"
  if [[ -z "$output" ]]; then
    warn "codex mcp list returned no output; verify Codex CLI setup manually"
    return
  fi

  # 这里按“是否存在配置项”判断核心 MCP 是否已准备好，避免不同 Codex 版本输出格式差异导致误判。
  for server in sequential-thinking desktop-commander context7 playwright exa; do
    if printf '%s\n' "$output" | grep -Eq "^${server}[[:space:]]"; then
      pass "core MCP present -> $server"
    else
      warn "core MCP missing -> $server"
    fi
  done
}

run_smoke_test() {
  local tmp_dir=""

  if ! have_command codex-init-project; then
    fail "smoke test skipped because codex-init-project is unavailable"
    return
  fi

  tmp_dir="$(mktemp -d "${TMPDIR:-/tmp}/codex-bootstrap-demo.XXXXXX")"
  if codex-init-project "$tmp_dir" >/dev/null 2>&1; then
    pass "smoke test command -> codex-init-project $tmp_dir"
  else
    fail "smoke test command failed -> codex-init-project $tmp_dir"
    [[ "$KEEP_TEMP" -eq 1 ]] && printf 'Temp dir kept: %s\n' "$tmp_dir"
    [[ "$KEEP_TEMP" -eq 0 ]] && rm -rf "$tmp_dir"
    return
  fi

  check_file "$tmp_dir/AGENTS.md" "smoke test AGENTS.md"
  check_dir "$tmp_dir/.codex" "smoke test .codex"
  check_dir "$tmp_dir/.agents/skills" "smoke test .agents/skills"
  check_file "$tmp_dir/.codex/context-current.json" "smoke test context-current.json"
  check_file "$tmp_dir/.codex/plan.md" "smoke test plan.md"

  if [[ "$KEEP_TEMP" -eq 1 ]]; then
    printf 'Temp dir kept: %s\n' "$tmp_dir"
  else
    rm -rf "$tmp_dir"
  fi
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --smoke-test)
      RUN_SMOKE_TEST=1
      shift
      ;;
    --keep-temp)
      KEEP_TEMP=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

echo "== codex-bootstrap environment check =="

check_command codex "codex CLI"
check_command git "git"
check_command codex-init-project "codex-init-project"

check_gh_auth
check_git_identity

check_file "$HOME/.local/bin/codex-init-project" "global codex-init-project script"
check_file "$HOME/.codex/AGENTS.md" "global AGENTS.md"
check_file "$HOME/.codex/instruction.md" "global instruction.md"
check_file "$HOME/.codex/settings.local.json" "global settings.local.json"
check_dir "$HOME/.codex/skills" "global skills directory"

check_dir "$HOME/.codex/templates/project-bootstrap" "project-bootstrap template directory"
check_file "$HOME/.codex/templates/project-bootstrap/AGENTS.md" "template root AGENTS.md"
check_file "$HOME/.codex/templates/project-bootstrap/.codex/AGENTS.md" "template .codex AGENTS.md"
check_file "$HOME/.codex/templates/project-bootstrap/.codex/config.toml" "template .codex config.toml"
check_dir "$HOME/.codex/templates/project-bootstrap/.agents/skills" "template ECC skills directory"

check_core_mcp

if [[ "$RUN_SMOKE_TEST" -eq 1 ]]; then
  run_smoke_test
fi

echo
echo "== summary =="
printf 'PASS: %s\n' "$PASS_COUNT"
printf 'WARN: %s\n' "$WARN_COUNT"
printf 'FAIL: %s\n' "$FAIL_COUNT"

if [[ "$FAIL_COUNT" -gt 0 ]]; then
  echo "Environment is not ready yet."
  exit 1
fi

echo "Environment looks usable."
