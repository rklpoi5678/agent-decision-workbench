# Productivity Benchmark

The purpose of this project is not to make the terminal look more agentic. It should reduce real coordination work.

Run a small A/B test.

## A: current workflow

Complete 3-5 normal tasks using your usual Codex / Claude Code workflow.

## B: workbench workflow

Complete 3-5 tasks of similar size using:

```text
Claude Supervisor
  -> Claude Developer
  -> deterministic verification
  -> Codex Reviewer only when warranted
  -> revision only when justified
```

Use Jev only when the next workflow route is consequential and genuinely ambiguous.

## Record

For every task:

| Metric | Meaning |
|---|---|
| wall_clock_minutes | Start to accepted result |
| human_interventions | Times the human had to redirect or transfer context |
| followup_prompts | Extra prompts after the initial task |
| agent_handoffs | Cross-agent delegations |
| revision_loops | Developer-reviewer correction loops |
| jev_calls | Number of ambiguous routing decisions delegated to Jev |
| codex_reviews | Number of independent Codex review passes |
| checks_passed | Relevant verification completed |
| false_done_claims | Agent claimed completion before evidence supported it |
| notes | Failures, friction, useful behaviors |

## Primary metric

Prioritize **human interventions per completed task** over raw elapsed time.

The system is useful when the user spends less attention coordinating agents without increasing defects or cost beyond an acceptable level.

## Keep / change / delete

After the first 5-10 tasks:

- Keep features that reduced intervention.
- Change features that caused repeated friction.
- Delete orchestration steps that add ceremony but do not change outcomes.
