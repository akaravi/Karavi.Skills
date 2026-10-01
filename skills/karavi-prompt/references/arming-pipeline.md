# Arming Pipeline

Stage contracts, the spec schema, the run envelope, and the state machine.
The SKILL.md owns the rules; this file owns the shapes.

---

## State machine

```text
        ┌──────────┐
        │   RAW    │  user text, no structure
        └────┬─────┘
             │ INTAKE
             ▼
        ┌──────────┐
        │  INTAKE  │  intent contract complete?
        └────┬─────┘   no ──▶ ask only a blocking, material, user-owned question
             │ yes     yes ──▶ state stays INTAKE, no panel, no dispatch
             │ ENGINEER
             ▼
        ┌──────────┐
        │ ARMED    │  structured + grounded + bounded prompt
        └────┬─────┘
             │ GUARD
             ▼
   ┌─────────┴─────────┐
   │  GUARD: block     │──▶ report findings, redact, STOP (exit 1)
   └─────────┬─────────┘
             │ pass | warn
             │ PANEL
             ▼
        ┌──────────┐
        │  PANEL   │  rendered once, user has now seen it
        └────┬─────┘
             │ DISPATCH (verbatim, single target)
             ▼
        ┌──────────┐
        │ DISPATCH │  target agent executes
        └────┬─────┘
             │ LEDGER close
             ▼
        ┌──────────┐
        │  CLOSED  │  outcome + rubric score → eval set seed
        └──────────┘
```

Transitions are forward-only. A `block` is terminal for that run id; re-arming
allocates a new run id. Editing the panel after `DISPATCH` is a new run, never
a patch.

---

## Stage contracts

### INTAKE

Input: whatever the user typed. Output: a complete intent contract.

Required before leaving INTAKE:

- `goal` — one sentence, observable deliverable.
- `scope` and `outOfScope` — at least one entry each. An empty `outOfScope`
  means the boundary was not thought about.
- `constraints` — hard boundaries the agent may not cross.
- `acceptance` — checkable statements, not adjectives.
- `verifyMethod` — the command, test, or observation that proves acceptance.
- `target.mode` — `read-only`, `mutating`, `network`, or `secret`.
- `untrusted` — every source the agent will read that is not authored by the
  user in this conversation.

**Ask only when** all three hold: the decision is blocking, it cannot be
inferred from the repo or the request, and it is genuinely user-owned. Every
other gap is an assumption you state in one line and proceed past.

### ENGINEER

Input: the intent contract plus the raw text. Output: the armed prompt and the
list of techniques applied.

The armed prompt must be dispatchable as-is. No unfilled placeholder, no
"adjust as needed", no unstated default that changes the deliverable.

Two shapes only:

- **Case A — content was given.** The real content is baked in. The whole
  prompt, content included, is what gets dispatched.
- **Case B — a class of task was described.** The prompt is self-contained and
  opens by asking the user for the specific inputs it needs, then states the
  full procedure for when it gets them.

### GUARD

Input: the armed prompt plus the spec metadata. Output: a verdict and findings.

Fail-closed. Any `block` finding ends the run. The finding set is defined in
the SKILL.md guard table; the detection order is:

1. Read the spec, normalize paths, refuse to proceed without `rawPrompt` and
   `armedPrompt` unless the caller is re-guarding a stored run.
2. `SECRET` — scan the armed text for credential shapes. Redact every match to
   `[REDACTED]` **in the returned copy**; never write the raw form to disk.
3. `MODE` — `target.mode` is `secret`, or the body asks for credential access.
4. `INJECTION` — scan untrusted spans for override phrasings and control
   tokens.
5. `TAINT` — untrusted content that is not inside a labeled tag, or a labeled
   tag that is not declared data-only.
6. `CONTRACT` — acceptance, output shape, termination.
7. `PLACEHOLDER` — unfilled placeholders in a dispatch-bound prompt.
8. `ARM_DELTA` — armed text identical to raw text.
9. `BUDGET` — token estimate against the class budget.
10. `PORTABILITY` — provider-specific mechanism without a fallback.

Trivial text (`< 10` characters) cannot satisfy `CONTRACT` or `ARM_DELTA`.
It is refused at stage INTAKE, not repaired by the guard.

### PANEL

Input: the armed prompt and the verdict. Output: one rendered box.

The panel renders **only** on `pass` or `warn`. A `block` produces findings and
no panel, so there is nothing on screen that looks dispatchable.

### DISPATCH

Input: the armed prompt. Output: the agent's instruction.

Verbatim, one target, no wrapper. The panel is a record, not an envelope.

### LEDGER

Input: the run envelope. Output: one `jsonl` line and, on close, an outcome.
The ledger is what makes the next run's eval set possible.

---

## Spec schema

The file passed to `karavi-prompt.arm.ps1 -Spec`.

```json
{
  "rawPrompt": "the user's unengineered text",
  "armedPrompt": "the engineered prompt that will be dispatched",
  "techniques": ["xml-structuring", "quote-then-answer", "scoped-constraint"],
  "language": "fa",
  "notes": "one line: why the arming changed anything",
  "intent": {
    "goal": "one sentence, observable",
    "scope": ["in-scope item"],
    "outOfScope": ["not requested"],
    "constraints": ["hard boundary"],
    "acceptance": ["checkable statement of done"],
    "verifyMethod": "command, test, or observation",
    "untrusted": ["path, URL, or chunk the agent may read"]
  },
  "target": {
    "host": "omp",
    "agent": "task",
    "model": "frontier",
    "mode": "read-only"
  }
}
```

Validation: `rawPrompt`, `armedPrompt`, `intent.goal`, and `target` are
required. Missing or malformed JSON is exit code `3`. `techniques` is free
text; it is copied into the panel so the user can see which engineering fired.

`target.model` accepts `frontier`, `mid-tier`, `small`, or `reasoning`. The
class selects the token budget and the CoT rule. Unknown values are treated as
`frontier` and reported as a `warn` finding.

---

## Run envelope

Written to `karavi.temp.status/karavi-prompt/runs/<runId>.json`.

```json
{
  "id": "kp-20261001T081455Z-4f9ac2",
  "createdUtc": "2026-10-01T08:14:55Z",
  "stage": "armed",
  "language": "fa",
  "techniques": ["xml-structuring"],
  "intent": { "...": "verbatim from spec" },
  "target": { "host": "omp", "agent": "task", "model": "frontier", "mode": "read-only" },
  "rawTokens": 118,
  "armedTokens": 402,
  "deltaPercent": 241,
  "rawDigest": "sha256:…",
  "digest": "sha256:…",
  "guard": {
    "verdict": "warn",
    "counts": { "secret": 0, "injection": 0, "taint": 1, "contract": 0,
                "placeholder": 0, "armDelta": 0, "budget": 0,
                "portability": 0, "mode": 0 },
    "findings": [
      { "id": "TAINT", "severity": "warn", "message": "…", "evidence": "…" }
    ]
  },
  "artifacts": {
    "envelope": "<abs path>",
    "raw": "<abs path>",
    "prompt": "<abs path>",
    "panel": "<abs path>"
  },
  "dispatch": "the exact armed text",
  "closed": false
}
```

The envelope never contains a secret. `dispatch` is the redacted armed text,
byte-identical to what the guard cleared.

`runId` is `kp-<UTC compact>-<6 hex>` where the hex is the first 6 characters
of the armed digest. Deterministic, sortable, and correlatable with the ledger.

---

## Ledger

`karavi.temp.status/karavi-prompt/karavi-prompt.jsonl`, one JSON object per
line, append-only:

```json
{"ts":"2026-10-01T08:14:55Z","id":"kp-...-4f9ac2","event":"armed","verdict":"warn","digest":"sha256:...","target":"omp/task","mode":"read-only","rawTokens":118,"armedTokens":402}
{"ts":"2026-10-01T08:19:02Z","id":"kp-...-4f9ac2","event":"closed","outcome":"accept","score":4.2,"note":"rubric 8-dimension, karavi-judge verdict"}
```

`event` is `armed`, `dispatched`, or `closed`. `outcome` on close is `accept`,
`partial`, `fail`, or `needs-review`, matching the vocabulary `karavi-judge`
already uses so the two skills read the same ledger.

A `fail` or `needs-review` close contributes its raw prompt to the eval set.
That is the loop that makes the next arming better than this one.

---

## Run lifecycle and cleanup

Everything this skill writes lives in one directory it owns:

```text
karavi.temp.status/karavi-prompt/
|-- karavi-prompt.jsonl          append-only ledger
`-- runs/
    |-- <runId>.json             envelope (guard verdict, digest, dispatch)
    |-- <runId>.armed.txt        the exact dispatched text
    |-- <runId>.raw.txt          the unengineered input
    `-- <runId>.panel.txt        the rendered panel
```

`karavi-folder clean` filters `karavi.temp.status/` non-recursively, so it does
not reach `runs/`. Purge with this skill's own command, which is scoped to that
one directory; `-WhatIf` lists what would go without removing it:

```powershell
& .agents/skills/karavi-prompt/scripts/karavi-prompt.ledger.ps1 -Purge -OlderThanDays 14 -WhatIf
```

Runs younger than the cutoff are never touched. The ledger is not purged by
this command; it is the eval-set seed and belongs to the user.

---

## Re-arming

Re-arm when any of these changes: the target, the mode, the scope, the
acceptance, or any user edit to the panel text. Never patch a stored prompt.

To re-run the guard on a stored run without re-engineering:

```powershell
& .agents/skills/karavi-prompt/scripts/karavi-prompt.guard.ps1 -Run <run-envelope.json>
```
