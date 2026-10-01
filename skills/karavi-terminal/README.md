# karavi-terminal

مهارت **عمومی و مستقل** برای مدیریت جلسات ترمینال نظارت‌شده در Windows و شل‌های محلی/راه‌دور: PowerShell Core / 5.1، Windows Terminal، SSH، WSL، Orca و ابزارهای مانیتورینگ.

این مهارت دو اصل محوری دارد:
1. **اجرای خودکار و بدون وقفهٔ دستورات Read-Only** (کسب شواهد، مانیتورینگ، وضعیت سرویس‌ها، بررسی پورت‌ها).
2. **الزام تأیید صریح کاربر برای هرگونه Mutation** (دستکاری فایل‌ها، تغییر تنظیمات، استاپ/استارت سرویس، گیت، شبکه و دیتابیس).

هیچ هاست، پورت، سکرت یا نام سرور خاصی در این skill هاردکد نشده است؛ پارامترها و کانفیگ‌ها در همان ریپوی مصرف‌کننده نگهداری می‌شوند.

---

## ۱. نقشه و اسکریپت‌های اجرایی (`scripts/`)

| اسکریپت | کاربرد | مثال فراخوانی |
|---|---|---|
| `karavi-terminal.open-interactive.ps1` | باز کردن ترمینال تعاملی SSH یا محلی | `& .\scripts\karavi-terminal.open-interactive.ps1 -HostAlias srv1 -RemoteHost 192.168.1.50 -User admin` |
| `karavi-terminal.open-agent-session.ps1` | ایجاد نشست شل پایدار برای ایجنت | `& .\scripts\karavi-terminal.open-agent-session.ps1 -SessionId "sess-01" -Shell pwsh` |
| `karavi-terminal.invoke-agent-command.ps1` | اجرای دستور در نشست ایجنت با کنترل خروجی | `& .\scripts\karavi-terminal.invoke-agent-command.ps1 -SessionId "sess-01" -Command "Get-Process"` |
| `karavi-terminal.close-agent-session.ps1` | بستن امن نشست شل | `& .\scripts\karavi-terminal.close-agent-session.ps1 -SessionId "sess-01"` |
| `karavi-terminal.pty-launch.ps1` | راه‌اندازی فرآیند PTY با بافر ابعاد واقعی | `& .\scripts\karavi-terminal.pty-launch.ps1 -Id "pty-1" -Command "bash"` |
| `karavi-terminal.pty-send-keys.ps1` | ارسال کلیدها و اینپوت به کنسول PTY | `& .\scripts\karavi-terminal.pty-send-keys.ps1 -Id "pty-1" -Keys "top`n"` |
| `karavi-terminal.pty-wait.ps1` | انتظار هوشمند برای متن یا الگوی خروجی | `& .\scripts\karavi-terminal.pty-wait.ps1 -Id "pty-1" -Pattern "Tasks:" -TimeoutSec 10` |
| `karavi-terminal.pty-screenshot.ps1` | دریافت اسنپ‌شات متنی/ASCII از صفحه | `& .\scripts\karavi-terminal.pty-screenshot.ps1 -Id "pty-1"` |
| `karavi-terminal.pty-close.ps1` | خاتمه امن فرآیند PTY | `& .\scripts\karavi-terminal.pty-close.ps1 -Id "pty-1"` |
| `verify-karavi-terminal-skill.ps1` | بررسی سلامت و صحت انکودینگ اسکریپت‌ها | `& .\scripts\verify-karavi-terminal-skill.ps1` |

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
دستور: Stop-Service -Name "TelephonyService" -Force
محدوده: سرور محلی توسعه
ریسک: قطع سرویس تماس‌های ورودی
verifyMethod: بررسی عدم وجود PID سرویس با Get-Process
```

### دستورات کاملاً ممنوع بدون Override اختصاصی
- پاک‌سازی دیسک یا پارتیشن: `format`, `diskpart`, `rm -rf /`
- فورس پوش و ریست مخرب در گیت: `git push --force`, `git reset --hard`
- ارسال سکرت و توکن در بدنه کامندهای شل یا لاگ‌ها

---

## ۳. مثال‌های واقعی و سناریوهای کاربردی (Practical Scenarios)

### سناریو ۱: تست اتصال و بررسی سلامت پورت PJSIP/Asterisk
```powershell
# گام ۱: بررسی دسترسی به پورت ۵۰۶۰ سرور لوکال (Read-Only)
$conn = Test-NetConnection -ComputerName "127.0.0.1" -Port 5060 -InformationLevel Detailed
if ($conn.TcpTestSucceeded) {
    Write-Output "Asterisk TCP SIP port is reachable."
} else {
    Write-Warning "Asterisk SIP port is unreachable. Checking service status..."
    Get-Service -Name "asterisk*"
}
```

### سناریو ۲: راه‌اندازی نشست PTY و تعامل با کنسول لینوکسی (Asterisk CLI)
```powershell
# راه‌اندازی نشست تعاملی
& .\scripts\karavi-terminal.pty-launch.ps1 -Id "ast-cli" -Command "wsl" -Args @("asterisk", "-rvvv")

# انتظار برای ظاهر شدن اعلان کنسول Asterisk
& .\scripts\karavi-terminal.pty-wait.ps1 -Id "ast-cli" -Pattern "CLI>" -TimeoutSec 5

# ارسال دستور مشاهده وضعیت ترانک‌های PJSIP
& .\scripts\karavi-terminal.pty-send-keys.ps1 -Id "ast-cli" -Keys "pjsip show endpoints`n"

# دریافت تصویر متنی وضعیت ترمینال
$screen = & .\scripts\karavi-terminal.pty-screenshot.ps1 -Id "ast-cli"
Write-Output $screen

# خروج و بستن نشست
& .\scripts\karavi-terminal.pty-send-keys.ps1 -Id "ast-cli" -Keys "exit`n"
& .\scripts\karavi-terminal.pty-close.ps1 -Id "ast-cli"
```

### سناریو ۳: اجرای دستور نیازمند تأیید در قالب امن (WhatIf)
```powershell
# بررسی تغییرات قبل از حذف پوشه موقت لاگ
Remove-Item -Path "karavi/karavi.temp.logs/*" -Recurse -WhatIf
```

---

## ۴. نصب و راه‌اندازی (Installation)

```bash
npx skills add https://github.com/akaravi/Karavi.Skills --skill karavi-terminal
```

فراخوانی در چت با ایجنت:
```text
/karavi-terminal
```

---

## ۵. منابع تکمیلی (References)

- [`references/permission-model.md`](references/permission-model.md) — قواعد سخت‌گیرانه مرز Read-Only در برابر Mutation
- [`references/command-classification.md`](references/command-classification.md) — دسته‌بندی و چک‌لیست تمام دستورات شل
- [`references/pty-sessions.md`](references/pty-sessions.md) — جزئیات فنی پروتکل PTY و مانیتورینگ خروجی
- [`references/examples.md`](references/examples.md) — نمونه‌های تکمیلی JSON envelope و پوشش خروجی‌ها
- [`references/orca-terminal.md`](references/orca-terminal.md) — یکپارچه‌سازی با ترمینال محیط Orca

---

## ۶. License

Apache-2.0
