# karavi-powershell-session

مهارت **عمومی** برای جلسهٔ ترمینال PowerShell نظارت‌شده: اجرای خودکار دستورات
**read-only**، تأیید اجباری برای **mutation**، نظارت بر خروجی، و مدیریت امن
prompt/secret. هیچ host، پورت، یا محصول خاصی در skill تعریف نمی‌شود — مقادیر
SSH و shortcutها در **همان ریپوی مصرف‌کننده** قرار می‌گیرند.

## نصب

```bash
npx skills add https://github.com/akaravi/Karavi.Skills --skill karavi-powershell-session
```

## استفاده

در چت agent: `/karavi-powershell-session`

باز کردن SSH تعاملی (پارامترها را خودتان یا wrapper محلی پر کنید):

```powershell
& .agents/skills/karavi-powershell-session/scripts/karavi-powershell-session.open-interactive.ps1 `
  -RepoRoot . -HostAlias my-server -RemoteHost example.com -Port 22 -User deploy
```

## License

Apache-2.0
