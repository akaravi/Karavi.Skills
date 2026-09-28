# Host Adapter Contract

Only the Chair varies by harness. Principal and Adversary remain independent
read-only processes when the host supports them.

| Capability | Required behavior |
|---|---|
| File writes | Chair writes every artifact using the host's safe edit tool |
| Shell | Chair can run bounded commands and wait for seat output |
| Read-back | Chair reads and verifies every generated artifact |
| Persistence | Chair can continue turns or resume from `_state.md` |
| Rules | Chair loads the target repository's rules before Phase 0 |

If any capability is missing, state the limitation before starting and classify
the run as blocked or degraded according to risk. A different harness may
continue from the same artifact directory because artifacts, not context, are
the state.

The target repository's `AGENTS.md`, `CLAUDE.md`, project rules, security policy,
and explicit user instructions outrank this adapter. The plan may mention a
project-specific execution skill, but must not require a skill unavailable to
the future executor.
