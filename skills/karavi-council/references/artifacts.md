# Karavi Council Artifact Contract

## State

`_state.md` records `schemaVersion`, council id, scope, profile (`quick|standard|critical`), current phase, lifecycle (`running|completed|blocked|failed`), seat availability, changed transitions with UTC timestamps, active blockers, and next action. Do not rewrite unchanged state as new evidence.

## Core files

| File | Required content |
|---|---|
| `00-brief.md` | user goal, problem, in-scope/out-of-scope, success criteria, constraints, profile |
| `01-context.md` | repository/config/history evidence, affected surfaces, relevant skills, sibling patterns |
| `02-assumptions.md` | assumption, evidence, owner, invalidation signal, consequence |
| `03-approaches.md` | real alternatives, trade-offs, cost, security, migration, rollback, verification |
| `04-risks.md` | risk, severity, likelihood, impact, mitigation, trigger, owner, residual risk |
| `05-decisions.md` | ADR id, decision, evidence, alternatives rejected, consequences, invalidation |
| `06-spec.md` | behavior, contracts, data/API/UI boundaries, failure paths, i18n/theme/accessibility, acceptance |
| `07-plan.md` | Parts, dependencies, exact files/interfaces, commands, tests, owners, rollback, micro-steps |
| `08-readiness.md` | requirement matrix, gate results, unresolved findings, degraded seats, verdict, handoff |

## Part contract

Each Part contains `id`, `status`, `prerequisites`, `dependsOn`, `owner`, `scope`, `files`, `action`, `expectedResult`, `verifyMethod`, `rollback`, and `completionCriteria`. A Part is not ready if it has an unresolved placeholder, unknown dependency, or missing verification.

## Readiness checklist

- Scope is complete and no new scope is hidden in a Part.
- Every requirement and acceptance criterion maps to evidence and a Part.
- Principal decisions are present for consequential architecture choices.
- Adversarial findings are resolved, accepted-risk, or explicitly blocked.
- Failure scenarios, security, compatibility, parity, cost, and rollback are covered.
- The plan is executable by a fresh agent without relying on the council transcript.
- Readiness is `ready` only when all required gates pass; otherwise record `blocked` or `degraded`.
