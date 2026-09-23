#!/usr/bin/env bash
set -uo pipefail

ok=0
bad=0

check() {
  local name="$1"
  shift
  if "$@" >/tmp/adw-doctor.out 2>/tmp/adw-doctor.err; then
    printf '[OK]   %s\n' "$name"
    ok=$((ok+1))
  else
    printf '[FAIL] %s\n' "$name"
    sed -n '1,3p' /tmp/adw-doctor.err | sed 's/^/       /'
    bad=$((bad+1))
  fi
}

check_env() {
  local name="$1"
  local var="$2"
  if [ -n "${!var-}" ]; then
    printf '[OK]   %s\n' "$name"
    ok=$((ok+1))
  else
    printf '[FAIL] %s\n' "$name"
    bad=$((bad+1))
  fi
}

# ── CLI availability ──────────────────────────────────────────────
check "tmux"        tmux -V
check "curl"        curl --version
check "Codex CLI"   codex --version
check "Claude Code" claude --version
check "Composio CLI" composio --help
check "CAO"         cao --help

# ── Claude native developer agent ─────────────────────────────────
if [ -f "$HOME/.claude/agents/workbench-developer.md" ]; then
  if grep -q 'name: workbench-developer' "$HOME/.claude/agents/workbench-developer.md" 2>/dev/null; then
    printf '[OK]   Claude native dev agent (workbench-developer)\n'
    ok=$((ok+1))
  else
    printf '[FAIL] Claude native dev agent (workbench-developer) — missing name field\n'
    bad=$((bad+1))
  fi
else
  printf '[FAIL] Claude native dev agent (workbench-developer) — file not found\n'
  bad=$((bad+1))
fi

# ── CAO profiles ──────────────────────────────────────────────────
check "profile: jev_supervisor"   cao profile show jev_supervisor
check "profile: claude_developer" cao profile show claude_developer
check "profile: codex_reviewer"   cao profile show codex_reviewer

# ── Optional custom Anthropic provider environment ─────────────────
if [[ -n "${ANTHROPIC_BASE_URL:-}" || -n "${ANTHROPIC_TARGET_API_URL:-}" ]]; then
  check_env "ANTHROPIC_BASE_URL"       ANTHROPIC_BASE_URL
  check_env "ANTHROPIC_TARGET_API_URL" ANTHROPIC_TARGET_API_URL
else
  printf '[INFO] Standard Claude provider mode; custom Anthropic endpoints not configured.\n'
fi

# ── Summary ───────────────────────────────────────────────────────
printf '\nSummary: %s checks passed, %s failed.\n' "$ok" "$bad"

if [ "$bad" -gt 0 ]; then
  echo 'One or more prerequisites missing. Fix above failures and re-run.'
  exit 1
fi

echo 'All prerequisites met.'
