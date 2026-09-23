#!/usr/bin/env bash
set -euo pipefail

SESSION="${1:-decision-workbench}"

if [[ "$SESSION" != cao-* ]]; then
  SESSION="cao-$SESSION"
fi

cao shutdown --session "$SESSION" || true

echo "Stopped CAO session: $SESSION"