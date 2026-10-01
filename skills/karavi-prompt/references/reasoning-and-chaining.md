# Reasoning and Chaining

When to ask a model to reason out loud, when to split the work across calls,
and how to stop either from silently producing garbage.

---

## Chain of thought

Use it when a human would have to think it through: multi-constraint
decisions, analysis, math, code that must be right. Skip it for lookups and
straight generation — it costs latency and tokens for nothing.

| Level | Instruction | Tradeoff |
|---|---|---|
| Basic | "Think step by step." | easy, unstructured |
| Guided | "First do X, then consider Y, then decide Z." | reliable, reasoning still mixed with the answer |
| Structured | reasoning in one tag, answer in another | best: reasoning is cleanly separable |

```text
Work through each condition in &lt;reasoning&gt;, then give the decision in
&lt;answer&gt;.
```

**The rule that matters:** the model must *output* the reasoning. Instructing it
to "think" without giving it somewhere to write does not improve anything.
Reasoning that is not generated does not happen.

**On reasoning models** — o-series, extended thinking, thinking mode — explicit
CoT is redundant and can hurt: the model already reasoned internally, and the
prompt asks it to reason again, wasting tokens and sometimes contradicting
itself. Give those models the task plus clear success criteria and stop.

In a Karavi run, `target.model = reasoning` means the armed prompt carries no
CoT instruction. Any CoT in that prompt is a defect.

---

## Prompt chaining

Split when a single prompt skips steps, produces inconsistent quality, or asks
too much at once. Also split when different steps want different model
classes.

Common shapes: extract → transform → validate; research → outline → draft →
edit; generate → self-critique → revise; classify → route → handle.

```python
# Step 1 — one objective
step1 = """
Extract each distinct complaint from the ticket below.
Output a JSON array of strings and nothing else.
<ticket>{{ticket_text}}</ticket>
"""
complaints = json.loads(call_llm(step1))

# Step 2 — receives structured output
step2 = f"""
Classify each complaint into exactly one of: authentication, performance,
billing, other. Output a JSON array of objects with "complaint" and "category".
<complaints>{json.dumps(complaints)}</complaints>
"""
```

Principles:

- One objective per step.
- Structured handoffs between steps, never prose.
- Independent subtasks run in parallel; dependent ones do not.
- A verification step at the end for anything consequential.

---

## Inter-step resilience

Step N produces malformed or subtly wrong output, and step N+1 consumes it
without noticing. The corruption is invisible until the end.

**Validate between steps.** Parse and schema-check after each one. If step 1
promised a JSON array and returned a markdown list, catch it there.

**Retry with feedback.** Append the error to the failed step: "Your previous
output was invalid: {error}. Produce output matching this schema: {schema}."
Cap at two or three retries; past that the step is mis-specified, not unlucky.

**Make downstream steps resilient.**

```text
The input below came from a prior step and may contain errors or missing
fields. If a field is missing or malformed, note it and continue with what is
available. Never fabricate to fill a gap.
```

**Design the failure output.** Every chained step declares a failure shape
(`{"status":"handoff_failed","reason":"…"}`) so the orchestrator can branch
instead of parsing prose to guess what happened.

---

## Shared concept alignment

Two chained prompts are two stateless models. Neither inherits the other's
understanding. If both use "lead", "qualified", "production", or "done", both
must define those identically — extract the shared definitions into one
preamble block and inject it into every step that needs them.

This is the single most common cause of a chain that contradicts itself: step 2
redefines the term step 1 was graded on.

---

## Decomposition in an agent prompt

When a request has more than one deliverable, the armed prompt either lists the
deliverables as an explicit checklist in order, or splits into separate runs.
A checklist inside one prompt is fine for closely coupled deliverables; separate
runs are correct when each deliverable needs a different target, a different
mode, or an independent acceptance check.

Naming the steps beats "think step by step" every time:

```text
1. Identify the affected components from the request.
2. Read each one before proposing a change.
3. State the change and its risk.
4. Apply it.
5. Re-read the result and check it against the acceptance criteria.
```

---

## Self-check

For code, math, claims, architecture, or anything where an error is costly,
close with a verification instruction near the end:

```text
Before you finish, re-read your answer and check it against every
acceptance criterion above. If any criterion is unmet, fix it or state
which one and why.
```

Cheap, and it catches a real fraction of errors — but it is not a substitute
for the acceptance criteria actually being written down.

---

## Research and analysis

For open-ended investigation, ask for competing hypotheses with tracked
confidence and periodic self-critique:

```text
Develop several competing hypotheses as you gather information. Track a
confidence level for each. Self-critique the approach at each stage: what
would falsify the leading hypothesis, and have you looked for that?
```

Coverage over filtering is the rule in review and research alike — report
everything found, with confidence attached, and let a downstream stage rank it.
