# Agent Decision Workbench

An opinionated local-first starter for coordinating **Claude Code**, **Codex CLI**, **AWS CLI Agent Orchestrator (CAO)**, **Composio**, and **Jev**.

The project does **not** try to replace CAO or build yet another coding-agent router. Instead, it supplies a reusable control pattern:

- Claude Code acts as the supervisor.
- Claude Code acts as the default implementation worker.
- Codex acts as the independent quality reviewer.
- Jev is used only when a decision is genuinely ambiguous and can change the next action.
- Composio provides the tool/authentication layer used to reach Jev.
- CAO owns process/session orchestration and cross-provider delegation.

## Why this exists

Using Codex and Claude Code together is already useful, but humans often become the hidden orchestrator:

1. decide which agent should work,
2. copy context between terminals,
3. ask another model to review,
4. send fixes back,
5. decide when enough verification has happened.

This repository turns that workflow into a repeatable supervisor/developer/reviewer setup without reimplementing the underlying CLIs.

## Architecture

```text
                        User
                          |
                          v
                 Claude Supervisor
                   (CAO conductor)
                          |
             +------------+-------------+
             |                          |
      ambiguous decision?          deterministic?
             |                          |
             v                          |
          Composio                      |
             |                          |
             v                          |
            Jev                         |
             |                          |
             +------------+-------------+
                          |
                 routing / next action
                          |
             +------------+-------------+
             |                          |
             v                          v
      Claude Developer            Codex Reviewer
        (write/test)                (quality gate)
             |                          |
             +------------+-------------+
                          |
                    Supervisor
                          |
              accept / revise / human
```

## Current scope: v0.1

This first version is intentionally small.

It provides:

- reusable CAO profiles,
- an idempotent-ish bootstrap script,
- a launcher for the supervisor session,
- a doctor script,
- a Jev decision policy,
- a simple productivity benchmark plan.

It does **not** yet provide:

- a custom orchestration runtime,
- a dashboard,
- automatic token/quota accounting,
- a custom Jev SDK,
- automatic GitHub PR creation,
- autonomous destructive actions.

Those are possible later only if real use shows they are needed.

## Prerequisites

Linux/macOS is the current target.

You should already have:

- `git`
- `tmux`
- Python 3.10+
- `uv`
- Claude Code (`claude`) authenticated
- Codex CLI (`codex`) authenticated
- Composio CLI (`composio`) authenticated

The bootstrap script installs CAO from PyPI when `cao` is missing.

## Quick start

```bash
git clone <YOUR_REPO_URL>
cd agent-decision-workbench

chmod +x scripts/*.sh
./scripts/bootstrap.sh
```

If Jev has not been connected to Composio yet:

```bash
composio link jev
```

Check the environment:

```bash
./scripts/doctor.sh
```

Launch the supervisor:

```bash
./scripts/launch.sh
```

Or name the session:

```bash
./scripts/launch.sh my-project
```

Then give the supervisor a real repository task, for example:

```text
Inspect this repository and implement the requested feature.

Use the configured workflow:
- delegate implementation to claude_developer,
- request codex_reviewer only when independent review is warranted,
- revise if the review finds a concrete problem,
```

## Profiles

### `jev_supervisor`

Claude Code supervisor. It coordinates workers and may call Jev through Composio when a structured decision would materially affect execution.

### `claude_developer`

Claude Code implementation worker. It owns code changes and deterministic verification.

### `codex_reviewer`

Independent Codex quality reviewer. It checks requirements, changed code, verification evidence, and regressions.

## Jev usage rule

Jev is not a substitute for tests, compiler output, repository facts, or user approval.

Use Jev when:

- several reasonable routes exist,
- the route materially changes cost/risk/work,
- the state can be summarized compactly,
- a typed decision is more useful than another long-form answer.

Do not use Jev for:

- obvious next steps,
- facts that can be checked directly,
- routine shell/file operations,
- destructive actions requiring human approval.

See [`docs/decision-policy.md`](docs/decision-policy.md).

## Existing projects we intentionally build on

This project is glue, policy, and reproducible setup—not a reinvention of the ecosystem.

- AWS Labs CLI Agent Orchestrator (CAO): process/session orchestration
- Composio: external tool/authentication layer
- Jev / TypeSafe: typed probabilistic decisions
- Codex CLI: implementation worker
- Claude Code: supervisor/reviewer

There are also existing agent-router and multi-agent projects. This repository should only grow where the integration or opinionated workflow adds a concrete missing capability.

## Security

- Never commit API keys, `.env`, provider credentials, auth caches, or private task logs.
- Task state sent to Jev may leave your machine through the configured provider. Do not send secrets.
- Jev results are advisory decisions, not permission grants.
- Destructive or irreversible operations require explicit human approval.
- Review generated shell commands before running this project in sensitive environments.

## Productivity experiment

Do not assume orchestration improves productivity.

Compare the old workflow and this workflow using real tasks. Track:

- total wall-clock time,
- number of human interventions,
- number of follow-up prompts,
- rework loops,
- tests/checks passed,
- model/agent usage where available.

See [`docs/productivity-benchmark.md`](docs/productivity-benchmark.md).

## License

MIT.
