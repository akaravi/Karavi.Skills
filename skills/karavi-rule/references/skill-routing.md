# v3 to v4 skill-routing map

v4 keeps rules that are global invariants and delegates workflow procedures to
the personal skills below. Delegation is a required route, not duplicated text.

| v3 capability | v4 owner | Route condition |
|---|---|---|
| folder initialization, migration, cleanup, and temporary-file boundaries | `karavi-folder` | the request changes workspace structure or removes temporary data |
| council phases, seats, option analysis, ADR, specification, and readiness | `karavi-council` | the request has consequential architecture, multiple parts, or an unclear implementation path |
| independent acceptance, evidence review, failure scenario, and final verdict | `karavi-judge` | implementation or a delivery claim needs an acceptance gate |
| language, scope, secrets, authorization, Git, Deploy/FTP, encoding, API, security, i18n, accessibility, and observability invariants | `karavi-rule` plus v4 source | always active when the rule applies |

The coordinator reads only the selected skill's entrypoint and the references
needed for the current mode. It records `skillsInvoked` with name, role, and
evidence once. Missing optional tooling is degraded, not fabricated. Technical
disagreement becomes a decision packet with evidence, options, trade-offs,
selected option, owner, action, verification, and residual risk.

The three mandatory skills are installed together, but not every workflow runs
every skill. This preserves cost control and prevents a planning-only request
from being treated as an implementation acceptance.
