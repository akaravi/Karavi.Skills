# Grounding and Context

Keeping the answer anchored to what was actually provided, and keeping the
context window small enough that the anchoring survives.

---

## Grounding

### Permission to abstain

One line, the highest-value line in the file:

```text
If the answer is not contained in the provided context, reply
"Not found in provided context". Do not guess.
```

### Quote-then-answer

Force retrieval before generation. The model copies the relevant sentences
first, then reasons only from what it copied.

```xml
<instructions>
Step 1: inside &lt;quotes&gt;, copy the exact sentences from the document
        that bear on the question. If none do, write "None found".
Step 2: inside &lt;answer&gt;, answer using only what you quoted.
        Introduce nothing that is not in your quotes.
</instructions>

<document>{{document_text}}</document>

<question>{{question}}</question>
```

The model can still cherry-pick quotes that support a conclusion it already
reached, so this reduces fabrication without eliminating motivated reasoning.
Pair it with source restriction.

### Source restriction

```text
Answer only from the documents above. Do not use prior knowledge and do not
infer beyond what they state. If they do not contain enough to answer, say so
explicitly rather than completing the gap.
```

### Citation

"For each claim, cite the document and section." Makes the output checkable and
discourages unsupported assertions.

### Self-verification

"Before responding, verify each factual claim against the source material.
Remove any claim you cannot substantiate."

### Confidence calibration

```text
Rate each answer 1 (uncertain, weak support) to 5 (certain, stated directly).
Below 3, prefix the answer with [LOW CONFIDENCE].
```

A rough triage signal, not a calibrated probability. Useful for routing
partial-knowledge answers to a human instead of presenting them as fact.

No technique removes hallucination. High-stakes output is validated outside
the model.

---

## Long context

**Documents first, question last.** The strong default for large inputs. The
exception is multi-criteria extraction, where naming the criteria before the
document helps the model know what to look for; test both when performance
matters.

**Label the documents.**

```xml
<documents>
  <document id="1" source="Q3 report">…</document>
  <document id="2" source="competitor analysis">…</document>
</documents>
```

**Lost in the middle.** Frontier models have reduced the effect, but the
mitigation is still correct and still matters for mid-tier and small models:
critical content at the top or bottom, never the middle.

**Rerank before injecting.** Embedding similarity is not relevance. If ten
chunks are retrieved and two or three matter, rerank and inject the top three
to five. Less noise, fewer tokens, less confident hallucination from an
irrelevant passage.

**For very long documents**, make the model scan first: "identify the section(s)
most relevant to the question, quote them in `<relevant_passages>`, then
answer."

**Chunking**, when content exceeds the window:

- Cut at natural boundaries — paragraphs, sections, logical units — not fixed
  character counts.
- Overlap the tail of chunk N with the head of chunk N+1 by roughly 100 tokens.
- Map-reduce: one extraction prompt per chunk, one synthesis prompt over the
  extractions.

---

## Context budget for agent prompts

| Content | In the prompt? |
|---|---|
| The deliverable and its acceptance | always |
| The agent's operating rules | always |
| The mode, scope, and boundaries | always |
| Tool and interface contracts | always |
| Repo structure, entry points, key files | as a project map, compressed |
| One file the task names | quoted, inside an untrusted tag |
| The whole subsystem | no — read it, with the path in the prompt |
| History of prior turns | summarized, and marked as ground truth |
| Anything the agent can read for itself | no — name the path instead |

A well-built project map replaces thousands of tokens of exploratory
glob/grep/read cycles. It carries: directory purpose in a few words, entry
points, the one-line data or request flow, and the three to five files worth
reading first. Skip build output, VCS internals, and dependency trees.

Summaries of prior context are lossy. For high-stakes work, extract the
specific facts verbatim into a structured block rather than paraphrasing them,
and mark the block: "This is a summary of prior work. Treat it as ground truth.
Do not contradict it."

---

## Context variables

Declare what the agent receives and what happens when a value is missing.

| Variable | Rule |
|---|---|
| required input | name it, describe it, and give the fallback: "request it and stop" |
| optional input | name the default and the behavior when it is absent |
| ambient context (`repo`, `workspace`, `selection`) | reference only when the task actually needs it |
| dynamic values (date, version, path) | inject at runtime; never hardcode |

A prompt that says "use the current date" and a prompt that hardcodes
2026-10-01 are the same prompt for one day and then diverge.

---

## Cache-aware ordering

Static prefix first, dynamic last. The system prompt, role, tool schemas,
examples, and reference documents are the prefix; the request is the suffix.
Never reorder between calls — a one-token prefix change invalidates the cache.

Grounding and caching pull in opposite directions: reference material improves
the answer and inflates the prefix. When calls are frequent, retrieve the
reference material instead of embedding it.

---

## Anti-drift

Long agent loops drift. Countermeasures, in order of leverage:

1. A structured state object per turn — task, steps completed, current step,
   findings — instead of raw history.
2. Re-assert the critical rules near the end of the system prompt.
3. Bound the loop: max steps, max tokens, a termination condition that is
   observable from outside.
4. A verification step before the final answer on anything consequential.
5. Test the system prompt at turn 50, not turn 1.
