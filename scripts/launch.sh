#!/usr/bin/env bash
set -euo pipefail

SESSION="${1:-decision-workbench}"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/agent-decision-workbench"
mkdir -p "$STATE_DIR"

server_up() {
  curl -fsS \
    --max-time 2 \
    http://127.0.0.1:9889/health \
    >/dev/null 2>&1
}

if ! command -v cao >/dev/null 2>&1; then
  echo "CAO is not installed. Run ./scripts/bootstrap.sh first." >&2
  exit 1
fi

if ! server_up; then
  echo "Starting cao-server..."
  nohup cao-server >"$STATE_DIR/cao-server.log" 2>&1 &
  echo $! >"$STATE_DIR/cao-server.pid"

  for _ in 1 2 3 4 5 6 7 8 9 10; do
    if server_up; then
      break
    fi
    sleep 0.5
  done
fi

if ! server_up; then
  echo "cao-server did not become reachable on 127.0.0.1:9889." >&2
  echo "See: $STATE_DIR/cao-server.log" >&2
  exit 1
fi

echo "Launching Claude supervisor session: $SESSION"
echo "Working directory: $PWD"
echo "CAO server log: $STATE_DIR/cao-server.log"

CAO_ARGS=(
  launch
  --agents jev_supervisor
  --session-name "$SESSION"
  --provider claude_code
  --working-directory "$PWD"
  --auto-approve
)

if [[ -n "${ANTHROPIC_BASE_URL:-}" ]]; then
  CAO_ARGS+=(--env "ANTHROPIC_BASE_URL=$ANTHROPIC_BASE_URL")
fi

if [[ -n "${ANTHROPIC_TARGET_API_URL:-}" ]]; then
  CAO_ARGS+=(--env "ANTHROPIC_TARGET_API_URL=$ANTHROPIC_TARGET_API_URL")
fi

exec cao "${CAO_ARGS[@]}"
