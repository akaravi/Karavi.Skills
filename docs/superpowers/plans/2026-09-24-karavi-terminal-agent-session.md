# Karavi Terminal Agent-Controllable Session Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rename the terminal skill to `karavi-terminal` and enable an agent to control a persistent local PowerShell session by `sessionId`.

**Architecture:** A PowerShell module owns a private process, session metadata, capture files, locking, command markers, redaction, and cleanup. Thin public scripts call that module for open, invoke, status, and close; the interactive human-login script remains a distinct channel. The rename is complete across the skill folder, public documentation, repository indexes, scripts, references, and verifier.

**Tech Stack:** PowerShell 5.1+ / pwsh-compatible scripts, Pester when available, UTF-8 JSON metadata.

**Spec:** `docs/superpowers/specs/2026-09-24-karavi-terminal-agent-session-design.md`

## Global Constraints

- Public name and folder: `karavi-terminal`; the old name is not a public alias.
- Support only local `powershell.exe` or `pwsh.exe`; do not automate SSH passwords, MFA, or host trust.
- Never place secrets in parameters, state files, returned JSON, logs, or documentation examples.
- Read-only vs mutation approval policy remains unchanged; the controller is transport, not authorization.
- State is confined to `.cursor/karavi-terminal/`; cleanup never recursively removes `.cursor`.
- Return structured UTF-8 JSON and bounded, redacted command evidence.
- Preserve user interactive terminal guidance as a separate channel.

## Review Focus

- Concurrent invokes: only one command writes to a session stdin at a time and the lock is released after success, failure, or timeout.
- Command correlation: output from an earlier command is never returned for a later command.
- Process ownership: a forged or stale record cannot terminate a process it did not create.
- Native and PowerShell failures: each yields a non-success result with the correct signal instead of false success.
- Secret-shaped command output: results redact bearer tokens, connection strings, and private-key-like content before JSON serialization.

---

### Task 1: Rename the public skill surface

**Files:**
- Move: `skills/karavi-terminal-session/` → `skills/karavi-terminal/`
- Modify: `README.md`
- Modify: `skills/README.md`
- Modify: `skills/AGENTS.md`
- Modify: `skills/karavi-terminal/SKILL.md`
- Modify: `skills/karavi-terminal/README.md`
- Modify: all current references and script names containing `karavi-terminal-session`

**Interfaces:**
- Produces: discoverable public skill `/karavi-terminal`, folder `skills/karavi-terminal/`, and consistent references.

- [ ] **Step 1: Add a failing rename-contract test**

Create `skills/karavi-terminal/tests/karavi-terminal.rename.Tests.ps1` to assert that the new folder and `name: karavi-terminal` exist and the old folder/name have no remaining public occurrence.

- [ ] **Step 2: Run the rename-contract test to verify it fails**

Run: `Invoke-Pester skills/karavi-terminal/tests/karavi-terminal.rename.Tests.ps1 -Output Detailed`

Expected: FAIL because the old skill folder and front matter still exist.

- [ ] **Step 3: Rename the folder and public references**

Move the folder using a non-destructive git-aware move when tracked. Rename user-facing script filenames, update front matter, paths, install commands, markdown links, index entries, and verifier rules. Keep the interactive script’s channel boundary explicit.

- [ ] **Step 4: Re-run the rename-contract test**

Run: `Invoke-Pester skills/karavi-terminal/tests/karavi-terminal.rename.Tests.ps1 -Output Detailed`

Expected: PASS with no public occurrence of the old name.

### Task 2: Define and test the agent-session state contract

**Files:**
- Create: `skills/karavi-terminal/scripts/karavi-terminal.agent-session.psm1`
- Create: `skills/karavi-terminal/tests/karavi-terminal.agent-session.Tests.ps1`

**Interfaces:**
- Produces: module-private functions `New-KaraviTerminalSession`, `Get-KaraviTerminalSession`, `Invoke-KaraviTerminalCommand`, and `Close-KaraviTerminalSession`.
- Consumes: a repository root and safe local shell executable.

- [ ] **Step 1: Write failing lifecycle tests**

Write Pester tests that open a temporary-repository session and assert: a schema-versioned metadata file exists; `sessionId` is nonempty; PID is live; `status` is `ready`; and closing removes only state belonging to that session.

- [ ] **Step 2: Run lifecycle tests to verify they fail**

Run: `Invoke-Pester skills/karavi-terminal/tests/karavi-terminal.agent-session.Tests.ps1 -Output Detailed`

Expected: FAIL because the module and public lifecycle do not exist.

- [ ] **Step 3: Implement isolated metadata, validation, and ownership primitives**

Create the module with strict mode, schema version, generated session ID, private state directory, canonical path validation, atomic metadata write, PID start time ownership proof, status readback, and exact-session cleanup. Use redirected standard streams and never attach to an arbitrary PID.

- [ ] **Step 4: Re-run lifecycle tests**

Run: `Invoke-Pester skills/karavi-terminal/tests/karavi-terminal.agent-session.Tests.ps1 -Output Detailed`

Expected: PASS for open/status/close and scoped cleanup.

### Task 3: Implement command transport and result capture

**Files:**
- Modify: `skills/karavi-terminal/scripts/karavi-terminal.agent-session.psm1`
- Modify: `skills/karavi-terminal/tests/karavi-terminal.agent-session.Tests.ps1`

**Interfaces:**
- Produces: `Invoke-KaraviTerminalCommand -SessionId <string> -Command <string> -TimeoutSeconds <int>` returning `{ sessionId, commandId, status, stdout, stderr, nativeExitCode, powerShellSucceeded, timedOut }`.
- Consumes: a ready session created by Task 2.

- [ ] **Step 1: Write failing command-contract tests**

Add Pester tests that run two sequential local commands and prove they share the recorded process PID, return only their own output, return non-zero native exit correctly, surface a terminating PowerShell error, and report a bounded timeout as non-success.

- [ ] **Step 2: Run command-contract tests to verify they fail**

Run: `Invoke-Pester skills/karavi-terminal/tests/karavi-terminal.agent-session.Tests.ps1 -Output Detailed`

Expected: FAIL because no command transport or correlated capture exists.

- [ ] **Step 3: Implement marker protocol, lock, timeout, and bounded capture**

Use a per-session exclusive lock. Write unique begin/end JSON-safe markers through redirected stdin, read stdout/stderr incrementally from session-owned files, capture `$LASTEXITCODE` and `$?`, stop waiting at the timeout, and release the lock in `finally`. Preserve markers only internally; never emit them as user evidence.

- [ ] **Step 4: Re-run command-contract tests**

Run: `Invoke-Pester skills/karavi-terminal/tests/karavi-terminal.agent-session.Tests.ps1 -Output Detailed`

Expected: PASS for sequential isolation, error state, native exit, and timeout.

### Task 4: Expose scripts and enforce redaction

**Files:**
- Create: `skills/karavi-terminal/scripts/karavi-terminal.open-agent-session.ps1`
- Create: `skills/karavi-terminal/scripts/karavi-terminal.invoke-agent-command.ps1`
- Create: `skills/karavi-terminal/scripts/karavi-terminal.get-agent-session.ps1`
- Create: `skills/karavi-terminal/scripts/karavi-terminal.close-agent-session.ps1`
- Modify: `skills/karavi-terminal/scripts/karavi-terminal.agent-session.psm1`
- Modify: `skills/karavi-terminal/tests/karavi-terminal.agent-session.Tests.ps1`

**Interfaces:**
- Produces: JSON-only command-line entry points defined in the spec.

- [ ] **Step 1: Write failing public-script and redaction tests**

Add tests that call each public script, parse its stdout as JSON, verify invalid/missing sessions return a non-zero controller error, and verify representative bearer, connection-string, and private-key-shaped output is redacted.

- [ ] **Step 2: Run public-script tests to verify they fail**

Run: `Invoke-Pester skills/karavi-terminal/tests/karavi-terminal.agent-session.Tests.ps1 -Output Detailed`

Expected: FAIL because public scripts and result redaction do not exist.

- [ ] **Step 3: Implement thin JSON entry points and result redaction**

Make each script import the module, pass only typed declared inputs, serialize one JSON object to stdout, report controller errors to stderr with non-zero exit, and redact sensitive patterns before serialization. Add a maximum result length to avoid unbounded evidence.

- [ ] **Step 4: Re-run public-script tests**

Run: `Invoke-Pester skills/karavi-terminal/tests/karavi-terminal.agent-session.Tests.ps1 -Output Detailed`

Expected: PASS with parseable JSON, safe error behavior, and redaction.

### Task 5: Update the skill contract, references, and structural verifier

**Files:**
- Modify: `skills/karavi-terminal/SKILL.md`
- Modify: `skills/karavi-terminal/README.md`
- Modify: `skills/karavi-terminal/references/agent-terminals.md`
- Modify: `skills/karavi-terminal/references/session-lifecycle.md`
- Modify: `skills/karavi-terminal/references/verification-and-capture.md`
- Modify: `skills/karavi-terminal/references/windows-terminal.md`
- Modify: `skills/karavi-terminal/scripts/verify-terminal-skill.ps1`

**Interfaces:**
- Consumes: public script names and result schema from Tasks 2–4.
- Produces: discoverable guidance that distinguishes human interactive terminals from agent-controllable sessions.

- [ ] **Step 1: Add failing verifier expectations**

Extend the structural verifier to require the four public scripts, module, tests, new front matter, and UTF-8-without-BOM text. Assert that old public naming is absent.

- [ ] **Step 2: Run the verifier to verify it fails**

Run: `& skills/karavi-terminal/scripts/verify-terminal-skill.ps1 -SkillRoot (Resolve-Path skills/karavi-terminal)`

Expected: FAIL until files and documentation agree on the new contract.

- [ ] **Step 3: Document the operational contract**

Document local-only controller scope, ready/mutation policy, session command examples, status/close behavior, bounded redacted result semantics, timeout semantics, and the separation of user login from agent control. Keep `SKILL.md` concise and move detail to references.

- [ ] **Step 4: Re-run the verifier**

Run: `& skills/karavi-terminal/scripts/verify-terminal-skill.ps1 -SkillRoot (Resolve-Path skills/karavi-terminal)`

Expected: PASS with all required files, clean UTF-8, and no old public name.

### Task 6: Verify the integrated skill

**Files:**
- Modify if required by test evidence only: affected Task 1–5 files

**Interfaces:**
- Consumes: complete renamed skill and all public scripts.
- Produces: verified local agent-controllable terminal skill.

- [ ] **Step 1: Run the full Pester suite**

Run: `Invoke-Pester skills/karavi-terminal/tests -Output Detailed`

Expected: PASS with lifecycle, correlation, failure, timeout, cleanup, and redaction coverage.

- [ ] **Step 2: Run structural and encoding validation**

Run: `& skills/karavi-terminal/scripts/verify-terminal-skill.ps1 -SkillRoot (Resolve-Path skills/karavi-terminal); git diff --check`

Expected: PASS; no BOM, whitespace errors, or stale naming.

- [ ] **Step 3: Run a manual harmless smoke flow**

Run the public scripts in a temporary directory: open a session, invoke `$PID` and a deterministic stdout/stderr command, inspect status, close it, then verify its PID is no longer live and only session-owned state was removed.

Expected: every result is valid JSON, output is command-correlated, and the closed process is absent.

- [ ] **Step 4: Secret-scan the changed files**

Run: `rg -n -i --glob '!*.lock' '(AKIA[0-9A-Z]{16}|ghp_[A-Za-z0-9]+|sk-[A-Za-z0-9]+|xoxb-[A-Za-z0-9]+|password\s*=|bearer\s+[A-Za-z0-9._-]+|connection\s*string\s*=)' -- README.md skills docs`

Expected: no exposed secret values; documented redaction patterns and placeholders are reviewed manually.
