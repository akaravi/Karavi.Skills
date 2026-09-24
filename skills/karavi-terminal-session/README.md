# karavi-terminal-session

مهارت **عمومی** برای جلسهٔ ترمینال نظارت‌شده در Windows و shellهای راه‌دور: PowerShell،
Windows Terminal، SSH، WSL، Orca و کنترل برنامه‌های قابل‌مشاهده. اجرای دستورات
**read-only** بدون تأیید، تأیید اجباری برای **mutation**، ثبت خروجی و مدیریت امن
prompt/secret را پوشش می‌دهد. هیچ host، پورت، یا محصول خاصی در skill تعریف نمی‌شود — مقادیر
SSH و shortcutها در **همان ریپوی مصرف‌کننده** قرار می‌گیرند.

## نصب

```bash
npx skills add https://github.com/akaravi/Karavi.Skills --skill karavi-terminal-session
```

## استفاده

در چت agent: `/karavi-terminal-session`

باز کردن SSH تعاملی (پارامترها را خودتان یا wrapper محلی پر کنید):

```powershell
& .agents/skills/karavi-terminal-session/scripts/karavi-terminal-session.open-interactive.ps1 `
  -RepoRoot . -HostAlias my-server -RemoteHost example.com -Port 22 -User deploy
```

## License

Apache-2.0
