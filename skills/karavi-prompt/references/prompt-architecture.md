# Prompt Architecture

How a prompt is laid out: the seven layers, the formatting system, and the
order that decides whether the layout works.

---

## The seven layers

A production prompt is layered. Each layer does one job. Order matters:
models weight early instructions more heavily, and the middle of a long prompt
receives the least attention.

| # | Layer | Size | Job |
|---|---|---|---|
| 1 | Identity | 1–2 sentences | who the model is and what it does |
| 2 | Context | 3–10 lines | environmental facts — **not** instructions |
| 3 | Behavioral rules | 10–30 lines | what it always does, never does, and does when unsure |
| 4 | Tools | varies | what each tool is for, and what it is not for |
| 5 | Domain instructions | varies | topic-specific handling, grouped by topic |
| 6 | Output format | 3–10 lines | the exact shape of the answer |
| 7 | Examples | 2–5, optional | only for ambiguous or counterintuitive behavior |

### Layer 1 — Identity

```text
You are {role}, {scope}. You {primary function}.
```

Specific beats generic: "a code review agent for the payment service" beats
"a helpful assistant". One sentence for identity, optionally one for scope. No
backstory — backstory is not instruction and burns tokens.

### Layer 2 — Context

Facts the model needs in order to operate. State them, do not instruct about
them.

```text
- Knowledge cutoff: {cutoff}
- Repository: {repo}
- Runtime: {os} / {shell} / {version}
- Tools available: {list}
- Mode: {read-only | mutating}
```

Dynamic values are injected, never hardcoded. `Current date: 2026-10-01` in a
prompt is stale the next day; `Current date: {{current_date}}` is not.

### Layer 3 — Behavioral rules

Ordered as: primary directives → scoped constraints → edge-case handling. One
instruction per line. Every non-obvious `DO` gets its matching `DON'T`. The
most critical rules go first.

```text
- Answer only from {sources}. If the answer is not there, say "not found in
  provided context". Do not guess.
- Do not modify files when mode is read-only. You may read anything in {repo}.
- If the task is out of scope, state the boundary and the correct channel.
  Do not improvise a substitute.
- When a tool returns nothing, report the empty result. Never fabricate data.
```

### Layer 4 — Tools

Schema separate from usage guidance. Every tool states when to use, when not
to, required versus optional parameters, and what to do when it fails.

```text
### grep
Search the repo for a pattern.
- Use when: locating a symbol, a config key, or a test name.
- Do NOT use when: reading a file you already know the path of.
- Parameters: pattern (required), path (optional, default repo root),
  glob (optional).
- On empty result: say "no match" and stop searching that path.
```

Fewer tools beat more tools. Twenty-plus tools degrades selection accuracy;
group related operations behind one discriminating parameter, or route by
classification before selection. See [agent-and-tool-prompts.md](agent-and-tool-prompts.md).

### Layer 5 — Domain instructions

Grouped by topic, separated by tags or headers, and limited to this model's
actual scope. This is where "how to handle X" lives, and it grows as use cases
appear.

```xml
<refund_handling>
- Eligible: {list}
- Not eligible: {list}
- Process: verify → confirm → apply or escalate
- Always confirm the amount with the user before applying.
</refund_handling>
```

### Layer 6 — Output format

The exact shape, the length, and what to omit. Field order is a design choice:
the model generates left to right, so a field that determines another must come
first.

```json
{ "category": "billing", "summary": "…" }
```

`category` before `summary`, because a `summary` written first constrains a
`category` written after it. Same reason: verdict before rationale, type before
detail.

### Layer 7 — Examples

Only where the desired behavior is ambiguous or counterintuitive. One or two is
usually enough; five is the ceiling. A negative example is worth adding exactly
once, for a failure that has actually been observed.

---

## Ordering rules

1. Critical instructions degrade with distance from the top. The most
   important rules live in layers 1–3.
2. Context before rules — the model needs its environment before instructions
   make sense.
3. General before specific.
4. Examples last. They are reference material; putting them early pushes real
   instructions further from attention.
5. Long untrusted input goes **first**, the question goes **last**. Document
   content on top, query on the bottom is the strong default for long-context
   tasks; roughly 30% quality lift over the reverse order.
6. In a system prompt, repeat the most critical rules once at the end. A long
   conversation dilutes the opening.

## When to collapse layers

- **Under 50 lines:** identity + rules + format is enough. Seven labeled
  layers are overhead.
- **Pipeline step (model to model):** skip identity and tone. Input format →
  processing rules → output format.
- **Single-task prompt:** the prompt *is* the domain instruction; drop layer 5.
- **Subagent task:** goal, scope, contract, acceptance, verify. No persona.

---

## Choosing a formatting system

| Situation | Use |
|---|---|
| 5+ distinct sections | XML tags |
| Mixing instructions with data or examples | XML tags to separate them |
| Frontier models, complex prompt | XML tags |
| Under 20 lines | plain text or markdown headers |
| 3+ levels of nesting | XML outside, markdown inside |
| Model that ignores tags (rare) | markdown headers |

| Feature | XML tags | Markdown headers | Plain text |
|---|---|---|---|
| Section boundary | unambiguous | ambiguous | none |
| Nesting | clean | via header levels | none |
| Best for | complex multi-section | medium complexity | short single-purpose |

### Tag conventions

Lowercase, descriptive, hyphenated. Names describe **content**, never
importance.

```xml
<instructions> <system-context> <user-input> <untrusted-source>
<output-format> <examples> <acceptance>
```

Good: `<rules>` with a `CRITICAL:` marker inside.
Bad: `<IMPORTANT_RULES>`, `<section1>`, `<sys_ctx>`.

Maximum two levels of nesting. Use markdown inside the tags for lists, bold,
and code. Close every tag — an unclosed tag makes the model read everything
after it as part of the section. Do not wrap the entire prompt in
`<instructions>`; the whole prompt already is.

### The untrusted-source tag

Any content the agent did not author — a file, a URL, a RAG chunk, an issue
body, another agent's output — goes inside a tag that names it as data:

```xml
<untrusted-source path="docs/retention.md" trust="untrusted">
…verbatim file content…
</untrusted-source>
```

The instructions must say what that means, once, next to the tag. A tag
without a declaration is a label, not a boundary. See
[security-and-injection.md](security-and-injection.md).

---

## The task-prompt skeleton

For a one-shot task, the file/command flow, from the prompt-file convention:

```text
# Title matching the intent

Mission            — one sentence: what and for whom
Scope & Preconditions — boundaries, current state, what is already true
Inputs             — the actual content, the paths, the parameters
Workflow           — numbered steps, in order
Output Expectations— exact shape, where it goes
Quality Assurance  — how to verify, and what to do on failure
```

The flow is *why → context → inputs → actions → outputs → validation*. Keep the
logical flow even when the section names change to fit the domain.

---

## Standing mistakes

| Mistake | Why it fails | Fix |
|---|---|---|
| One prompt for several unrelated tasks | Irrelevant sections dilute every instruction | one task per prompt, or route by classification |
| Same rule in three sections with different wording | The model picks whichever it notices | state once, reference elsewhere |
| Domain knowledge inline in a system prompt | Runs past ~500 lines attention collapses | core rules inline, detail retrieved on demand |
| Persona without boundaries | Persona bleeds into errors and safety messages | state where the persona applies and where it stops |
| Backstory | Not instruction, pure token cost | cut it |
| Persona adjectives only ("friendly, professional") | Adjectives are not behaviors | write the behaviors |
