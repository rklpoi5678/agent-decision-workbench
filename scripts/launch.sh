#!/usr/bin/env bash
set -euo pipefail

SESSION="${1:-decision-workbench}"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/agent-decision-workbench"
mkdir -p "$STATE_DIR"

server_up() {
  python3 - <<'PY'
import socket
s = socket.socket()
s.settimeout(0.2)
try:
    raise SystemExit(0 if s.connect_ex(("127.0.0.1", 9889)) == 0 else 1)
finally:
    s.close()
PY
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
echo "CAO server log: $STATE_DIR/cao-server.log"

exec cao launch \
  --agents jev_supervisor \
  --session-name "$SESSION" \
  --provider claude_code
