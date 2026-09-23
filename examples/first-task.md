# First task

Use this only after the bootstrap and doctor scripts succeed.

```text
Inspect this repository before changing anything.

Goal:
Implement the requested feature with minimal unrelated changes.

Workflow:
1. Build a compact understanding of the relevant code.
2. If the next action is deterministic, do not call Jev.
3. If a consequential branch is genuinely ambiguous, use Composio + Jev.
4. Delegate implementation to claude_developer.
5. Decide whether independent review is warranted; use Jev when that decision is genuinely ambiguous.
6. When review is warranted, ask codex_reviewer for an independent review.
7. If the reviewer finds a concrete defect, send one bounded revision to claude_developer.
8. Finish with changed files, checks run, review verdict, and remaining risks.

Do not perform destructive actions without my approval.
```
