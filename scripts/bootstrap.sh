#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

say() { printf '\n==> %s\n' "$*"; }
fail() { printf '\nERROR: %s\n' "$*" >&2; exit 1; }

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || fail "Missing required command: $1"
}

say "Checking base dependencies"
need_cmd tmux
need_cmd uv
need_cmd codex
need_cmd claude
need_cmd composio

if ! command -v cao >/dev/null 2>&1; then
  say "Installing CLI Agent Orchestrator from PyPI"
  uv tool install cli-agent-orchestrator
else
  say "CAO already installed: $(command -v cao)"
fi

say "Configuring Composio plugins for detected Codex / Claude Code installs"
composio setup --target auto --yes

say "Validating CAO profiles"
cao profile validate "$ROOT/profiles/jev-supervisor.md"
cao profile validate "$ROOT/profiles/codex-developer.md"
cao profile validate "$ROOT/profiles/claude-reviewer.md"

say "Installing CAO profiles"
cao install "$ROOT/profiles/jev-supervisor.md"
cao install "$ROOT/profiles/codex-developer.md"
cao install "$ROOT/profiles/claude-reviewer.md"

cat <<'EOF'

Bootstrap complete.

Next:

  1) If Jev is not linked yet:
       composio link jev

  2) Run:
       ./scripts/doctor.sh

  3) Launch:
       ./scripts/launch.sh

No API keys are stored by this repository.
EOF
