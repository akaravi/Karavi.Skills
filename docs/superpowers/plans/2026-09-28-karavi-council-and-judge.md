# Plan: Karavi Council and Judge Skills

## Goal

Create two reusable skills in `skills/` and align the canonical Karavi global rule so technical agents decide and proceed autonomously inside scope without unnecessary Customer or 7Expert blocking.

## Scope

1. Create `karavi-council` as a planning and decision-council skill adapted from `project-council`.
2. Create `karavi-judge` as an evidence-based 7Expert/Judge completion-gate skill.
3. Add supporting references, README, and license files for both skills.
4. Update `assembledPrompt.v3.1.5.txt` in both Persian and English rule sections, then run the canonical sync script.
5. Validate frontmatter, references, line limits, encoding, diff whitespace, and pressure invariants.

## Acceptance criteria

- Both skill directories contain valid `SKILL.md` files with discoverable `Use when...` descriptions.
- Council explicitly stops before implementation and records assumptions, decisions, risks, spec, plan, and readiness.
- Judge always emits `accept|block|fail`, uses the seven-domain relevance mask, and does not block for advisory disagreement or low/medium findings alone.
- New-scope work is routed and reported, not silently executed or used as a default blocker.
- Global rule destinations are synchronized and hash-verified by the official script.
- No commit, push, deploy, or remote transfer is performed.

## Verification

- Validate each skill with the bundled quick validator when available.
- Run structural and pressure assertions for autonomy, severity thresholds, scope routing, verdicts, and references.
- Run `git diff --check` and read back all changed files as UTF-8 without BOM.
