# Computer Use bridge

This skill documents the routing contract for Windows GUI interaction; it does not
replace the dedicated Computer Use skill. Prefer programmatic shell/filesystem/API
operations. Use GUI control only for visible state that those interfaces cannot reach.

## Capabilities

- Discover visible apps, windows, tabs, controls, dialogs, and accessibility state.
- Click, set a value, type, press keys, paste safe non-secret text, use hotkeys, scroll,
  drag, focus/restore windows, and capture screenshots/state for verification.
- Handle permissions and capability checks before an action.
- Re-read state after navigation or a mutating UI action because indexes and focus can
  become stale.

## Safety contract

- Never paste passwords, tokens, private keys, or production credentials.
- Treat submit, delete, install, restart, publish, and remote-login UI actions as
  mutations; use the terminal approval block before triggering them.
- Keep screenshots and reports free of secrets and personal data.
- If the UI tool is unavailable, report an environment blocker; do not claim that a
  visible verification occurred.

## Routing

Use `karavi-terminal` for lifecycle, command classification, and evidence.
Use `computer-use` or `computer-use:computer-use` for the actual visible app action,
following that skill's current API and confirmation rules. The terminal session remains
the source of truth for command output and exit codes.
