# Judge Resilience

## Lifecycle

Track `running|completed|blocked|failed` independently from
`accept|block|fail`. A timeout, unavailable browser, missing test environment,
or missing optional reviewer is classified with category and evidence; it is
not relabelled as a product defect or a pass.

## Cycle limits

When invoked by `judge-plan-loop`, use `quick=2`, `standard=4`, and
`critical=6` maximum cycles. Each finding allows at most two bounded fix
attempts by the owner. Two cycles without fewer findings or stronger evidence
activate the circuit breaker. Continue only on the failed branch and preserve
all previous evidence.

## Missing inputs

- Missing required acceptance or scope: `decision-required` with the exact
  missing field and the safest way to resolve it; use hard `block` only when
  no safe in-scope continuation exists.
- Missing required verification: `decision-required` with a selected bounded
  verification path, or `block`/`fail` only when safety or authorization makes
  continuation impossible.
- Missing optional seat/tool: `WARNING` with `degraded` status.
- Invalid or fabricated subagent result: reject that branch and record its
  resume condition; do not synthesize a replacement result.

## Interrupted result

Before stopping, write a partial result containing status, task and scope,
cycle, changed files, decisions, gate evidence, findings, seat/tool statuses,
blocker, ordered next steps, owner, and resume condition. Mask secrets and raw
logs. On resume, read it back and compare with the actual repository before
continuing.

## Decision packet

For every technical blocker, return an actionable packet: issue, evidence,
options, trade-offs, recommended option, owner, exact action, verification,
residual risk, and next action. `block` is reserved for hard safety or
authorization stops; a technical blocker becomes `decision-required` and is
resolved by Agent Main without abandoning the project.

## Independence

Judge does not implement or repair. It returns the smallest evidence-backed
finding set to Agent Main, then reevaluates changed scope after the bounded fix.
It never reruns unchanged tests merely to increase confidence.
