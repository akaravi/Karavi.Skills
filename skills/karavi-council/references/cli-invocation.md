# Safe Seat Invocation

This reference is for hosts that can run local CLIs. If a host lacks a CLI,
apply the resilience rules and disclose the degraded seat; do not impersonate
the missing seat.

## Invariants

1. Put long prompts in `_work/<turn>.prompt.md` and pipe through stdin. Do not
   pass multiline prompts, secrets, or non-ASCII prose through shell argv.
2. Use one persistent session per Principal and Adversary turn. Record the
   session ID in `_state.md` immediately.
3. Principal and Adversary are read-only. The Chair alone writes artifacts.
4. Phase 1 runs both seats in parallel and blind. All later turns are
   sequential. Phase 6 executor simulations are fresh throwaway sessions.
5. Store raw transport output in `_work/`, copy only the redacted prompt/reply
   to `_transcript/`, and never store secrets or sensitive raw logs.

## Principal pattern

For a Claude-compatible CLI, use the equivalent of:

```powershell
Get-Content $promptFile -Raw |
  claude -p --session-id $principalSid --model opus `
    --output-format json `
    --disallowed-tools "Write,Edit,NotebookEdit" `
    --add-dir $repo |
  Set-Content $jsonFile -Encoding utf8
```

Subsequent turns resume the same ID with `-r $principalSid`. Read `result`,
`is_error`, `stop_reason`, `usage`, and cost fields when provided. A non-zero
exit or incomplete stop reason is a failed turn, not a decision.

## Adversary pattern

For a Codex-compatible CLI, use the equivalent of:

```powershell
codex exec - -s read-only -C $repo --skip-git-repo-check `
  --json -o $outFile < $promptFile
```

Resume with `codex exec resume <thread-id> - -c sandbox_mode="read-only"`.
Do not add `-s` to `resume`; reassert read-only through configuration. Capture
the thread ID from the structured stream and read the final answer from the
output file, not progress text.

## Fresh executor simulation

Use a new read-only session for each audited Part. Give it only the Part,
required spec excerpts, exact files, and verification contract. Do not resume,
fork, add a council preamble, or provide the prior transcript. Any reported
guess becomes a plan defect.

## Transport gate

Every turn records command, exit status, structured status, session/thread ID,
output path, token/cost values only when actually returned, and the next
action. Never treat a prose reply without successful transport evidence as a
valid seat result.
