# Agent Decision Workbench

> **Decision-gated orchestration for coding agents.**
>
> Claude implements. Codex reviews when it matters. Jev decides when the route is ambiguous.

Agent Decision Workbench is a small, local-first workflow layer for
**Claude Code**, **Codex CLI**, **CAO**, **Composio**, and **Jev**.

It is not another agent runtime.

Instead, it answers a narrower question:

> **When is another agent actually worth calling?**

Most multi-agent workflows can easily turn every task into:

```text
implement
→ review
→ review again
→ debate
→ handoff
→ more tokens
````

Agent Decision Workbench takes the opposite approach:

```text
use deterministic evidence first
→ call another agent only when it changes the outcome
```

---

## Why this exists

Using Claude Code and Codex together is useful.

But without a workflow, the human often becomes the orchestration layer:

```text
"Claude, implement this."
        ↓
copy result
        ↓
"Codex, review this."
        ↓
copy findings
        ↓
"Claude, fix these."
        ↓
decide whether another review is necessary
```

That coordination is repetitive.

This project moves that control into a small, explicit policy layer.

---

## How it works

```text
                         User
                           │
                           ▼
                  Claude Supervisor
                           │
                           ▼
                  Claude Developer
                           │
                           ▼
              Deterministic Verification
             tests · build · lint · diff
                           │
                           ▼
                   Review Routing
                           │
             ┌─────────────┼─────────────┐
             │             │             │
          obvious        obvious      ambiguous
          low-risk       high-risk       │
             │             │             ▼
             │             │            Jev
             │             │       Choice / Score /
             │             │          Noul
             │             │             │
             ▼             ▼             ▼
          Complete      Codex Review   route decision
                            │
                     ┌──────┴──────┐
                     │             │
                    PASS         REVISE
                     │             │
                     ▼             ▼
                  Complete    Claude revision
                                    │
                                    └──→ Codex Review
```

The important part is what **does not happen**:

* trivial changes do not automatically trigger another model,
* deterministic facts are not delegated to an LLM,
* Jev is not called for every branch,
* a reviewer cannot silently override explicit contract violations,
* revision loops are bounded.

---

## The decision gate

After implementation and deterministic verification, the supervisor chooses
one of three paths.

### A — Review clearly unnecessary

Examples:

```text
README typo
comment-only change
local metadata edit
mechanical formatting
```

Result:

```text
Claude Developer
→ deterministic verification
→ complete
```

No Jev.
No Codex review.

### B — Review clearly required

Examples:

```text
authentication
authorization
payments
data migrations
public API changes
cross-component runtime behavior
high-risk infrastructure changes
```

Result:

```text
Claude Developer
→ deterministic verification
→ Codex Reviewer
```

No Jev is needed because the route is already obvious.

### C — Review necessity is ambiguous

This is where Jev is used.

A single compact state can evaluate:

```text
execution_strategy: Choice

- direct_implementation
- implementation_then_review
- inspect_more
- human_review
```

```text
risk: Score

0 = trivial / local
1 = low
2 = meaningful behavioral or cross-system risk
3 = high / irreversible / permission-sensitive
```

```text
need_independent_review: Noul
need_more_verification: Noul
```

The supervisor uses these signals together rather than inventing a hard
probability threshold.

---

## Evidence first

This project follows one rule above everything else:

> **Deterministic evidence outranks model confidence.**

A model cannot turn:

```text
failing test
```

into:

```text
looks good to me
```

The same applies to:

```text
compiler failures
repository state
git diff
lint results
type errors
explicit acceptance criteria
```

Jev is used for **semantic branch decisions**, not facts that software can
already determine.

See [Decision Policy](docs/decision-policy.md).

---

## Reviewer invariants

Codex acts as an independent quality gate.

Reviewer output is structured:

```yaml
verdict: PASS | REVISE | HUMAN_REVIEW

required_contract_violations: []

findings: []

verification_evidence: []

remaining_risks: []

recommended_next_action: accept | revise | human_review
```

The supervisor then applies its own invariants.

For example:

```text
Reviewer says: PASS

but

required_contract_violations:
  - expected: risk_scale.max = 3
    actual: risk_scale.max = 2
```

The effective result is still:

```text
REVISE
```

The reviewer's label is not treated as unquestionable truth.

---

## Bounded revision loops

A failed review does not create an endless agent conversation.

The default correction flow is:

```text
Codex Reviewer
      │
    REVISE
      │
      ▼
Claude Developer
      │
 smallest corrective change
      │
      ▼
Codex Reviewer
```

At most **2 revision rounds** are allowed for the same implementation contract.

If the issue is still unresolved:

```text
HUMAN_REVIEW
```

---

## Quick start

### Requirements

| Tool        | Purpose                            |
| ----------- | ---------------------------------- |
| Claude Code | Supervisor + implementation worker |
| Codex CLI   | Independent reviewer               |
| CAO         | Agent/session orchestration        |
| Composio    | Tool and authentication layer      |
| Jev         | Typed decision engine              |
| tmux        | CAO terminal sessions              |
| uv          | CAO installation                   |
| curl        | Health checks                      |

Also required:

```text
Python 3.10+
Linux or macOS
```

### Install

```bash
git clone https://github.com/rklpoi5678/agent-decision-workbench.git
cd agent-decision-workbench

chmod +x scripts/*.sh
./scripts/bootstrap.sh
```

If Jev has not been connected yet:

```bash
composio link jev
```

Verify the installation:

```bash
./scripts/doctor.sh
```

Example successful result:

```text
[OK]   tmux
[OK]   curl
[OK]   Codex CLI
[OK]   Claude Code
[OK]   Composio CLI
[OK]   CAO
[OK]   Claude native dev agent (workbench-developer)
[OK]   profile: jev_supervisor
[OK]   profile: claude_developer
[OK]   profile: codex_reviewer

All prerequisites met.
```

---

## Launch

From the repository you want the agents to work on:

```bash
/path/to/agent-decision-workbench/scripts/launch.sh
```

Or choose a session name:

```bash
/path/to/agent-decision-workbench/scripts/launch.sh my-project
```

The current working directory becomes the agent workspace.

Stop the session with:

```bash
/path/to/agent-decision-workbench/scripts/stop.sh my-project
```

---

## First task

A minimal task can simply be:

```text
Inspect this repository and implement the requested feature.

Use the configured workflow.
Use deterministic evidence first.
Use Jev only when a consequential workflow decision is genuinely ambiguous.
Use independent Codex review only when warranted.
```

The supervisor handles the rest.

A longer starter prompt is available in:

```text
examples/first-task.md
```

---

## Profiles

### `jev_supervisor`

Claude Code supervisor.

Responsible for:

```text
task decomposition
delegation
review routing
Jev decisions
revision control
final evidence
```

### `claude_developer`

Thin CAO wrapper around the native Claude Code agent:

```text
workbench-developer
```

Responsible for:

```text
implementation
tests
builds
linting
type checks
change reporting
```

### `codex_reviewer`

Independent Codex quality gate.

Responsible for checking:

```text
requirements
correctness
regressions
edge cases
verification claims
scope expansion
repository conventions
```

---

## What this project is not

Agent Decision Workbench is intentionally **not**:

```text
a new agent runtime
a replacement for CAO
a model router
a swarm framework
a coding-agent UI
an autonomous software factory
```

CAO already handles agent processes and sessions.

Claude and Codex already know how to work with code.

Composio already handles external tool integration.

Jev already provides typed probabilistic decisions.

This repository adds the **workflow policy between them**.

---

## Built on existing tools

| Project     | Role here                                  |
| ----------- | ------------------------------------------ |
| CAO         | Agent and terminal orchestration           |
| Claude Code | Supervisor + implementation                |
| Codex CLI   | Independent review                         |
| Composio    | External tools and authentication          |
| Jev         | Typed decisions at ambiguous branch points |

The goal is integration, not reinvention.

---

## Benchmark the workflow

More agents do not automatically mean better engineering.

This repository includes a simple benchmark plan comparing:

```text
manual Claude / Codex coordination
```

against:

```text
decision-gated orchestration
```

Track:

```text
wall-clock time
human interventions
follow-up prompts
agent handoffs
Jev calls
Codex reviews
revision loops
false "done" claims
verification results
```

The primary question is:

> **Does the workflow reduce human coordination without increasing defects or unreasonable cost?**

See [Productivity Benchmark](docs/productivity-benchmark.md).

---

## Project status

**v0.1 — working experimental release**

include:

```text
Claude native developer handoff
Codex independent review
PASS / REVISE control flow
bounded revision loop
reviewer consistency invariants
conditional Jev routing
direct completion without unnecessary review
```

The project is intentionally small while real-world usage data is collected.

---

## Security

Never send credentials or secrets to Jev or another model as routing context.

The workflow does not treat model output as authorization.

Destructive or irreversible actions still require explicit human approval.

Do not commit:

```text
.env
API keys
provider credentials
private task logs
authentication caches
```

---

## Roadmap

The immediate roadmap is deliberately boring:

```text
use it on real projects
measure whether it helps
remove steps that do not help
improve routing policy from evidence
```

Features such as dashboards, custom runtimes, automatic quota accounting,
or additional agents should only be added when actual usage justifies them.

---

## License

MIT
