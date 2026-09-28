# Judge Evidence Contract

## Input envelope

```text
scope | outOfScope | profile | acceptanceCriteria | agentMainResult
changedFiles | diffEvidence | tests | verification | securityEvidence
parityEvidence | contractEvidence | sevenExpertOutput | customerOutput
openFindings | priorVerdict | cycleNumber
```

Fields are required when relevant to the scope. An omitted required field is a
finding. A field is not evidence until it has a source, timestamp or changed
status, and an observable result.

## Finding schema

```text
id | severity | message | path | line | confidence | impact | evidence
owner | verifyMethod | resumeCondition
```

Severity is `info|low|medium|high|critical`; confidence and impact are `H|M|L`.
`resumeCondition` is mandatory for a blocking finding. Findings must be
deduplicated by root cause; keep separate evidence only when status changed.

## Evidence quality

- Fresh: produced for the current scope or explicitly unchanged and still valid.
- Specific: points to a path, command, test, response, or artifact.
- Reproducible: another reviewer can repeat the verification.
- Sufficient: covers the acceptance claim and its relevant failure path.
- Safe: contains no secret, credential, PII, or raw sensitive log.

Do not substitute a plan for execution evidence, a command name for a result,
or a green health check for functional acceptance.
