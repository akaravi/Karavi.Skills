# CLAUDE.md — Karavi.Skills Integration Guide

این فایل راهنمای جامع تعامل و کار با **مخزن Karavi.Skills** برای دستیار **Claude Code** (و سایر دستیارهای هوش مصنوعی سازگار با Claude) است.

---

## ۱. نقشه و ساختار مهارت‌ها (Skills Architecture)

این مخزن شامل مهارت‌های استاندارد توسعه، اجرا، بازبینی و مدیریت پروژه است:

| مهارت | مسیر | نوع | وظیفه اصلی |
|---|---|---|---|
| [`karavi-prompt`](./karavi-prompt/) | `skills/karavi-prompt` | Pipeline | تسلیح و مهندسی پرامپت قبل از ارسال به ایجنت (Guard, Panel, Ledger, Dispatch) |
| [`karavi-terminal`](./karavi-terminal/) | `skills/karavi-terminal` | Operator Session | مدیریت نشست‌های امن ترمینال (PowerShell, SSH, WSL, PTY) با مدل مجوز Read-Only خودکار و Mutation با تأیید |
| [`karavi-folder`](./karavi-folder/) | `skills/karavi-folder` | Caretaker | مقداردهی اولیه ۲۱ فولدر استاندارد، مهاجرت خودکار ساختارهای قدیمی و پاک‌سازی ایمن temp/cache |
| [`karavi-asterisk-voip`](./karavi-asterisk-voip/) | `skills/karavi-asterisk-voip` | Reference | مرجع جامع Asterisk 22 LTS، PJSIP، AMI، ARI، FastAGI، Dialplan، WebRTC و امنیت مخابراتی |
| [`karavi-council`](./karavi-council/) | `skills/karavi-council` | Architecture / Plan | شورای تصمیم‌گیری فنی، مقایسه راهکارها، طراحی ADR، نگارش Spec و ارزیابی آمادگی (Readiness) |
| [`karavi-judge`](./karavi-judge/) | `skills/karavi-judge` | Quality Gate | داوری مستقل کیفیت با ماسک هفت‌گانه (7Expert)، تحلیل شکست و ثبت Completion Envelope |
| [`karavi-rule`](./karavi-rule/) | `skills/karavi-rule` | Router / Governance | اعمال قوانین جهانی، الزام وابستگی‌های سه‌گانه و هدایت درخواست‌ها به مهارت صاحب فرایند |

---

## ۲. توالی اجرایی استاندارد (Standard Execution Flow)

هنگام مواجهه با درخواست‌های پیچیده یا تغییرات چندبخشی، Claude باید این توالی را رعایت کند:

```text
1. ARMED PROMPT    →  /karavi-prompt arm "<raw user prompt>"
2. ARCH & PLANNING →  /karavi-council (Brief → Options → ADR → Spec → Plan → Readiness)
3. EXECUTION       →  /karavi-terminal (Read-Only auto-run, Mutation with explicit approval)
4. CLEANUP/TREE    →  /karavi-folder (init / clean --deep)
5. ACCEPTANCE      →  /karavi-judge (Relevance Mask → Failure Scenario → Verdict)
```

---

## ۳. مثال‌های کاربردی و نحوه فراخوانی (Usage Examples)

### مثال ۱: تسلیح پرامپت با `karavi-prompt` قبل از ارسال به ساب‌ایجنت

```text
/karavi-prompt arm "ماژول احراز هویت JWT را با رفرش توکن و تست‌های کامل پیاده‌سازی کن"
```

Claude یک سند Intent Contract و Spec استخراج کرده و کادر زیر را به کاربر نمایش می‌دهد:

```text
╔══════════════════════════════════════════════════════════════════════╗
║  KARAVI · PROMPT ARMED · IN EXECUTION                              ║
╠══════════════════════════════════════════════════════════════════════╣
║  RUN     : kp-20261001-auth-jwt                                     ║
║  TARGET  : host=omp agent=pm-builder model=frontier mode=mutating    ║
║  GUARD   : PASS secret=0 injection=0 taint=0 contract=ok budget=ok   ║
║  SIZE    : raw=45 tok -> armed=312 tok (+593%)                      ║
╠══════════════════════════════════════════════════════════════════════╣
║  ARMED PROMPT                                                      ║
║  <goal>Implement JWT auth module with rotating refresh tokens</goal> ║
║  <acceptance>All unit tests pass, zero secret leaks</acceptance>   ║
╚══════════════════════════════════════════════════════════════════════╝
```

---

### مثال ۲: اجرای دستورات امن ترمینال با `karavi-terminal`

**دستور Read-Only (بدون نیاز به تأیید کاربر):**
```powershell
# بررسی وضعیت پورت‌های شبکه و سلامت سرویس
Test-NetConnection -ComputerName 127.0.0.1 -Port 5060 -InformationLevel Detailed
Get-Service -Name "asterisk" -ErrorAction SilentlyContinue
```

**دستور Mutation (تأیید صریح کاربر الزامی است):**
```text
[درخواست اجرا — MUTATION]
دستور: Restart-Service -Name "asterisk"
محدوده: سرویس VoIP لوکال
ریسک: قطع موقت تماس‌های در جریان
آیا اجرا تأیید می‌شود؟ (بله / خیر)
```

---

### مثال ۳: مقداردهی اولیه و مهاجرت ساختار فولدر با `karavi-folder`

```bash
# ایجاد ساختار ۲۱ فولدری و مهاجرت خودکار پوشه‌های قبلی
/karavi-folder init

# پیش‌نمایش پاک‌سازی کش‌ها و فایل‌های موقت بدون حذف واقعی
/karavi-folder clean --what-if

# پاک‌سازی کامل temp و فایل‌های build
/karavi-folder clean --deep
```

---

### مثال ۴: معماری و برنامه‌ریزی یک فیچر پیامددار با `karavi-council`

```text
/karavi-council برای مهاجرت از FreePBX Dialplan قدیمی به ARI و FastAGI در دات‌نت، یک plan کامل همراه با ADR آماده کن
```

خروجی‌های استاندارد در `docs/planning/<YYYY-MM-DD>-<slug>/` تولید می‌شوند:
- `00-brief.md`: هدف، ذینفعان و معیار موفقیت
- `03-approaches.md`: تحلیل گزینه‌های ARI در مقابل AMI/AGI
- `05-decisions.md`: تصمیم نهایی معماری (ADR)
- `07-plan.md`: بخش‌های اجرایی با owner، فایل‌ها و verifyMethod مشخص

---

### مثال ۵: داوری مستقل و ارزیابی کیفیت با `karavi-judge`

```text
/karavi-judge خروجی پیاده‌سازی و شواهد تست‌های ماژول ARI را در سطح standard داوری کن
```

نمونه خروجی Completion Envelope:

```text
=== KARAVI COMPLETION ENVELOPE ===
Check 1 — scopeComplete: PASS (تمام 4 نیازمندی ARI و Stasis پوشش داده شد)
Check 2 — crossSectionComplete: PASS (تست‌های یکپارچگی سبز هستند)
Check 3 — 7ExpertSummary:
  - Backend & Architecture: PASS (جداسازی لایه Business از WebSocket)
  - Infrastructure & Security: PASS (احراز هویت ARI با متغیر محیطی، بدون افشای رمز)
  - Quality & Testing: PASS (تست قطع اتصال و reconnect با موفقیت اجرا شد)
JudgeVerdict: ACCEPT
Next Actions (خارج از اسکوپ فعلی):
  1. افزودن متریک‌های Prometheus برای مانیتورینگ تاخیر رویدادهای Stasis
=================================
```

---

## ۴. اصول تغییرناپذیر مهندسی (Core Engineering Rules)

1. **مدل مجوز ترمینال:** هر دستوری که تغییری در فایل‌ها، سرویس‌ها، رجیستری یا دیتابیس ایجاد کند، `MUTATION` است و باید تأیید شود.
2. **عدم افشای سکرت‌ها:** هیچ کلمه عبور، توکن، کلید خصوصی یا رشته اتصال نباید در چت، لاگ، کامیت یا آرت‌فکت درج شود.
3. **رمزگذاری فایل‌ها:** همه فایل‌های متنی باید UTF-8 بدون BOM باشند.
4. **رفتار خودمختار در اسکوپ:** تصمیم‌های فنی داخل محدوده با شواهد رسمی اتخاذ می‌شوند؛ پیدا شدن یافته‌های low/medium به‌تنهایی نباید گردش کار را متوقف کند.
5. **داوری مبتنی بر شواهد:** ادعای پایان کار تنها در صورت داشتن تست اجراشده، خروجی دستور یا شواهد عینی پذیرفته می‌شود.
