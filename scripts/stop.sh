#!/usr/bin/env bash
set -euo pipefail

cao shutdown --all || true

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/agent-decision-workbench"
PID_FILE="$STATE_DIR/cao-server.pid"

if [ -f "$PID_FILE" ]; then
  pid="$(cat "$PID_FILE")"
  if kill -0 "$pid" 2>/dev/null; then
    kill "$pid" || true
  fi
  rm -f "$PID_FILE"
fi

echo "Stopped CAO sessions and the workbench-started server when present."
