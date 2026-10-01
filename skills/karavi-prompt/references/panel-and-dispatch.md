# Panel and Dispatch

The panel is the human-visible half of the contract: what is about to run, at
whom, under which guard, in which mode. The dispatch is the machine half: the
armed text, verbatim.

---

## Panel specification

### Required fields

| Field | Value | Why it is there |
|---|---|---|
| `RUN` | run id | correlates panel, envelope, ledger, dispatch |
| `STAGE` | `DISPATCH` and the stage path | tells the user this is the point of no return |
| `TARGET` | `host` `agent` `model` `mode` | the user must know which agent is about to act |
| `GUARD` | verdict and per-check counts | a `warn` must be visible, not buried in prose |
| `SIZE` | raw → armed tokens and delta | arming that triples the prompt is a fact worth seeing |
| `DIGEST` | `sha256:` of the armed text | makes "what exactly ran" answerable later |
| `ARMED PROMPT` | the armed text itself | not a description of it |

### Layout rules

- Render **once** per run. A second panel means a second run; give it a new id.
- Fixed-width box, `╔ ═ ╗ ║ ╠ ╣ ╚ ╝`. Default inner width 78, clamped to 60–120.
- Long prompts are truncated with `… +N more lines → <path to full prompt>`.
  The truncation must be visible; a silently clipped prompt is a lie.
- No emoji inside the box. Color is optional and must degrade to nothing.
- The digest is shown truncated to 6 hex characters after the prefix. The full
  value is in the envelope.

### Box form

```text
╔══════════════════════════════════════════════════════════════════════╗
║  KARAVI · PROMPT ARMED · IN EXECUTION                              ║
╠══════════════════════════════════════════════════════════════════════╣
║  RUN     : kp-20261001T081455Z-4f9ac2                             ║
║  STAGE   : DISPATCH   (RAW → ENGINEER → GUARD → PANEL)             ║
║  TARGET  : host=omp agent=task model=frontier mode=read-only       ║
║  GUARD   : PASS  secret=0 injection=0 taint=0 contract=ok          ║
║            budget=ok placeholder=0 armDelta=0 portability=0        ║
║  SIZE    : raw=118 tok -> armed=402 tok (+241%)                   ║
║  TECH    : xml-structuring, quote-then-answer                      ║
║  DIGEST  : sha256:4f9ac2…                                         ║
╠══════════════════════════════════════════════════════════════════════╣
║  ARMED PROMPT                                                      ║
║  ─────────────                                                     ║
║  <mission>                                                         ║
║  Rewrite the stale retention policy in docs/retention.md so that it  ║
║  matches karavi-folder's current cleanup rules.                     ║
║  …                                                                 ║
╠══════════════════════════════════════════════════════════════════════╣
║  MODE NOTE: read-only. No workspace mutation is authorized by this   ║
║  run. A mutating run still requires karavi-terminal approval.       ║
╚══════════════════════════════════════════════════════════════════════╝
```

The `MODE NOTE` band appears for every run. For `mutating` it names the
approval still owed; for `network` and `secret` it names the boundary.

### Markdown form

For hosts with no shell — Cursor chat, Claude Code, Codex, OpenCode, Cline, and
any terminal that mangles box drawing. Same information, plain fences:

```markdown
> **KARAVI · PROMPT ARMED · IN EXECUTION**
>
> | field | value |
> |---|---|
> | RUN | `kp-20261001T081455Z-4f9ac2` |
> | STAGE | `DISPATCH` (RAW → ENGINEER → GUARD → PANEL) |
> | TARGET | `host=omp agent=task model=frontier mode=read-only` |
> | GUARD | `PASS` — secret=0 injection=0 taint=0 contract=ok |
> | SIZE | raw=118 tok → armed=402 tok (+241%) |
> | DIGEST | `sha256:4f9ac2…` |
>
> **ARMED PROMPT**
>
> ```text
> …the armed prompt, truncated with a pointer if long…
> ```
>
> **MODE NOTE** — read-only; no workspace mutation authorized by this run.
```

`karavi-prompt.panel.ps1 -Format Markdown` emits exactly this. The fenced
block must stay closed; an unclosed fence swallows the rest of the answer.

### JSON form

`-Format Json` returns the panel as data for hosts that render it themselves:

```json
{ "run": "kp-…", "stage": "DISPATCH", "target": {}, "guard": {},
  "size": { "rawTokens": 118, "armedTokens": 402, "deltaPercent": 241 },
  "digest": "sha256:…", "mode": "read-only",
  "panel": "…rendered text…", "truncated": false, "fullPromptPath": "…" }
```

---

## Dispatch protocol

1. **Verbatim.** The dispatched text equals the envelope's `dispatch` field,
   byte for byte. No preamble, no "I will now…", no restatement, no apology
   for the format.
2. **One target per run.** Two targets means two runs, two panels, two ledger
   lines. A run cannot fan out.
3. **No re-engineering at dispatch.** If the target's context reveals a defect,
   close the run and re-arm. Do not patch in flight.
4. **Then close.** Append `event: dispatched`, execute, append `event: closed`
   with the outcome and the rubric score.
5. **User edits are new runs.** A corrected panel allocates a new id, a new
   digest, and a new guard pass.

### What dispatch looks like to the target

The target receives a self-contained instruction. It does not know a panel
existed, does not need the run id, and must not be asked to re-derive the
scope. If the armed prompt references the run id, that reference is noise —
remove it before arming.

---

## Host adapters

| Host | How to show the panel | How to dispatch |
|---|---|---|
| **omp** | `karavi-prompt.panel.ps1 -Run <envelope> -Ansi` in the terminal; the box is the record | pass `dispatch` to `task` as the subagent `task` field, or apply it inline |
| **Claude Code** | `-Format Markdown` into the assistant message | inline as the next user turn |
| **Cursor** | `-Format Markdown`; keep the fence closed | inline in the chat composer |
| **Codex / Cline** | `-Format Markdown` or `-Format Json` when the host renders structured blocks | inline |
| **Any CI or script** | `-AsJson`, assert on `guard.verdict` before continuing | fail the step on `block` |

Adapters differ only in rendering. The guard verdict, the digest, and the
dispatch bytes are identical everywhere.

---

## Panel variants by mode

| `target.mode` | Extra band | Behavior |
|---|---|---|
| `read-only` | "no workspace mutation authorized" | dispatch directly after the panel |
| `mutating` | "requires karavi-terminal mutation approval" | panel first, then the karavi-terminal approval block, then dispatch |
| `network` | "outbound calls permitted to the listed hosts" | dispatch; record the host list in the envelope |
| `secret` | "credential boundary" | the guard blocks; no panel is rendered |

A `mutating` run never bypasses `karavi-terminal` approval because the panel
looked clean. The panel states the obligation; it does not satisfy it.

---

## Re-rendering a panel

Panels are re-rendered for display at a different width or after a color
decision, never to change what runs. The digest is the invariant: if a
re-rendered panel shows a different digest, it is a different prompt and needs
a guard pass.

```powershell
& .agents/skills/karavi-prompt/scripts/karavi-prompt.panel.ps1 `
  -Run karavi.temp.status/karavi-prompt/runs/kp-20261001T081455Z-4f9ac2.json `
  -Format Box -Width 100 -Ansi
```
