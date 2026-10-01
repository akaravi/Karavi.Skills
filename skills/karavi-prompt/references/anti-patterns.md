# Anti-Patterns

The defect catalog. Each entry: what it looks like, why it fails, and the fix.
Run this scan before arming.

---

## Structural

**1. Wall of text** — 200 lines, no boundaries.
*Fails:* attention follows position and salience; mid-prompt rules get the least.
*Fix:* XML tags for complex prompts, markdown headers otherwise.

**2. Instructions scattered across sections** — the same policy in identity,
rules, and examples, worded differently each time.
*Fails:* the model follows whichever version it happens to attend to.
*Fix:* state once, reference the location from elsewhere.

**3. Critical instructions buried late** — safety and format rules after a long
knowledge section.
*Fails:* primacy and recency both work against the middle.
*Fix:* critical rules in the first 30%; mark them `CRITICAL:`.

**4. Monolithic prompt for multiple tasks** — support, sales, and onboarding in
one file.
*Fails:* every request pays for every unrelated section.
*Fix:* split, or route by classification at the application layer.

---

## Clarity

**5. Vague platitudes** — "Be helpful, accurate, and concise."
*Fails:* every model is already trying to be helpful. Zero behavioral delta.
*Fix:* "Answer in 2–3 sentences unless detail is asked. Cite a source for every
statistic."

**6. Undefined qualifiers** — "appropriate", "relevant", "as needed", "timely".
*Fails:* the model applies its training distribution, not your intent.
*Fix:* define the measure. "Under 100 words." "Formal English, no slang."

**7. Compound instructions** — "Be concise and cite sources and stay under 200
words and avoid jargon unless the user is a developer."
*Fails:* each clause gets less attention, and the trailing condition may not
apply to all of them.
*Fix:* one instruction per line, conditions attached to their own instruction.

**8. Instruction by implication** — an example of a short answer, hoping the
length rule is inferred.
*Fails:* examples demonstrate; they do not define.
*Fix:* state the rule, then optionally add the example.

---

## Constraints

**9. Absolute bans without scope** — "NEVER discuss politics."
*Fails:* refuses "What is the European Parliament?". Over-refusal costs more
trust than under-refusal.
*Fix:* "Do not express political opinions or endorse candidates. You may explain
political systems, processes, and history factually."

**10. Enumerated ban lists** — 50 topics, 30 phrases, 20 behaviors.
*Fails:* impossible to complete; the 51st gets through. Burns tokens and
attention.
*Fix:* one meta-rule covering the category.

**11. Conflicting instructions** — "Always cite sources" plus "Under 50 words".
*Fails:* a cited answer with links runs 80+ words; one rule must break.
*Fix:* priority order, or "the citation does not count toward the limit".

**12. Safety by omission** — nothing written, hoping built-in safety covers it.
*Fails:* default safety varies by model and version; your risks are not its
risks.
*Fix:* write the rules for this use case.

---

## Tokens

**13. Redundant preambles** — "In your capacity as an advanced AI language
model…".
*Fails:* 20 tokens, zero meaning.
*Fix:* "You are {role}. You {function}." Ten words.

**14. Saying it three ways** — "Be concise. Keep responses short. Don't use
unnecessary words."
*Fails:* wastes tokens and creates ambiguity about which phrasing governs.
*Fix:* one precise instruction with a number.

**15. Over-explained concepts** — narrating the model's own thought process back
to it.
*Fails:* it already does this.
*Fix:* cut to the behavior. "Search before making a factual claim."

**16. Excessive examples** — ten examples for one task.
*Fails:* 500–2000 tokens of context competing with the instructions.
*Fix:* 1–2 for ambiguity, 0 for the obvious. Needing ten means the instruction
is unclear.

---

## Reliability

**17. No grounding** — factual questions with no uncertainty or boundary rule.
*Fails:* confident, plausible, wrong.
*Fix:* cutoff, "say you don't know", verify-before-asserting.

**18. "Think step by step" as the architecture** — CoT standing in for a plan.
*Fails:* CoT improves reasoning but does not constrain it; steps get skipped or
invented.
*Fix:* name the steps. "Identify intent → check sources → draft → verify."

**19. Only the happy path** — no out-of-scope, ambiguous, missing, or
adversarial branch.
*Fails:* the model improvises all four, badly.
*Fix:* define what to *do* in each case.

**20. Assuming capabilities** — "check the internet" to a model with no web
access.
*Fails:* fabricated results, or a confusing refusal.
*Fix:* list real capabilities in the context layer; reference only those.

---

## Persona

**21. Persona without boundaries** — "Always respond in pirate speak."
*Fails:* error messages, safety notices, and code all arrive as pirate prose.
*Fix:* "Pirate voice for conversation only; standard English for errors,
technical content, and safety notices."

**22. Adjectives instead of behaviors** — "You are friendly, professional, and
empathetic."
*Fails:* adjectives are not instructions.
*Fix:* the behaviors. "Greet by name when known. Acknowledge the frustration
before solving it. No slang, but not stiff."

**23. Backstory as instruction** — "You were created in 2019 and love solving
problems."
*Fails:* not instruction, and the model does not become someone because of it.
*Fix:* cut; define the behavior you actually want.

---

## Output

**24. No format specification** — the prompt says what to answer, not how.
*Fails:* the model defaults to its training distribution, which varies by model,
version, and even between requests.
*Fix:* state the format, including what to omit.

**25. "Be concise" without a metric** — concise is relative.
*Fails:* the model picks its own threshold.
*Fix:* "under 100 words", or "1–3 sentences for factual, up to 2 paragraphs for
explanations".

**26. Format conflicts with content** — "always valid JSON" plus "start with a
friendly greeting".
*Fails:* a greeting is not valid JSON.
*Fix:* make them compatible; wrap the greeting in a schema field.

---

## Meta

**27. Prompt as legal document** — subclauses and exceptions to exceptions.
*Fails:* legal precision leans on shared human conventions models do not fully
internalize, so it introduces ambiguity rather than removing it.
*Fix:* "Do X when Y", not "notwithstanding any prior instruction, in the event
that…".

**28. Prompt as employee handbook** — 2000 lines covering every exception.
*Fails:* past ~500 lines the model cannot attend to all of it at once.
*Fix:* core rules inline, the rest retrieved on demand.

**29. Copy-pasted across models** — the same text for every model.
*Fails:* each model attends to structure differently. See the class table in
[optimization-playbook.md](optimization-playbook.md).
*Fix:* a shared core plus per-model adaptation, tested on each.

**30. Never revised** — written once and never revisited.
*Fails:* a prompt is a hypothesis about model behavior; production traffic and
model upgrades both invalidate it.
*Fix:* treat it as code. Version it, log outcomes, re-score on upgrade.

---

## Arming-specific

**31. Unfilled placeholder in a dispatched prompt** — `[paste code here]`,
`{topic}`, `<your_input>`, `___`.
*Fails:* the user pastes, nothing happens, the round trip is wasted.
*Fix:* Case A bakes the real content in. Case B makes the prompt ask for what
it needs as step 1. Templates in `templates.md` are for authoring, not for
dispatch.

**32. Arming delta of zero** — the armed text equals the raw text.
*Fails:* the pipeline ran and changed nothing; the guard raises `ARM_DELTA`.
*Fix:* state in the notes what engineering was applied, or do not claim a run.

**33. Panel shown after dispatch** — the box appears as a report.
*Fails:* the user never got the choice.
*Fix:* the panel is a gate, not a receipt.

**34. Over-engineered arming** — seven layers and eleven techniques for a
one-line request.
*Fails:* structure that exceeds the task is noise, and the SIZE delta exposes it.
*Fix:* proportionality. A trivial raw prompt gets a trivial armed prompt, and
the panel says so with `SIZE: raw → armed` nearly equal.

**35. Untrusted content concatenated inline** — a file body pasted into the
instruction text.
*Fails:* file content that says "ignore previous instructions" is now an
instruction.
*Fix:* labeled tag, declared data-only, scanned by `INJECTION` and `TAINT`.
