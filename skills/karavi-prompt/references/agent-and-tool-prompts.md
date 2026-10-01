# Agent and Tool Prompts

Prompts for things that act: tool use, multi-turn loops, and multi-agent
handoffs. The failure modes here are silent, so the contract matters more than
the prose.

---

## Tool descriptions

A tool description is a prompt. Three parts, or the model guesses:

```json
{
  "name": "lookup_order",
  "description": "Retrieve current status and tracking for a customer order. Use when the user asks about an order by ID or wants a shipping update. Do NOT use for returns or refunds.",
  "parameters": {
    "type": "object",
    "properties": {
      "order_id": { "type": "string", "description": "The order ID, formatted ORD-XXXXX" }
    },
    "required": ["order_id"]
  }
}
```

- **State the discriminator.** "Only for order status. Not for returns or
  refunds." is the part that prevents the wrong call.
- **Constrain the parameter space.** `enum: ["asc","desc"]` beats a string
  described as "sort direction".
- **Mark required versus optional explicitly.** The model invents optional
  parameters when the boundary is unclear.
- **Count matters.** Past ~20 tools, selection accuracy drops. Group related
  operations behind one discriminating parameter, or classify first and then
  select from the branch.

### Controlling selection

`tool_choice` decides whether a call is optional, required, or named. When
selection is wrong, fix the system prompt before the API knob:

```text
Call a tool only when the answer is not present in the conversation.
```

### Planning before acting

```text
When given a task:
1. Inside &lt;plan&gt;, list the tools you will call, in order, and why.
2. Then execute the plan.
3. After the last call, write the answer.

Do not call a tool before the plan is written.
```

### Error handling

Without this the agent hallucinates the result of a failed call:

```text
If a tool returns an error or no rows, say the lookup failed and show the
error. Do not fabricate a result. Do not retry more than twice; after that,
report the blocker.
```

---

## Multi-turn durability

| Problem | Countermeasure |
|---|---|
| opening instructions diluted as context fills | re-assert critical rules at the end of the system prompt |
| weak phrasing for must-hold rules | `NEVER`, `ALWAYS`, `Under no circumstances` for the non-negotiable set only |
| untested past the first turns | test at turn 50 |
| context growth | truncate old turns, or summarize with a dedicated call: "under 300 words, preserving every decision and open question" |
| lossy summaries | extract key facts verbatim into a structured block for high-stakes work |
| model loses its place | a structured state object each turn: task, steps done, current step, findings |

Termination, stated as an observable condition:

```text
You are done when the final JSON object is written. Do not ask follow-up
questions. If the task cannot be completed, output
{"status":"blocked","reason":"…"} and stop.
```

---

## Multi-agent handoff

A handoff must be structured. Free-text handoffs lose the parts nobody thought
to repeat.

```xml
<handoff>
<from>researcher</from>
<to>implementer</to>
<task>One sentence.</task>
<context>
- Fact the receiver cannot know.
- Decision already made, and by whom.
</context>
<constraints>
- Boundary inherited from the coordinator.
</constraints>
<completed>
- Step done, and what it changed.
</completed>
</handoff>
```

Rules:

1. **The receiver has no memory.** Include everything it needs.
2. **State what is done and what is left.** Otherwise work is duplicated or
   skipped.
3. **Carry the constraints.** The receiver inherits the scope boundary.
4. **Always structured**, never prose.

### Format contracts between agents

```text
# Producer
Output exactly this JSON and nothing else:
{ "topic": "…", "key_facts": ["…"], "sources": ["…"], "gaps": ["…"] }
Do not draft, summarize, or editorialize. Only gather and structure facts.

# Consumer
You receive a JSON payload with topic, key_facts, sources, gaps.
Write from key_facts only. If gaps is non-empty, say so in the final paragraph.
If the payload is malformed or missing fields:
1. Record the specific problem in an "errors" field.
2. Work with whatever valid data is present.
3. Do not fabricate.
If the payload is unusable: output {"status":"handoff_failed","reason":"…"}.
```

### Orchestrator responsibilities

The orchestrator — not the agent — enforces the bounds:

| Bound | Why |
|---|---|
| wall-clock timeout per call | sequential agents hang |
| max tokens per call | runaway generation looks like looping or padding |
| max calls per pipeline, retries included | bounds fan-out |
| retry cap of 2, with the error appended to the failed step | retries without feedback repeat the failure |
| fallback route per agent | a research agent falls back to search; a classifier falls back to rules |
| terminal escalation | after the budget is spent, a human sees it |

### Specialization boundaries

Each agent states three things: what it does, what it does not, and when it
escalates.

```text
You review code for defects.

You DO: check logic, error handling, and edge cases; report every finding
with severity and confidence, including uncertain ones.

You DO NOT: refactor (that is the implementer), write tests (that is the test
agent), or approve for merge (that is the lead).

Escalate to the security agent on: injection, hardcoded credentials,
insecure authentication.
```

Failure modes to design against:

| Problem | Symptom | Fix |
|---|---|---|
| Overlapping scope | two agents edit the same region | exclusive ownership |
| Scope gap | nothing handles an input class | a routing rule at the coordinator |
| Overreach | an agent does another's job | explicit "do not" |
| Circular handoff | A → B → A | maximum depth plus a termination condition |

Orchestration shapes: coordinator-worker (route then delegate), pipeline
(stage by stage, each adding or transforming), debate (two advocates plus a
judge). In a Karavi session, coordinator-worker maps onto the manager and its
subagents; the manager never delegates the top-level plan.

---

## Subagent task prompts

A subagent starts with no conversation, so its task is fully self-contained:

```text
# Target
The exact files or scope, and the explicit non-goals.

# Context
What is already true, what has already been done, what conventions apply.

# Change
The steps, the interfaces, the APIs — concrete enough to execute without a
follow-up question.

# Acceptance
The observable result that proves the task is done.
```

Four rules that decide whether a delegation works:

1. **No placeholders.** Every parameter named; no "as appropriate".
2. **Exclusive write-set.** State which files or subsystem the worker owns.
3. **Non-goals are stated.** The most common silent failure is a subagent
   doing the adjacent work nobody asked for.
4. **No inherited conversation.** Anything the worker needs is in the task.
