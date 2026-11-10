# Windows/IIS zero-lock deployment lifecycle

Use this reference only after the target is verified as Windows/IIS and the
Plesk repository directory has been read back. It is a procedure, not evidence
that a live server has been configured.

## Pre-merge hook

Create `<website-root>/.git/hooks/pre-merge-commit` with **LF** line endings:

```sh
#!/bin/sh
# Place IIS in offline maintenance mode to release locked DLL handles
echo "Updating application..." > app_offline.htm
sleep 2
```

Verify the file has no extension, is executable for the Git runtime, and is in
the repository's actual hooks directory. Do not put this hook in the source
repository or commit it as application code.

## Post-deployment cleanup

Configure the Plesk Additional deployment actions (or the equivalent verified
post-deployment step) with:

```bat
if exist app_offline.htm del /f /q app_offline.htm
```

The cleanup must run after successful deployment and in the configured failure
cleanup path. Never report the site online until a fresh read-back confirms the
file is absent.

## Controlled verification

1. Record the current deployment commit and application status.
2. Trigger a controlled merge/pull that actually creates a merge commit.
3. Verify `app_offline.htm` exists before overwrite, no DLL lock error occurs,
   the expected commit is deployed, and the file is deleted afterward.
4. Separately exercise a fast-forward pull. Because Git does not run
   `pre-merge-commit` for that path, require the Plesk pre-deployment action or
   wrapper to provide the same offline/cleanup lifecycle.

Keep command output and paths redacted in evidence. A webhook HTTP 204 only
proves that Plesk accepted the request; it does not prove this lifecycle ran.