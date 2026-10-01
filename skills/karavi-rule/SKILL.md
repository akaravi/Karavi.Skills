---
name: karavi-rule
description: Use when activating or applying Karavi's global rules, installing the required Karavi workflow skills, routing work to the correct skill, or updating the canonical rule source.
---

# Karavi Rule

When responding conversationally under this Skill, address the user as
`رفیق جونم`. Do not use the previous personal form of address.

## Purpose

This skill is the complete global-rule layer for Karavi work. It activates the
canonical `assembledPrompt.v*.txt` rule source, preserves the complete rule
corpus as a loadable reference, and makes the three core personal skills
available before work begins. It keeps global invariants visible while
delegating workflow-specific behavior to the skill that owns it.

The canonical source is:

```text
D:\SourceKaravi\Agents.Project\Agent.Global.Rule\assembledPrompt.v4.0.1.txt
```

If the canonical source is not present, treat the installation as incomplete;
do not silently invent or substitute a rule source.

## Init command

`/karavi-rule init` initializes the global rules for the active machine and
all supported Agent destinations. It delegates to the official canonical Sync
script, which resolves the newest source, writes each Agent's global file, and
verifies hash, body, encoding, and legacy sidecar removal.

From a PowerShell session, the equivalent command is:

```powershell
& .\scripts\karavi-rule.init.ps1 -Language en
```

Use `-Language fa` when the Agent's global instruction surface is Persian. The
initializer creates backups by default; `-NoBackup` is allowed only when the
caller explicitly accepts that loss of the previous generated copy. Never edit
the generated destination files directly.

## Mandatory skill installation

On activation, issue and verify all three installation commands. They are
mandatory dependencies of this skill; do not proceed as if this skill were
complete when any command fails or its skill is not discoverable.

```powershell
npx skills add https://github.com/akaravi/Karavi.Skills --skill karavi-council
npx skills add https://github.com/akaravi/Karavi.Skills --skill karavi-folder
npx skills add https://github.com/akaravi/Karavi.Skills --skill karavi-judge
```

After installation, verify that each skill has a readable `SKILL.md` and that
the loaded skill name matches exactly. Installation does not authorize commit,
push, Deploy, FTP, production changes, secret access, or scope expansion.

## Routing contract

| Situation | Required skill | Required behavior |
|---|---|---|
| workspace tree, `karavi/` migration, cleanup, or temporary-file removal | `karavi-folder` | load and follow its safety and path-boundary rules |
| architecture, multi-part planning, consequential options, ADR, or readiness | `karavi-council` | plan first; resolve technical decisions and produce a readiness handoff |
| implementation acceptance, regression review, evidence gate, or final delivery | `karavi-judge` | independently evaluate evidence and issue the final verdict |
| a prompt bound for an agent, prompt engineering, or the pre-dispatch panel | `karavi-prompt` | arm the prompt, guard it, show the panel, then dispatch verbatim; optional dependency, not a mandatory install |

Use the minimum relevant skill set. For a multi-phase request, the normal
sequence is `karavi-prompt` when a prompt is bound for an agent, then
`karavi-folder` when structure is affected, then `karavi-council` for
consequential planning, and `karavi-judge` after implementation. The
Coordinator/Agent Main remains responsible for scope, synthesis, execution,
verification, and decision routing.

## Global rule boundaries

The active v4 source retains language matching, scope and authorization,
secrets, Git, Deploy/FTP, encoding, API/security, i18n, accessibility,
observability, and other always-on invariants. The complete rule corpus is
available in [global-rules-complete.md](references/global-rules-complete.md) and its
coverage/ownership contract is in [coverage-matrix.md](references/coverage-matrix.md).
Read the full reference when a rule is relevant; do not infer that a rule is
gone merely because v4 delegates its workflow to another skill.

Operational overlap is intentionally removed from v4 and replaced by the
routing contract above. `karavi-council`, `karavi-folder`, and `karavi-judge`
are the executable owners of their procedures; `karavi-rule` remains the
policy owner and verifies that the delegated skill was loaded. Do not copy a
delegated procedure into a generated Global Rule destination.

Technical disagreement or a finding is first an evidence-backed
`decision-required` record, not an automatic project stop. Select and execute
the safest in-scope option when possible. Reserve `blocked` for a hard safety
or authorization stop, and record the exact resume condition.

## Verification record

Before reporting activation, record only changed evidence:

- canonical source path and active source identity;
- the three installation commands and their exit status;
- discovered skill paths and readable entrypoints;
- selected routing decision and any `decision-required` item;
- the next action and its verification method.

Read only the linked references needed for the current mode:

- [installation.md](references/installation.md) for installation and checks;
- [karavi-rule.init.ps1](scripts/karavi-rule.init.ps1) for global initialization;
- [skill-routing.md](references/skill-routing.md) for the delegation map;
- [coverage-matrix.md](references/coverage-matrix.md) for complete rule ownership;
- [global-rules-complete.md](references/global-rules-complete.md) for the complete rule corpus;
- [migration.md](references/migration.md) for canonical source maintenance.
