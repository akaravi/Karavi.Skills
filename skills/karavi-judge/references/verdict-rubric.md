# Judge Verdict Rubric

## Finding record

Every material finding has `severity`, `message`, `path`, `confidence`, `impact`, `evidence`, `owner`, and `verifyMethod`. A blocking finding also has `resumeCondition`.

## Thresholds

| Condition | Action |
|---|---|
| info/low/medium, in scope | record and continue |
| in-scope improvement | route and continue |
| new scope | report separately; do not execute or block current work |
| high/critical with valid evidence | block until fixed or explicitly authorized resolution |
| acceptance cannot be evaluated without a user-owned choice | block with one precise decision request |
| optional seat/tool unavailable | degraded warning unless it invalidates a required gate |
| unresolved contract/security/data-integrity failure | block or fail according to recoverability |

## Failure scenario

Choose a relevant negative path: invalid input, unauthorized access, dependency timeout, duplicate mutation, stale client contract, migration rollback, inaccessible UI state, or another scope-specific failure. Record setup, expected safety behavior, observed result, evidence, and status. Do not claim a scenario passed without an actual result.

## Disagreement

Preserve the claim, counterclaim, evidence, and decision owner. Agent Main decides technical questions inside scope; Judge checks whether the decision satisfies the rubric. A disagreement becomes a blocker only when it leaves a material acceptance, security, contract, parity, or data-integrity question unresolved.

## Envelope

Use the single `Completion Envelope`: scope completion, cross-section completion, one seven-domain mask/summary, then independent Judge verdict. Carry only changed findings and evidence into later cycles.
