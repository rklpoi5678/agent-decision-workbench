# Decision Policy

The core rule is:

> Deterministic evidence first. Jev only at semantic branch points.

## Three layers

### 1. Deterministic layer

Use direct evidence:

- files,
- git diff,
- compiler output,
- unit/integration tests,
- linter/typechecker,
- documented project constraints.

No Jev call is needed when this layer can decide the next step.

### 2. Jev decision layer

Use Jev for typed judgments where multiple routes remain reasonable.

Example shared state:

```text
goal
changed files
diff summary
test results
warnings
known constraints
```

execution_strategy: Choice
- direct_implementation
- implementation_then_review
- inspect_more
- human_review

risk: Score
0 = trivial/local
1 = low
2 = meaningful cross-system risk
3 = high/irreversible risk

need_independent_review: Noul

need_more_verification: Noul

A single shared-state evaluation is preferable to several redundant calls.

### 3. Human authority layer

Humans decide:

- destructive or irreversible changes,
- secrets/credentials handling,
- major scope changes,
- product decisions not present in the specification,
- expensive actions beyond configured limits,
- ambiguous requirements where the user's intent is required.

Jev may recommend escalation, but cannot approve these actions.

## Anti-patterns

Do not ask Jev:

- whether a command succeeded,
- whether a test output contains a failure,
- whether a file exists,
- whether code compiles,
- whether the user granted permission,
- every single micro-step.

The goal is fewer high-value decisions, not maximum Jev usage.
