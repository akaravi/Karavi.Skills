---
name: karavi-council
description: Use when a project or major subsystem needs structured multi-agent planning, autonomous technical decisions, red-team analysis, failure-mode review, ADRs, a written specification, and an implementation-ready plan before coding.
---

# Karavi Council

## Mission and hard gate

Karavi Council is a planning-only workflow. It turns a project or major
subsystem request into an auditable brief, assumptions, alternatives, risks,
binding decisions, specification, implementation plan, and readiness report.
Its terminal state is a written handoff at the readiness gate. It does not
implement code, scaffold production files, install dependencies, commit, push,
merge, Deploy, FTP, or silently expand scope. A later implementation request
starts a separate execution workflow.

Use it for architecture, API or DB changes, migrations, multi-consumer work,
security-sensitive changes, major UI flows, or any request whose implementation
path is not already clear. Do not use it for a small reversible change with a
known scope and verification path.

## Seats and authority

| Seat | Responsibility | Authority |
|---|---|---|
| Chair / Agent Main | runs the loop, reads context, writes every artifact, synthesises, enforces gates | owns scope and execution of the council; no vote on contested technical decisions |
| Principal | compares consequential options and signs binding ADR decisions | final technical authority for contested decisions |
| Adversary | independently frames the problem, attacks approaches, finds failure modes and gaps | advisory only; never decides or implements |
| Customer | optional acceptance-oriented advisory review | may request a Judge block only for evidence-backed high/critical acceptance defects or an unevaluable required decision |

The chair remains distinct from every subprocess seat even when the host is
the same product. Principal and Adversary are read-only. Only the Chair writes
the repository. If the default seat is unavailable, disclose the substitute,
record `degraded`, and never fabricate a seat result.

## Autonomy rule

The council resolves technical questions itself. Escalate to the user only if
all four conditions hold:

1. The issue blocks an artifact or acceptance decision.
2. It cannot be derived from repository evidence, rules, official docs, tests,
   or bounded inference, and Principal plus Adversary cannot infer it.
3. A wrong answer would cause material rework, risk, or cost.
4. The decision is genuinely user-owned: budget, legal policy, access,
   business rule, or personal preference. A technical judgment is not user-owned.

Anything failing one of these tests becomes an assumption with an ID,
confidence, blast radius, owner, evidence, and invalidation observation. Batch
surviving user questions once at the Phase 4 gate; do not ask them mid-round.

Routine advisory disagreement, info/low/medium findings, in-scope improvements,
missing optional tooling, and new-scope requests are recorded and routed; they
do not block by themselves. A demonstrated high/critical defect, missing
required prerequisite/evidence, or unresolved acceptance/security/contract/data
integrity issue opens an important decision record: Agent Main selects the best
safe remediation, fallback, rollback, or scope-preserving option and continues.
Do not leave the project idle merely because a finding is called a blocker.

## Block-to-decision policy

`block` is a decision signal, not an automatic stop. When a technical blocker
appears, immediately create a decision with the issue, evidence, options,
trade-offs, selected option, owner, action, verification, and residual risk.
Agent Main must choose the best evidence-backed option inside scope and proceed
with the smallest safe change. Use `decision-required` or `ACTION REQUIRED` for
the active state while the decision is being resolved.

Only a hard safety or authorization stop may pause execution: an exposed secret
requiring containment, destructive or production action without authorization,
an unavailable required credential/access, a legal/business decision owned by
the user, or an operation that cannot be made safe with a bounded fallback.
Even then, record the decision, safe interim work, owner, and exact resume
condition; never emit a bare `blocked` message.

## Setup

1. Identify the host harness and record it in `_state.md` and the final report.
2. Read target-repository `AGENTS.md`, `CLAUDE.md`, README, manifest, relevant
   history, rules, sibling files, and required skills. Repository rules outrank
   this skill.
3. Read [host-adapters.md](references/host-adapters.md),
   [resilience.md](references/resilience.md), and
   [cli-invocation.md](references/cli-invocation.md) before seat calls.
4. Create `docs/planning/<YYYY-MM-DD>-<english-kebab-slug>/` with
   `_transcript/` and `_work/`. Confirm `_work/` is gitignored; never place
   secrets or raw sensitive logs in either artifact area.
5. Verify available seat CLIs. Missing or unauthenticated tooling does not
   erase the run: apply quorum rules, continue independent phases, and record
   the exact degraded boundary.
6. Open one persistent session per seat and record session IDs immediately.
   Phase 1 is blind and parallel; Phase 6 executor simulations are fresh and
   throwaway; all other seat turns are sequential and resumable.

## Artifact and audit invariants

The artifact directory is the source of truth; sessions are only a cache.
Every prompt and reply is copied to `_transcript/NN-<phase>-<seat>-<occupant>.md`.
Write `_state.md` after every turn with current phase, lifecycle, seat roster,
session IDs, pending turn, ledger, changed transitions, blockers, and next
action. A resumed or rotated session is re-briefed from artifacts and never
claims continuity it cannot prove.

Use the complete contract in [artifacts.md](references/artifacts.md). The
canonical files are `_state.md`, `00-brief.md`, `01-context.md`,
`02-assumptions.md`, `03-approaches.md`, `04-risks.md`, `05-decisions.md`,
`06-spec.md`, `07-plan.md`, and `08-readiness.md`.

## Eight-phase loop

Run every phase. Scale the amount of prose for `quick|standard|critical`, but
never remove a gate.

### Phase 0 - Context sweep

The Chair reads the repository and writes the brief, context, and assumption
ledger. Include problem, goals, non-goals, success criteria, constraints,
affected surfaces, existing patterns, relevant skills, recent history, and
known risks. No `TBD` is allowed in these files.

**Exit:** all three files exist and the scope boundary is explicit.

### Phase 1 - Blind framing

Send the exact same brief to Principal and Adversary in parallel without
showing either answer to the other. Ask each to restate the real problem,
identify omissions, list decisions required before implementation, and flag
scope errors. Merge both answers into `01-context.md`; record divergence and
open decisions as `D-01`, `D-02`, ... with owner and blocking effect.

**Exit:** every decision named by either seat has a register ID.

### Phase 2 - Approaches

For every consequential open decision, obtain two or three real options from
both seats. Build a comparison keyed by the decision ID covering complexity,
risk, reversibility, cost, fit with existing code, security, migration,
rollback, and what each option forecloses. Apply YAGNI and remove features
that serve no stated goal.

**Exit:** every consequential decision has at least two credible options.

### Phase 3 - Red team and pre-mortem

Give the leading approaches to Adversary and request attacks: silent
assumptions, contract breaks, security failures, migration hazards, operational
regressions, parity gaps, cost traps, and 10x behavior. Give the attack to
Principal for rebuttal or a changed recommendation. Allow at most two
exchanges per topic. Both seats also assume the project shipped and failed;
write concrete failure stories, triggers, blast radius, detection signals,
likelihood, and mitigations. Every major flow must include success and failure
paths.

**Exit:** no selected approach has an unanswered material attack.

### Phase 4 - Binding decisions

Principal decides every open decision. Write one ADR per decision with context,
options, verbatim verdict, reasoning, consequences, reversal condition,
accepted failure modes, and Adversary dissent. Close each register item with
its ADR. Principal decisions bind Phases 5-7; later concerns must reopen the
ADR explicitly, never contradict it silently.

This is the preferred phase for Principal. If Principal is unavailable, do not
promote Adversary or pretend to have its verdict. Agent Main records a
`provisional-decision` with evidence, selected safe option, residual risk, and
later review owner, then continues all non-destructive work. Only a genuinely
user-owned or unsafe decision becomes a hard safety stop. Ask the user only the
questions that survived all four autonomy tests, in one batch.

**Exit:** every decision is decided or deferred with a trigger that reopens it.

### Phase 5 - Specification

Chair writes `06-spec.md` from the decisions. Cover behavior, contracts,
interfaces, data/API/UI boundaries, error and failure paths, security,
compatibility, parity, i18n, theme, accessibility, observability, acceptance,
and verification. Principal and Adversary review independently and return
`VERDICT: PASS` or `VERDICT: REVISE` with numbered findings. Fix and resend;
allow at most three iterations, then Principal arbitrates and records residual
findings.

**Exit:** both reviewers pass or Principal arbitration is recorded, with no
placeholder.

### Phase 6 - Implementation plan

Chair writes `07-plan.md` with independently verifiable Parts. Every Part has
exact paths and interfaces, owner, prerequisites, dependencies, action,
expected result, micro-steps, TDD/test commands, failure handling, rollback,
and completion criteria. No vague instruction such as "handle errors" is
allowed.

Run a zero-context executor simulation for the riskiest three or four Parts and
every Part with dependants. Each simulation uses a fresh throwaway session
with only that Part and its required inputs. Any guess is a plan defect. Then
Principal audits that every requirement in `06-spec.md` points to a Part.

**Exit:** zero unresolved guesses, zero uncovered requirements, acyclic
dependencies, and consistent names/types/interfaces.

### Phase 7 - Readiness gate

Write `08-readiness.md` using [quality-gates.md](references/quality-gates.md).
Check scope, requirements, evidence, decisions, risks, failure paths,
security, compatibility, parity, rollback, transcript integrity, seat
substitutions, and plan executability. Stop at this gate. The final report
states decisions, assumptions and invalidation signals, dissent, top risks,
seat roster, degraded areas, gate failures, plan location, and the next
authorized phase.

## Turn, retry, and resilience rules

- Prompts go through files/stdin, never long shell argv strings.
- Check exit code and structured response fields, not prose alone.
- Retry the same bounded branch at most twice; then classify as
  `decision-required` or `deferred` with evidence, selected fallback, and
  resume condition. Reserve `blocked` for a hard safety or authorization stop.
- Rotate a seat near context pressure or after loss at the next phase boundary;
  re-brief from artifacts and record the rotation.
- Never let a failed Principal call be answered by Chair or Adversary.
- Never mark a degraded run as a normal PASS; disclose the missing reviewer.
- Never reopen a closed gate because a session rotated.

## Red flags

| Rationalization | Required response |
|---|---|
| "The brief is vague" | Treat vagueness as Phase 1 input and frame it. |
| "They agree, skip red-team" | Run the pre-mortem; agreement is not evidence. |
| "I can decide as Chair" | Send the contested decision to Principal. |
| "Promote Adversary because Principal is unavailable" | Stop at Phase 4 and record the blocker. |
| "The plan is obvious" | Run a fresh zero-context executor simulation. |
| "I remember the state" | Read `_state.md`; artifacts outrank memory. |
| "Ask the user quickly" | Apply all four autonomy tests and batch only surviving questions. |
| "One more retry" | Two retries maximum, then classify the failure. |

## References

- [artifacts.md](references/artifacts.md) - artifact templates and Part contract
- [prompts-and-resilience.md](references/prompts-and-resilience.md) - seat prompts and recovery
- [cli-invocation.md](references/cli-invocation.md) - safe read-only CLI/session patterns
- [host-adapters.md](references/host-adapters.md) - Chair capabilities and harness differences
- [quality-gates.md](references/quality-gates.md) - readiness checklist and final report
- [resilience.md](references/resilience.md) - failures, quorum, rotation, pause and resume
