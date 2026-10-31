# karavi-terminal

مهارت **عمومی و مستقل** برای مدیریت جلسات ترمینال نظارت‌شده در Windows و شل‌های محلی/راه‌دور: PowerShell Core / 5.1، Windows Terminal، SSH، WSL، Orca و ابزارهای مانیتورینگ.

این مهارت دو اصل محوری دارد:
1. **اجرای خودکار و بدون وقفهٔ دستورات Read-Only** (کسب شواهد، مانیتورینگ، وضعیت سرویس‌ها، بررسی پورت‌ها).
2. **الزام تأیید صریح کاربر برای هرگونه Mutation** (دستکاری فایل‌ها، تغییر تنظیمات، استاپ/استارت سرویس، گیت، شبکه و دیتابیس).

هیچ هاست، پورت، سکرت یا نام سرور خاصی در این skill هاردکد نشده است؛ پارامترها و کانفیگ‌ها در همان ریپوی مصرف‌کننده نگهداری می‌شوند.

---

## ۱. پیش‌نیاز و انتخاب کانال

ابتدا [SKILL.md](SKILL.md) و قوانین ریپوی مصرف‌کننده را بخوانید. این مهارت برای جلسهٔ زندهٔ نظارت‌شده است، نه صرفاً ویرایش کد یا جایگزین `karavi-folder`.

- برای اسکریپت‌های محلی، Windows و PowerShell قابل اجرا لازم است؛ نشست ایجنت به‌صورت پیش‌فرض `pwsh.exe` را باز می‌کند و می‌توان `-Shell powershell.exe` داد.
- ConPTY به Windows دارای API شبه‌کنسول نیاز دارد؛ نصب `node-pty` لازم نیست. شل یا برنامهٔ مقصد باید از قبل موجود باشد.
- SSH/WSL/Windows Terminal فقط برای سناریوی مربوط لازم‌اند. میزبان، پورت، حساب و احراز هویت باید از کاربر یا تنظیمات همان پروژه بیایند.
- PID پنجرهٔ کاربر کانال کنترل ایجنت نیست؛ ورود کاربر در آن پنجره، احراز هویت شل جداگانهٔ ایجنت را تضمین نمی‌کند.

مثال‌های زیر از **ریشهٔ همین مخزن** هستند؛ پس از نصب، مسیر `$scripts` را به پوشهٔ واقعی skill تغییر دهید و `-RepoRoot` را همچنان به ریپوی هدف بدهید.

| اسکریپت در `scripts/` | کاربرد و پارامتر مهم |
|---|---|
| `karavi-terminal.open-interactive.ps1` | پنجرهٔ SSH تعاملی؛ هر دو مقدار `-RemoteHost` و `-User` لازم‌اند؛ `-RepoRoot`, `-HostAlias`, `-Port`, `-WhatIf`؛ این helper حالت local-only ندارد |
| `karavi-terminal.open-agent-session.ps1` | نشست پایدار؛ `-RepoRoot`, `-Shell`؛ شناسه توسط اسکریپت تولید می‌شود |
| `karavi-terminal.invoke-agent-command.ps1` | یک دستور؛ `-SessionId`, `-Command`, `-TimeoutSeconds` |
| `karavi-terminal.get-agent-session.ps1` / `karavi-terminal.close-agent-session.ps1` | فهرست نشست‌های زنده / بستن نشست متعلق به رجیستری |
| `karavi-terminal.agent-sanity.ps1` | گزارش شل، نسخه، مسیر و encoding |
| `karavi-terminal.pty-launch.ps1` | ConPTY؛ `-Command`, `-ArgumentList`, `-WorkingDirectory`, `-Columns`, `-Rows` |
| `karavi-terminal.pty-send-keys.ps1` | `-RepoRoot`, `-SessionId`, `-Keys`؛ Enter با `\r` |
| `karavi-terminal.pty-wait.ps1` | انتظار برای پایدارشدن خروجی با `-TimeoutMs`؛ نه انتظار regex |
| `karavi-terminal.pty-screenshot.ps1` / `karavi-terminal.pty-list.ps1` | صفحهٔ ASCII / فهرست نشست‌ها |
| `karavi-terminal.pty-resize.ps1` / `karavi-terminal.pty-close.ps1` | تغییر ابعاد / بستن نشست با `-RepoRoot`, `-SessionId` |
| `karavi-terminal.pty-close-host.ps1` | بستن میزبان و تمام نشست‌های همان ریپو |
| `verify-karavi-terminal-skill.ps1` | بررسی ساختار و BOM با `-SkillRoot` اختیاری |

---

## ۲. مدل مجوز و تفکیک دستورات (Permission Model)

### دستورات Read-Only (اجرا بدون توقف و بدون نیاز به تأیید)
ایجنت این دستورات را مستقیماً برای کشف اطلاعات، خواندن لاگ و ارزیابی شواهد اجرا می‌کند:
- بررسی پروسه‌ها و سرویس‌ها: `Get-Process`, `Get-Service`, `ps`, `systemctl status`
- شبکه و پورت: `Test-NetConnection -Port 5060`, `ping`, `ss -tulpn`, `nslookup`
- بررسی فایل و محتوا: `Get-ChildItem`, `Get-Content` (همراه با ماسک کردن سکرت‌ها), `Select-String`, `git status`, `git log`
- کانتینرها: `docker ps`, `docker logs --tail 100`, `kubectl get pods`

### دستورات Mutation (نیاز به فرمت تأیید صریح)
هر دستوری که دارای اثر جانبی، تغییر وضعیت یا نوشتن باشد باید قبل از اجرا در کادر تأیید به کاربر عرضه شود:

```text
[درخواست اجرا — MUTATION]
دسته: تغییر وضعیت سرویس
دستور: Stop-Service -Name "TelephonyService" -Force
cwd: <مسیر تأییدشده>
ریسک: قطع سرویس تماس‌های ورودی
اثر برگشت‌ناپذیر: خیر
تأیید: «اجرا کن» / «نه» / «اصلاح: ...»
```

### دستورات کاملاً ممنوع بدون Override اختصاصی
- پاک‌سازی دیسک یا پارتیشن: `format`, `diskpart`, `rm -rf /`
- فورس پوش و ریست مخرب در گیت: `git push --force`, `git reset --hard`
- ارسال سکرت و توکن در بدنه کامندهای شل یا لاگ‌ها

---

## ۳. مثال‌های واقعی و سناریوهای کاربردی (Practical Scenarios)

### سناریو ۱: آغاز محلی و نشست ایجنت

```powershell
$repo = (Get-Location).Path
$scripts = Join-Path $repo 'skills/karavi-terminal/scripts'
& "$scripts/karavi-terminal.agent-sanity.ps1"

# فقط پس از تأیید ایجاد نشست؛ این عملیات فایل و فرآیند ایجاد می‌کند
$session = & "$scripts/karavi-terminal.open-agent-session.ps1" -RepoRoot $repo | ConvertFrom-Json
& "$scripts/karavi-terminal.invoke-agent-command.ps1" -RepoRoot $repo `
  -SessionId $session.sessionId -Command 'Get-Location' -TimeoutSeconds 30

# بستن فرآیند نیز نیازمند مجوز است
& "$scripts/karavi-terminal.close-agent-session.ps1" -RepoRoot $repo -SessionId $session.sessionId
```

برای SSH تعاملی، کاربر یا ایجنتِ دارای مجوز `open-interactive` را با پارامترهای پروژه اجرا می‌کند. کاربر شخصاً login می‌کند و `ready` می‌فرستد. تا قبل از آن فقط sanity محلی Read-Only انجام دهید؛ اتصال غیرتعاملی از پیش پیکربندی‌شده باید صریحاً مشخص باشد.

### سناریو ۲: ConPTY و کنسول Asterisk در WSL

فقط اگر WSL و Asterisk نصب و محیط مجاز مشخص است؛ launch، ارسال کلید و close هرکدام Mutation هستند و تأیید لازم دارند:

```powershell
$pty = & "$scripts/karavi-terminal.pty-launch.ps1" -RepoRoot $repo `
  -Command 'wsl.exe' -ArgumentList @('asterisk', '-rvvv') | ConvertFrom-Json
& "$scripts/karavi-terminal.pty-wait.ps1" -RepoRoot $repo -SessionId $pty.sessionId -TimeoutMs 1000
& "$scripts/karavi-terminal.pty-send-keys.ps1" -RepoRoot $repo `
  -SessionId $pty.sessionId -Keys 'pjsip show endpoints\r'
& "$scripts/karavi-terminal.pty-screenshot.ps1" -RepoRoot $repo -SessionId $pty.sessionId
& "$scripts/karavi-terminal.pty-close.ps1" -RepoRoot $repo -SessionId $pty.sessionId
```

`WorkingDirectory` باید داخل ریپوی هدف باشد؛ حداکثر ۲۰ نشست، عرض ۲۰ تا ۵۰۰، ارتفاع ۵ تا ۲۰۰ و حداکثر ۱۰۰۰۰ کاراکتر ورودی پشتیبانی می‌شود. صفحهٔ بازگشتی محدود و redact شده است؛ این فیلتر تضمین حذف همهٔ سکرت‌ها نیست.

### سناریو ۳: تشخیص Read-Only و پیش‌نمایش تغییر

`Test-NetConnection -ComputerName 127.0.0.1 -Port 5060` فقط اتصال **TCP** را می‌سنجد، نه ثبت SIP روی UDP یا سلامت RTP. برای پیش‌نمایش حذف، `Remove-Item -Path 'karavi/karavi.temp.logs/*' -Recurse -WhatIf` را فقط در محدودهٔ مجاز به‌کار ببرید؛ پیش‌نمایش مجوز حذف واقعی نیست.

---

## ۴. نصب و راه‌اندازی (Installation)

```bash
pnpm dlx skills add https://github.com/akaravi/Karavi.Skills --skill karavi-terminal
```

فراخوانی در چت با ایجنت:
```text
/karavi-terminal
```

نصب به Node.js و `pnpm` موجود نیاز دارد و کاتالوگ محلی را تغییر می‌دهد؛ فقط در scope مجاز اجرا شود. این دستور SSH، WSL یا runtime سیستم را نصب نمی‌کند. پس از نصب، مسیر واقعی، frontmatter و لینک‌ها را بررسی کنید؛ [راهنمای نصب و کشف](references/discovery-and-install.md) را ببینید.

## خروجی و ارزیابی

- نشست ایجنت JSON شامل `sessionId`, PID و مسیر دارد. نتیجهٔ دستور شامل `stdout`, `stderr`, `nativeExitCode`, `powerShellSucceeded`, `timedOut` و شناسهٔ دستور است؛ صرف `status=completed` دلیل موفقیت برنامهٔ native نیست.
- رجیستری در `karavi.temp.status/karavi-terminal-sessions.json` و wrapperها در `.cursor/karavi-terminal/` ساخته می‌شوند. رجیستری با PID **و زمان شروع فرآیند** تطبیق داده می‌شود؛ حتی فهرست‌گیری ایجنت ممکن است رجیستری را بازنویسی کند.
- میزبان ConPTY یک فرآیند برای هر ریپو و رکورد `karavi.temp.status/karavi-terminal-pty-host.json` دارد؛ توقف میزبان همهٔ نشست‌هایش را متوقف می‌کند. درخواست‌های PTY ممکن است میزبان محلی را راه‌اندازی کنند؛ Read-Only بودن screenshot ناظر به برنامهٔ هدف است، نه تضمین نبودن اثر محلی.
- timeout انتظار پاسخ، اثبات لغو دستور نیست؛ پیش از تکرار Mutation وضعیت واقعی را بررسی کنید. خروجی خام نشست ایجنت را پیش از انتشار redact کنید.

بررسی ساختاری زیر از ریشهٔ مخزن قابل اجراست؛ موفقیت آن فقط ساختار، نام‌ها و نبود BOM را می‌سنجد، نه SSH، ConPTY یا یک سرور زنده:

```powershell
& .\skills\karavi-terminal\scripts\verify-karavi-terminal-skill.ps1
```

در جلسهٔ واقعی shell/cwd/version/encoding، کانال ورود، مجوز هر تغییر، exit code و شواهد ماسک‌شده را ثبت کنید. تست‌های رگرسیون در [نشست ایجنت](tests/karavi-terminal.agent-session.Tests.ps1) و [ConPTY](tests/karavi-terminal.pty.Tests.ps1) هستند؛ این README ادعای اجرای آن‌ها ندارد.

---

## ۵. منابع تکمیلی (References)

- [`references/permission-model.md`](references/permission-model.md) — قواعد سخت‌گیرانه مرز Read-Only در برابر Mutation
- [`references/command-classification.md`](references/command-classification.md) — دسته‌بندی و چک‌لیست تمام دستورات شل
- [`references/pty-sessions.md`](references/pty-sessions.md) — جزئیات فنی پروتکل PTY و مانیتورینگ خروجی
- [`references/examples.md`](references/examples.md) — نمونه‌های تکمیلی JSON envelope و پوشش خروجی‌ها
- [`references/orca-terminal.md`](references/orca-terminal.md) — یکپارچه‌سازی با ترمینال محیط Orca
- [چرخهٔ نشست](references/session-lifecycle.md)، [کانال کاربر و ایجنت](references/agent-terminals.md) و [ثبت شواهد](references/verification-and-capture.md)
- [PowerShell](references/powershell-core.md)، [Windows Terminal](references/windows-terminal.md)، [Windows DevOps](references/windows-devops.md)
- [Computer Use](references/computer-use-bridge.md) و [یکپارچه‌سازی Karavi](references/karavi-integration.md)

---

## ۶. License

[Apache-2.0](LICENSE)
