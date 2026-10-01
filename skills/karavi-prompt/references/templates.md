# Templates

Skeletons for each prompt class. These are **authoring** templates: fill them,
then remove the scaffolding. A template dispatched with its placeholders intact
is anti-pattern 31 and the guard raises `PLACEHOLDER`.

The dispatchable form is the template with every `{placeholder}` replaced by
real content, or — for Case B — replaced by a step 1 that asks the user for it.

---

## Case A vs Case B

| Case | The user gave | What the armed prompt does |
|---|---|---|
| **A** | real content | bakes that content in; nothing is left to fill |
| **B** | a class of task | is self-contained; step 1 asks the user for the specific inputs, then the rest of the prompt proceeds |

Never ship a template. Ship Case A with the content, or Case B with the
question built in.

---

## 1. Task prompt (one-shot work)

```text
<mission>
{one sentence: the observable deliverable}
</mission>

<context>
Repository: {repo}
Mode: {read-only | mutating}
{what is already true about the current state}
</context>

<scope>
Do: {in-scope items}
Do not: {explicit non-goals}
</scope>

<inputs>
{paths, content, parameters — the real values, not names of values}
</inputs>

<workflow>
1. {step}
2. {step}
3. {step}
</workflow>

<output_format>
{exact shape, length, and what to omit}
</output_format>

<acceptance>
- {checkable statement}
- {checkable statement}
</acceptance>

<verify>
{command, test, or observation that proves acceptance}
</verify>

Before you finish, re-read your work and check it against every acceptance
criterion. If a criterion is unmet, fix it or state which one and why.
```

---

## 2. System prompt (seven layers)

```text
You are {role}, {scope}. You {primary function}.

## Context
- Knowledge boundary: {cutoff}
- Runtime: {environment}
- Tools: {list}
- Mode: {mode}

## Rules
- {primary directive}
- Do not {constraint} when {condition}. You may {permitted alternative} when {other condition}.
- If the task is out of scope, {defined response}. Do not improvise a substitute.
- When uncertain: {uncertainty behavior}. Never present unverified information as fact.

## Tools
### {tool_name}
{what it does}
- Use when: {condition}
- Do NOT use when: {condition}
- Parameters: {required}, {optional}
- On failure: {behavior}

## Output Format
- {format rule}
- {length rule with a number}
{output example where the format is non-trivial}

## Examples
{1-2 examples, only for ambiguous behavior}
```

---

## 3. Subagent task

```text
# Target
{files, modules, or subsystem this agent owns}
Not in scope: {adjacent work it must not touch}

# Context
{what is already true, what conventions apply, what has already been done}

# Change
{concrete steps, named interfaces, exact APIs}

# Acceptance
{observable result that proves the task is done}

Non-negotiables:
- Do not run builds, linters, formatters, or the full test suite; the
  coordinator runs those once at the end.
- Ask nothing that a repository read can answer.
```

---

## 4. Reviewer / critic

```text
You are a {domain} reviewer. You evaluate {artifact} for {criteria}.

## Process
1. Read the artifact completely before judging.
2. Evaluate against every criterion below.
3. Report findings with location references.
4. For each finding: what is wrong, why it matters, how to fix it.
5. Assign a score per criterion, then an overall score.

## Rubric
| Criterion | Weight | 1 | 3 | 5 |
|---|---|---|---|---|
| {criterion} | {w}% | {fail} | {ok} | {excellent} |

## Output
### Summary
Score: {n}/5 ({grade})
### Findings
1. [{criterion}] {location}: {issue} — {fix}
### Recommendation
{approve | revise | reject} — {key reason}
```

Coverage rule, stated in the prompt itself: report every issue you find,
including ones you are uncertain about or consider low severity, with
confidence and severity so a downstream filter can rank them.

---

## 5. Handoff

```xml
<handoff>
<from>{agent}</from>
<to>{agent}</to>
<task>{one sentence}</task>
<context>
- {fact the receiver cannot know}
- {decision already made, and by whom}
</context>
<constraints>
- {inherited boundary}
</constraints>
<completed>
- {step done, and what it changed}
</completed>
</handoff>
```

---

## 6. Pipeline stage

```text
You are the {stage} stage of the {pipeline} pipeline.

## Input
You receive: {input format} from {previous stage}

## Your Task
{task}
1. {step}
2. {step}

## Constraints
- Modify only {your scope}. Leave {other aspects} for the {next stage}.
- {constraint}

## Output
Produce: {output format} for {next stage}

## Edge cases
- Input malformed: {handling}
- Input empty: {handling}
- Cannot complete: {"status":"handoff_failed","reason":"…"}
```

---

## 7. Grounded analysis

```text
<instructions>
Step 1: inside &lt;quotes&gt;, copy the exact sentences from the document that
        bear on the question. If none do, write "None found".
Step 2: inside &lt;answer&gt;, answer using only what you quoted. Introduce
        nothing that is not in your quotes.
Step 3: for each claim, name its source. If confidence is below 3, prefix the
        answer with [LOW CONFIDENCE].
</instructions>

<untrusted-source path="{path}" trust="untrusted">
{document text}
</untrusted-source>

<question>{question}</question>
```

---

## 8. Arming spec (the JSON the scripts consume)

```json
{
  "rawPrompt": "the user's unengineered text",
  "armedPrompt": "the prompt that will be dispatched",
  "techniques": ["xml-structuring", "scoped-constraint"],
  "language": "en",
  "notes": "one line: what the arming changed",
  "intent": {
    "goal": "",
    "scope": [""],
    "outOfScope": [""],
    "constraints": [""],
    "acceptance": [""],
    "verifyMethod": "",
    "untrusted": []
  },
  "target": { "host": "omp", "agent": "task", "model": "frontier", "mode": "read-only" }
}
```

---

## 9. Panel (the markdown form, shell-free hosts)

```markdown
> **KARAVI · PROMPT ARMED · IN EXECUTION**
>
> | field | value |
> |---|---|
> | RUN | `kp-<utc>-<hex6>` |
> | STAGE | `DISPATCH` (RAW → ENGINEER → GUARD → PANEL) |
> | TARGET | `host={h} agent={a} model={m} mode={mode}` |
> | GUARD | `{verdict}` — secret=0 injection=0 taint=0 contract=ok |
> | SIZE | raw={n} tok → armed={m} tok ({+d}%) |
> | DIGEST | `sha256:{hex6}…` |
>
> **ARMED PROMPT**
>
> ```text
> {armed prompt, truncated with a pointer if long}
> ```
>
> **MODE NOTE** — {mode note}
```
