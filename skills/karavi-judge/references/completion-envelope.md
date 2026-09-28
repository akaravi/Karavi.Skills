# Completion Envelope Contract

The Judge writes one envelope per completed scope. Later cycles carry only
changed evidence, findings, and actions.

```text
CompletionEnvelope {
  check1: { scopeComplete: yes|no, status, newEvidence, action },
  check2: { crossSectionComplete: yes|no, status, newEvidence, action },
  check3: {
    sevenExpertSummary: {
      relevanceMask: [seven domains, relevant|not-relevant, reason],
      relevantFindings, qualitySecurityStatus, openFindings, nextStepValue
    }
  },
  judgeVerdict: {
    verdict: accept|block|fail,
    reason, newEvidence, openFindings, owner, resumeCondition, nextAction
  }
}
```

## Status rules

Use only `PASS`, `WARNING`, `ACTION REQUIRED`, or `BLOCKED/FAILED` for envelope
sections. A warning records a non-blocking concern. `ACTION REQUIRED` means an
in-scope action remains. `BLOCKED/FAILED` requires evidence and a resume or
re-attempt condition.

`accept` requires Check 1 and Check 2 to report no remaining in-scope work,
Check 3 to contain all seven domains, all required gates to pass, and no open
blocking finding. After accept, next steps are out of scope and do not grant
implicit permission for implementation, Git, production, Deploy, or destructive
operations.
