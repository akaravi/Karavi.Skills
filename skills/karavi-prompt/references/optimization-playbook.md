# Optimization Playbook

Model-class selection, the technique catalog, the token budget, and the
compression pass. This is what `ENGINEER` executes.

---

## Model class first

The class decides prompt length, tool budget, example count, and whether CoT is
asked for at all.

| Class | System prompt | Tools | CoT | Examples |
|---|---|---|---|---|
| **frontier** | long and complex is fine | 15–20 reliable | usually unnecessary; native reasoning suffices | optional |
| **mid-tier** | keep under ~2000 words or instruction-following degrades | ≤10, route by classification | structured CoT with explicit tags beats "think step by step" | important — these models generalize less from prose |
| **small / local (<20B)** | short and direct, one task | 3–5, or hardcode routing | helps, keep the steps simple | essential |
| **reasoning** | task plus success criteria, no scaffolding | as needed | **do not add** — it reasons internally already | optional |

Mid-tier and small models show the lost-in-the-middle effect more strongly:
critical content belongs at the top *and* the bottom.

In a chained pipeline the classes mix: frontier for the hard step, mid-tier for
straight extraction or classification. That is a cost decision, not a
correctness one.

---

## Technique catalog

Load only the technique the defect needs.

| Defect | Technique | What it looks like |
|---|---|---|
| Output shape is guessed | **output format spec** | exact skeleton with placeholders, plus 1–2 examples |
| Instructions blur into data | **delimiters** | `<instructions>` / `<context>` / `<input>` / `<output_format>` |
| Same shape varies across runs | **constrained output** | schema, JSON mode, function calling, or assistant prefill |
| Domain words are defaulted wrongly | **operational definition** | "In this system, churned means no login for 14 consecutive days" |
| Facts are invented | **quote-then-answer** | extract into `<quotes>`, then answer only from the quotes |
| Uncertainty is invisible | **confidence calibration** | rate each claim 1–5; below 3, prefix `[LOW CONFIDENCE]` |
| The model refuses legitimate work | **role framing for purpose** | "You are classifying harmful content, not producing it" |
| Format drifts in tone | **register alignment** | write the instruction in the register the output needs |
| Too many steps are skipped | **prompt chaining** | one objective per call, validated between steps |
| One call is too big | **classification before routing** | narrow to a branch, then act |
| The wrong tool is called | **tool descriptions + when-not-to-use** | see [agent-and-tool-prompts.md](agent-and-tool-prompts.md) |
| It will not stop | **termination condition** | "You are done when you have produced the final JSON" |
| The model drifts over turns | **re-assertion** | repeat the critical rules at the end of the system prompt; test at turn 50 |
| Tokens are wasted | **static prefix** | static content first, dynamic last — see [caching](optimization-playbook.md#caching-and-cost) |
| The same failure recurs | **negative example** | show the wrong output, label it, then show the right one |

---

## Prompting patterns

| Pattern | Use for | Note |
|---|---|---|
| **Zero-shot** | simple, well-defined | the default; do not add structure for its own sake |
| **Few-shot** | format-sensitive or ambiguous | 1–2 to start; add only when inconsistency shows. Diverse, with one edge case |
| **Chain-of-thought** | multi-constraint, analysis, math | ask for it in a tag, or it will not happen |
| **Role prompting** | domain-registered answers | one line, only when it sharpens the output |
| **Self-consistency** | high-stakes single answers | sample several, take the agreed answer; costs N× |
| **Generated-knowledge** | the model needs to reason about its own output | generate context first, then answer from it |
| **Decomposition** | any task with more than one deliverable | one objective per sub-task, in one prompt or across several |

---

## The nine-step rewrite

1. **Name the goal** — what artifact, decision, or change must exist.
2. **Name the audience and the use** — who reads it, and what they do next.
3. **Pick the case** — A: content was given, bake it in. B: a class of task was
   described, write a self-contained prompt that asks for what it needs first.
4. **Find the gaps** — audience, format, length, constraints, examples, edge
   cases. Anything missing is a defect, not a style preference.
5. **Close the gaps** — assume and state for the non-essentials; make the
   prompt ask the user for the critical ones.
6. **Pick the structure** — one paragraph, or XML tags. Proportional to the
   task; a haiku prompt with seven layers is worse than no prompt.
7. **Write it** — positive framing, the reason attached once, literal scope
   ("apply to every section, not just the first").
8. **Close with the reasoning signal** — matched to the class. Reasoning
   models: skip it. Others: a single closing line, not competing instructions
   earlier in the prompt.
9. **Scan for placeholders** — re-read and remove every `[…]`, `{…}`, `<your…>`,
   `___` that survived. A dispatched prompt with an unfilled placeholder is
   unfinished work.

---

## Writing rules

**Positive framing.** "Write in flowing prose paragraphs" beats "don't use
bullet points". Lead with the desired behavior; add the restriction second.

**Show the why, once.** "No ellipses — this output is read by a TTS engine that
mispronounces them" is stronger than "Never use ellipses", and it costs one
clause rather than a paragraph. State the rule once; do not restate it three
ways.

**Be literal about scope.** Models do not always generalize. "Apply this to
every section, not just the first one." Use imperative verbs when you want
action: "Edit the function to…", not "Could you suggest improvements to…".

**Match style to style.** If the output should be terse, the prompt is terse.
If the output should be prose, the prompt is prose. Style leaks.

**One instruction per sentence.** "Be concise and cite sources and use a formal
tone" is three instructions, each of which gets less attention packed together.

**Review jobs are coverage jobs.** "Report every issue you find, including ones
you are uncertain about or consider low severity, with confidence and severity
so a downstream filter can rank them." Soft filters like "only flag important
issues" silently drop real bugs.

**Verification closes high-stakes work.** "Before you finish, re-read your
answer and check it against the criteria above."

---

## Token budget

Budget by instruction text, excluding untrusted payload.

| Budget | Shape |
|---|---|
| <200 tokens | single purpose: identity + 3–5 rules + format. No examples |
| 200–500 | standard: identity, context, rules, format. One example |
| 500–1000 | full seven layers, 2–3 examples, domain sections |
| 1000–2000 | agent-scale: tools, multi-domain, edge-case handling |
| >2000 | split: core prompt plus retrieval for domain knowledge |

Above ~500 lines of system prompt, instruction-following degrades and the
middle stops being attended to. Reference material is retrieved, not embedded.

### Compression

Token optimization is not brevity. It is every token earning its place. A
500-token clear prompt beats a 200-token ambiguous one. Compress only after
clarity, and re-read afterward as if seeing it for the first time.

| Technique | Effect |
|---|---|
| Cut filler | "It is very important that you…" → "…". "In your capacity as an AI…" → cut |
| Merge duplicates | three phrasings of one rule → the most specific single rule |
| Description → example | "full month name, day number, comma, four-digit year" → `January 15, 2025` |
| Paragraph → table | routing rules read as a topic → destination table |
| Group conditionals | scattered `if free-tier` lines → one `<free-tier-rules>` block |
| Parameterize | hardcoded dates and versions → injected values |

**Do not compress** when the behavior is ambiguous, the constraint is a safety
rule, the behavior is novel or counterintuitive, the process has multiple steps
that must not be skipped, or the output format is complex enough that one
example beats fifty words of description.

---

## Caching and cost

Provider caching bills a static prefix at a discount. That makes layout a cost
decision, not just a quality one.

```text
[ system prompt ]      ┐
[ role and rules ]     │
[ tool schemas ]       ├── static prefix: identical on every call
[ examples ]           │
[ reference docs ]     ┘
────────── cache boundary ──────────
[ user query ]         dynamic suffix
```

Never reorder between calls. A one-token difference in the prefix invalidates
the whole cache. Caching matters when calls are numerous, the system prompt is
long, or a base prompt is re-sent every turn of a loop.

### Portability

| Concern | Anthropic | OpenAI / Azure | Google |
|---|---|---|---|
| system prompt | dedicated `system` parameter | `role: "system"` message | `system_instruction` field |
| forced output shape | trailing `assistant` prefill | `response_format` / structured outputs | trailing model-role turn, `responseMimeType` |
| caching | explicit breakpoints | automatic on longest matching prefix | named cache with TTL |

Temperature is provider- and model-specific; reasoning models often ignore it.
Reach for a structural fix — schema, examples, prefill — before a numeric knob.
Any provider-specific mechanism in an armed prompt needs a stated fallback, or
the guard raises `PORTABILITY`.

---

## Failure table

| Symptom | Cause | Fix |
|---|---|---|
| Wrong format | format spec missing or ambiguous | explicit schema + 2–3 examples |
| Invented facts | no grounding | source restriction + quote-first + "say not found" |
| Skipped steps | too much in one prompt | chain it, validate between steps |
| Inconsistent tone | role missing or vague | one specific role line |
| Wrong tool called | overlapping tool descriptions | sharpen, reduce count, add when-not-to-use |
| Never stops | no termination condition | explicit completion criteria |
| Sometimes works | ambiguity resolved differently per run | examples + tighter wording |
| Ignores a constraint | constraint buried mid-prompt | move it to the end, or repeat it |
| Injected | input not separated | [security-and-injection.md](security-and-injection.md) |
| Drifts over turns | system prompt diluted | re-assert, summarize history, test at turn 50 |
| CoT hurts a reasoning model | explicit CoT on a native reasoner | remove it, let the model think |
| Truncated JSON | hit `max_tokens` | raise the cap, compact the output, validate |
| "Do not X" causes X | negative constraint hit a stylistic prior | reframe positively |
| Broke after a model upgrade | phrasing was tuned to old behavior | re-score against the eval set; do not assume regression |
| Expensive on repeat calls | static prompt re-processed | restructure into a static prefix |
