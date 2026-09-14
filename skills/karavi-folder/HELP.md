# karavi-folder — Help

راهنمای کامل کاربر برای مهارت `karavi-folder`. اسکلت استاندارد `karavi/` را در
ریپو می‌سازد و اطلاعات موقت (`karavi.temp.*`) را امن پاک می‌کند.

Complete user guide for the `karavi-folder` skill: it scaffolds the standard
`karavi/` workspace tree and safely removes temporary data.

---

## 1) این مهارت چه کاری انجام می‌دهد؟

دو عملیات مستقل:

| بخش | عملیات |
|---|---|
| ۱ | ساخت فولدرهای اصلی `karavi/` (Core یا Core+Optional) |
| ۲ | پاک‌سازی اطلاعات موقت — محتوای چهار فولدر `karavi.temp.*` و کش‌ها |

- امن و idempotent است: اجرای دوباره، چیزی را حذف/بازنویسی نمی‌کند.
- فقط چهار فولدر `karavi.temp.*` قابل حذف‌اند؛ هیچ سورس، config، history یا README حذف نمی‌شود.
- هرگز از پروژه‌ی دیگر import نمی‌کند — فقط در همین ریپو کار می‌کند.

---

## 2) فولدرهایی که ساخته می‌شوند

### Core — دستور `create` (۹ فولدر)

| فولدر | چه چیز (فارسی) |
|---|---|
| `karavi.plans.prompt` | پرامپت‌ها، قوانین JSON و پلن‌های Agent برای همه‌ی ابزارها (Cursor/Claude/سایر) — یک‌جا |
| `karavi.history` | تاریخچه تغییرات، فایل روزانه `history.YYYY-MM-DD.md` |
| `karavi.deploy.config` | تنظیمات deploy و FTP این ریپو (hostها، targets، secrets) |
| `karavi.scripts.command` | دستورات اپراتور (deploy، run all، clean، history.write و…) |
| `karavi.scripts.tools` | helperهای ابزاری (verify، path resolver، build pieces و…) |
| `karavi.temp.logs` | لاگ‌های موقت محلی (gitignored) — پاک‌شدنی |
| `karavi.temp.status` | گزارش‌های وضعیت موقت (gitignored) — پاک‌شدنی |
| `karavi.temp.deploy` | خروجی موقت آماده deploy (gitignored) — پاک‌شدنی |
| `karavi.temp.build` | خروجی موقت build (gitignored) — پاک‌شدنی |

### Optional — دستور `create --full` (۸ فولدر اضافه)

`karavi.assets/{brand,icons,screenshots,templates}` · `karavi.mockup` ·
`karavi.doc` · `karavi.BusinessModel.Doc` · `karavi.Customer.doc` ·
`karavi.SociaMediaContent`

> فقط اگر پروژه به آن‌ها نیاز دارد. `karavi.deploy.config` و `karavi.scripts.*`
> محفوظ‌اند و پاک نمی‌شوند.

---

## 3) دستورها (commands)

| دستور | اثر |
|---|---|
| `/karavi-folder` | می‌پرسد کدام بخش؛ سپس اجرا می‌کند |
| `/karavi-folder creat` | ساخت Core (۹ فولدر) |
| `/karavi-folder create --full` | ساخت Core + Optional (۱۸ فولدر) |
| `/karavi-folder clean` | پاک‌سازی `karavi.temp.logs` + `karavi.temp.status` |
| `/karavi-folder clean --deep` | پاک‌سازی هر ۴ temp + خروجی ریپو-سطح + کش‌ها |
| `/karavi-folder clean --what-if` | پیش‌نمایش خشک — هیچ‌چیز حذف نمی‌شود |
| `/karavi-folder help` | نمایش همین راهنما |

فارسی:
```
/karavi-folder ساخت            /karavi-folder ساخت --کامل
/karavi-folder پاکسازی          /karavi-folder پاکسازی --عمیق   /karavi-folder پاکسازی --پیش‌نمایش
```

### دستور بکارگیری همیشگی (در هر ریپو)
```
/karavi-folder create --full
```
اجرا دوباره بی‌خطر و idempotent است — نه حذف، نه بازنویسی.

### نسخه‌های مستقیم اسکریپت (PowerShell، از ریشه ریپو)
```powershell
& "karavi/karavi.scripts.command/karavi-folder.create.ps1" -Full            # ساخت
& "karavi/karavi.scripts.command/karavi-folder.clean.ps1" -Deep             # پاک‌سازی عمیق
& "karavi/karavi.scripts.command/karavi-folder.clean.ps1" -WhatIf           # پیش‌نمایش
& "karavi/karavi.scripts.command/karavi-folder.clean.ps1" -RepoRoot D:\X\Y  # ریپوی خاص
```

---

## 4) پاک‌سازی — دقیقاً چه چیزی حذف می‌شود؟

### `clean` (پیش‌فرض)
در `karavi.temp.logs` و `karavi.temp.status`:
`*.out.txt`، `*.err.txt`، `_tmp-*`، `_fix-*`، `*launch.ps1`، `*loop.ps1`،
`*.pid`، توکن/state دامپ‌ها، فایل‌های HTML/JSON موقت.

### `clean --deep`
همه‌ی موارد بالا **به‌علاوه**:
- `karavi.temp.build/` و `karavi.temp.deploy/`
- خروجی ریپو-سطح: `publish/`, `artifacts/`, `.run-logs/`, `LastRunInfo.html`, `Deploy_Summary.html`
- کش‌ها: `**/bin/`, `**/obj/`, `**/.dart_tool/`, `.next/`, `dist/`, `out/`, `node_modules/.cache/`

### هرگز حذف نمی‌شود
سورس، `karavi.history/`، `karavi.deploy.config/`، `karavi.plans.prompt/`،
`karavi.scripts.command/`، `karavi.scripts.tools/`، READMEها، `.gitkeep`.

---

## 5) نمونه‌ی عملی (end-to-end)

```text
# ۱) ساختار را بساز
/karavi-folder create --full

# ۲) بعد از چند run، اول پیش‌نمایش بگیر
/karavi-folder clean --what-if

# ۳) پاک‌سازی هر ۴ فولدر temp + کش‌ها (با تأیید)
/karavi-folder clean --deep
```

**اسکریپت مستقیم از PowerShell:**
```powershell
# ساخت کامل
& "karavi/karavi.scripts.command/karavi-folder.create.ps1" -Full

# فقط محتوای ۴ فولدر temp (بدون کش)
$k = Join-Path (Get-Location) 'karavi'
Get-ChildItem $k -Directory -Filter 'karavi.temp.*' | ForEach-Object {
    Get-ChildItem $_.FullName -Force | Where-Object { $_.Name -ne '.gitkeep' } |
        Remove-Item -Recurse -Force
}
```

---

## 6) ایکزیت‌کدها

| کد | معنی |
|---|---|
| 0 | موفق |
| 1 | پیش‌شرط برقرار نیست (ریشه‌ی ریپو یافت نشد / فولدر ساخته نشد) |
| 2 | کاربر بعد از پیش‌نمایش، حذف را رد کرد |
| 3 | مسیر هدف در لیست حفظ است یا خارج از ریپو — ممتنع |

---

## 7) عیب‌یابی

| مشکل | راه‌حل |
|---|---|
| «No repo root found» | از داخل ریپو اجرا کنید، یا `-RepoRoot D:\path` بدهید |
| فولدرها ساخته نشدند | مطمئن شوید ریپو `.git` دارد یا `karavi/` دارد؛ از `--what-if` برای مشاهده چه چیز خلق می‌شود استفاده کنید |
| چیزی زیاد پاک شد؟ | `clean --deep` کش‌ها را هم پاک می‌کند؛ اگر فقط temp می‌خواهید از دستور «فقط محتوای ۴ temp» در بخش ۵ استفاده کنید |
| خطای «No valid skills found» موقع نصب | از مخزن GitHub استفاده کنید و پارامتر `--skill karavi-folder` را بدهید |

---

## 8) سوالات رایج (FAQ)

- **آیا اجرای create فولدرهای موجود را بازنویسی می‌کند؟** نه — فقط فولدرهای مفقود را می‌سازد.
- **آیا clean config یا history را می‌زند؟** هرگز. فقط `karavi.temp.*` و کش‌ها/خروجی موقت.
- **در هر پروژه باید این را اجرا کنم؟** بله — `create --full` به‌عنوان عادت هر بار که `karavi/` ناقص است.
- **تفاوت clean و clean --deep؟** clean فقط لاگ+وضعیت، --deep همه temp چهارگانه + خروجی + کش.
- **از کجا می‌دانم چه چیزی پاک می‌شود؟** اول `--what-if` اجرا کنید — لیست کامل می‌دهد، بدون حذف.