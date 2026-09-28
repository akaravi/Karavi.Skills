# Council Resilience and Quorum

Artifacts are state; sessions are a cache. After every turn update `_state.md`
and keep the run resumable by another harness.

## Failure classes

| Failure | Action |
|---|---|
| Missing or unauthenticated CLI | continue independent phases; mark the seat degraded and queue phases that require it |
| Principal unavailable | finish Phases 0-3, record decisions and evidence, make a clearly-labelled provisional Agent Main decision for safe non-destructive work, and queue later Principal review; never promote Adversary |
| Adversary unavailable | continue only when risk allows; mark degraded and record residual risk |
| Timeout or transient transport error | retry the same bounded turn at most twice |
| Invalid or incomplete result | do not interpret it as a verdict; retry once with a narrower prompt, then classify |
| Rate limit or expired session | rotate at the next safe boundary and re-brief from artifacts |
| Context pressure near 60% | checkpoint, rotate the seat, and disclose the replacement |
| Contradictory seat results | preserve both, send the bounded conflict to Principal, record dissent |
| Crash or interruption | write a partial resumable state with blocker, evidence, next action, and resume condition |

## Quorum rules

- The Chair can write and synthesize, but cannot silently fill Principal's
  binding decision.
- Adversary can challenge but can never be promoted to Principal.
- A degraded review cannot be labelled a normal `PASS`.
- A missing optional seat is a warning unless its absence invalidates a required
  gate. A missing required gate becomes `decision-required` with a selected safe
  fallback whenever execution can continue safely; only an unsafe or
  unauthorized operation remains a hard blocker.
- Two failed retries activate classification, not an unlimited retry loop.

## Rotation

At a phase boundary, create a new session, record old/new occupants and IDs,
and send the new occupant the relevant artifacts plus the open turn. Rotation
does not reopen a closed gate and does not claim the new session remembers the
old one.

## Pause and resume

If a technical issue appears, write a decision record with evidence, selected
fallback, owner, verification, and residual risk, then continue. Use lifecycle
`blocked` only for a hard safety or authorization stop; include safe interim
work and an exact resume condition. On resume, read `_state.md`, compare it
with the repository and transcript, and continue only unresolved work. Never
restart completed phases or overwrite artifacts blindly.
