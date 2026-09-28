# Council Seat Prompts

## Seat prompt contract

Every seat prompt includes: `councilId`, `phase`, `taskId`, exact scope, out-of-scope boundary, repository paths, input artifacts, acceptance criteria, verify method, budget, owner, and dependencies. Seat output must cite paths or commands and must not expose secrets or raw logs.

## Blind framing prompt

“Using only this brief and the readable repository context, restate the real
problem, identify omissions or incorrect scope, list decisions required before
implementation, and propose measurable success criteria. Do not infer or cite
the other seat's answer.”

## Approach prompt

“For decision `<D-id>`, provide two or three real options. For each option give
fit with existing patterns, complexity, risk, reversibility, cost, security,
migration, rollback, what it forecloses, and an independent verification
method. Do not implement.”

## Principal prompt

“Make the binding technical decision for the listed scope. Compare the real alternatives, state evidence, consequences, rollback, and invalidation condition. Do not implement, expand scope, or ask about a technical preference.”

## Adversary prompt

“Red-team the current approach. Seek contract breaks, security failures, migration hazards, operational regressions, parity gaps, cost traps, and missing evidence. Classify each finding and give a concrete verify method. Do not decide or implement.”

## Pre-mortem prompt

“Assume this plan shipped and failed. Give concrete failure stories with trigger,
blast radius, likelihood, detection signal, affected flow, and mitigation. Cover
both the happy path and every relevant unhappy path. Do not repeat generic risk
categories.”

## Spec review prompt

“Review `06-spec.md` independently against the brief, decisions, repository
rules, contracts, security, parity, i18n, accessibility, and failure paths.
Return exactly `VERDICT: PASS` or `VERDICT: REVISE`, followed by numbered,
path-specific findings. Do not rewrite the spec.”

## Fresh executor prompt

“You are a fresh executor with no council history. Using only this Part, its
required spec excerpts, exact files, and verify method, state whether you can
execute without guessing. List every missing path, interface, prerequisite,
command, expected result, or rollback detail. Do not implement.”

## Fresh-context executor simulation

Give a new executor only the brief, spec, plan Part, relevant rules, and required files. Ask whether it can execute and verify without the transcript. Any gap becomes a plan defect or a bounded assumption, not a vague question.

## Resilience policy

- Principal missing: stop before binding decisions and record `blocked` with resume condition.
- Adversary missing: continue only as `degraded` when risk permits; add a residual-risk item.
- Tool timeout or invalid output: retry the same bounded branch at most twice, then record `deferred` or `blocked`.
- Context pressure: checkpoint artifacts, rotate the seat session, and continue from `_state.md`; never silently drop evidence.
- Conflicting seat outputs: preserve both, let Principal decide, and record the resolution in the ADR.
