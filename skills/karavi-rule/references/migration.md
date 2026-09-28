# Canonical rule maintenance

The file under `D:\SourceKaravi\Agents.Project\Agent.Global.Rule\assembledPrompt.v*.txt`
is the canonical source. When it is updated, refresh the complete rule corpus
and the coverage matrix in this Skill, then run the official Sync script.

The active source keeps global invariants and the mandatory routing contract.
Planning, workspace operations, and independent acceptance remain procedure
responsibilities of `karavi-council`, `karavi-folder`, and `karavi-judge`.

Never delete a rule silently. If a rule is absent from the active source, keep
its complete text in `references/global-rules-complete.md`, assign an owner in
`references/coverage-matrix.md`, and record the trigger, evidence, and
verifyMethod. Update generated destinations only through
`Global.Rule/Main/sync-global-rules.ps1`.
