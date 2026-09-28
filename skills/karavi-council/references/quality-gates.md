# Readiness Quality Gates

`08-readiness.md` records each gate as `PASS`, `WARNING`, `ACTION REQUIRED`, or
`BLOCKED/FAILED`, with changed evidence and next action. A warning is not a
silent pass and a degraded review is disclosed.

## Scope and requirements

- [ ] Problem, goals, non-goals, acceptance, constraints, and boundaries are explicit.
- [ ] Every requirement maps to a specification section and an implementation Part.
- [ ] New scope is separately routed and not hidden in an existing Part.
- [ ] All affected domain, API, DB, UI, consumer, i18n, theme, accessibility,
      observability, security, test, and deployment surfaces are classified.

## Decisions and risks

- [ ] Every consequential decision has two or more real approaches.
- [ ] Principal has signed or explicitly deferred every open decision.
- [ ] Adversary attack, rebuttal, dissent, and pre-mortem are recorded.
- [ ] Every assumption has evidence, owner, confidence, blast radius, and
      invalidation signal.
- [ ] Major flows include success and every relevant failure path.
- [ ] Security, compatibility, parity, cost, migration, rollback, and resilience
      risks have owners and verification methods.

## Plan executability

- [ ] Every Part has exact paths/interfaces, prerequisites, dependencies, owner,
      action, expected result, micro-steps, tests, rollback, and completion criteria.
- [ ] Dependencies are acyclic and no Part has an unknown prerequisite.
- [ ] No placeholder, vague action, invented path, or guessed interface remains.
- [ ] Fresh-context executor simulations pass for the riskiest and dependent Parts.
- [ ] Principal has audited coverage from specification requirements to Parts.

## Process integrity

- [ ] Every prompt and reply is in a stable transcript filename.
- [ ] Phase 1 seats were blind and used the same brief.
- [ ] `_state.md` matches phase, lifecycle, seat roster, session IDs, pending turn,
      blockers, and next action.
- [ ] Substitutions, rotations, unavailable seats, and degraded gates are named.
- [ ] Chair wrote artifacts; read-only seats did not modify the repository.
- [ ] No unchanged evidence was repeated as new evidence.
- [ ] No secret, credential, PII, or raw sensitive log is in artifacts.

## Final handoff

The report states what is being built, material decisions and reasons, risky
assumptions and invalidation signals, dissent, top risks and detection signals,
actual seat roster, any failed/degraded gate, plan path, and the next authorized
phase. The council stops here.
