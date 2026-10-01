# Evaluation and Scoring

How an armed prompt is scored before dispatch, and how runs become an eval set
that makes the next arming better.

---

## The 8-dimension rubric

Score each dimension 1–5, then take the weighted average.

| Dimension | Weight | 1 | 3 | 5 |
|---|---|---|---|---|
| Clarity | 15% | several instructions have two valid readings | mostly clear, a few vague spots | every instruction has exactly one reading |
| Specificity | 15% | platitudes only | key behaviors defined, secondary left to defaults | every behavior maps a condition to an action |
| Constraint quality | 15% | missing or self-contradictory | present, mostly scoped, one or two gaps | scoped, non-conflicting, meta-rules where needed, precedence stated |
| Grounding | 10% | none — free to fabricate | boundaries plus "say you don't know" | boundaries, uncertainty language, verification, citations, post-cutoff handling |
| Token efficiency | 10% | heavy redundancy, filler everywhere | some waste, mostly lean | every token earns its place |
| Maintainability | 10% | monolithic, hardcoded, no structure | organized but coupled | modular, parameterized, safely editable |
| Robustness | 15% | happy path only | common cases handled | edge, adversarial, conflicting, and missing-context all defined |
| Structure | 10% | no sections at all | sections, inconsistent | layered and navigable |

```text
Overall = Clarity·.15 + Specificity·.15 + Constraints·.15 + Grounding·.10
        + Efficiency·.10 + Maintainability·.10 + Robustness·.15 + Structure·.10
```

| Grade | Range | Meaning |
|---|---|---|
| A | 4.5–5.0 | ship |
| B | 3.5–4.4 | ship, note the weak dimension |
| C | 2.5–3.4 | fix the named dimensions, then re-arm |
| D | 1.5–2.4 | rework |
| F | < 1.5 | redesign |

**Dispatch rule:** any dimension below 3 blocks the run. Everything else is a
finding to report, not a reason to hold the line.

For every dimension under 4, write three lines: what is wrong (with the quote
or section), the concrete failure it causes, and the specific rewrite.

---

## Checklist pass

Run before scoring; each failure maps to a dimension.

**Structure** — clear section boundaries; logical order; critical instructions
in the first 30%; related instructions grouped, not scattered.

**Clarity** — no undefined qualifiers; one reading per instruction; conditions
stated on their own instruction; no compound sentences; no undefined domain
terms.

**Constraints** — scoped, not absolute unless safety-critical; every
prohibition paired with a permission; no two in conflict; out-of-scope handled;
precedence stated.

**Grounding** — knowledge boundary stated; uncertainty handled; verification
step present; no encouragement to guess; claims have a mechanism behind them.

**Tokens** — no rule restated in different words; no filler; examples that are
load-bearing; nothing over-explained that the model already knows.

**Robustness** — out-of-scope, ambiguous, missing-context, adversarial, and
empty inputs each have a defined response.

**Output** — format explicit; an example where the format is non-trivial;
format compatible with the content; length guidance with a number.

**Maintainability** — no hardcoded dates, versions, or URLs; dynamic values
parameterized; modular sections; editable by someone who is not its author.

---

## Eval sets

An eval set replaces "try it a few times and eyeball it" with a reusable
artifact. Store it next to the prompt; it is part of the prompt's
specification.

**Build it:**

- 10–30 cases to start.
- 60–70% the common case, 20–30% known edge cases, 10% adversarial or malformed.
- Real production inputs, not invented toy cases — synthetic cases miss the
  distribution.
- Expected output at one of three levels: **exact match** for extraction and
  classification; **criteria-based** (a checklist — "contains a date", "no
  hallucinated entity") for generation; **comparative** (preferred over a
  baseline by a human or an LLM judge) for open-ended output.

**Grow it:** every production failure enters the set with the correct expected
output. The set is fed by the ledger — a run closed `fail` or `needs-review`
contributes its raw prompt.

**Prune it:** quarterly, drop cases that no longer represent real traffic.

---

## Metrics by task type

| Task | Metrics |
|---|---|
| Classification | accuracy, per-class precision and recall, confusion matrix; aggregate accuracy hides rare-class failure |
| Extraction | field-level exact match, F1; partial credit is signal |
| Factual generation | factual accuracy, hallucination rate, citation coverage |
| Open generation | human preference ranking, LLM judge against an explicit rubric |
| Agent / tool use | tool-selection accuracy, task completion rate, steps to completion, error-recovery rate |

### LLM as judge

Give the judge the rubric explicitly. "Is this good?" is not a metric.

```text
You are grading a response.

<criteria>
1. Factual accuracy: every claim is supported by the source (1-5)
2. Completeness: every part of the question is addressed (1-5)
3. Format compliance: output matches the required schema (pass | fail)
</criteria>

<source>{{source}}</source>
<question>{{question}}</question>
<response>{{response}}</response>

Score each criterion. Output JSON:
{"accuracy": int, "completeness": int, "format": "pass"|"fail", "issues": ["…"]}
```

---

## A/B comparison

Iterating without measurement is guessing. To compare a candidate armed prompt
against the current one:

1. Run both against every eval input.
2. Score both with the same metric or judge.
3. Compare aggregates **and** read the cases where they diverge.
4. A prompt that improves the average while regressing on three specific
   inputs has introduced a new failure mode. Investigate before shipping.

With 10–30 cases, do not over-read a two-point swing — that is one example
changing. Read the diverging cases, not the number.

---

## Regression on model change

A model upgrade silently changes behavior. On any model change:

1. Re-run the full eval set; compare against the last known-good baseline.
2. Investigate every regression — it points at phrasing that leaned on a
   model-specific habit rather than a clear instruction.
3. Fix by tightening the prompt, not by reverting the model. Reverting breaks
   again on the next upgrade.
4. Update the baseline after the fix.

---

## Production monitoring

| Signal | Watches for |
|---|---|
| format compliance rate | drift, new input shapes |
| latency and token usage per run | looping, padding, a reasoning change |
| outcome distribution from the ledger | `fail` and `needs-review` clustering |
| input drift | traffic leaving the eval set's distribution — update the set |
| periodic fact spot-check | claims no longer matching sources |

---

## The ledger loop

```text
run armed → guard → panel → dispatch → close with outcome + score
                                              │
                    failing raw prompt ───────┘
                              │
                          eval set
                              │
                        next arming
```

A run that is never closed cannot teach the next one anything. Closing with
`fail` and the failing dimension is the highest-value entry in the ledger, and
it is the only part of this skill that compounds.
