# Karavi.Skills

مخزن مهارت‌ها (Skills) برای دستیارهای کدنویسی AI — Cursor، Claude Code،
Antigravity، OpenCode، Codex و Cline.

این مخزن طبق ساختار و روش‌شناسی استاندارد مهارت‌ها (Skills) نوشته و مدیریت می‌شود:
هر مهارت در `skills/<name>/` با `SKILL.md` (entry point)، `README.md`، `LICENSE`،
`references/` و (در صورت نیاز) `scripts/` قرار می‌گیرد. `SKILL.md` زیر ۵۰۰ خط
نگه داشته می‌شود و جزئیات در `references/` به‌صورت on-demand بارگذاری می‌شود.

## پیش‌نیاز و نصب

- یک دستیار با قابلیت بارگذاری skill؛ روش کشف و فعال‌سازی به میزبان بستگی دارد.
- برای نصب با CLI، محیط Node.js و `pnpm` و دسترسی به GitHub لازم است.
- اجرای اسکریپت‌ها پیش‌نیازهای جداگانه دارد؛ راهنمای همان مهارت را بخوانید. نصب یک skill به‌تنهایی PowerShell، Pester، سرویس VoIP یا زیرساخت CI را نصب نمی‌کند.

نمونهٔ نصب انتخابی با CLI بستهٔ `skills`:

```bash
pnpm dlx skills add https://github.com/akaravi/Karavi.Skills --skill karavi-folder
pnpm dlx skills add https://github.com/akaravi/Karavi.Skills --skill karavi-rule
pnpm dlx skills add https://github.com/akaravi/Karavi.Skills --skill karavi-prompt
```

برای مهارت دیگر، مقدار `--skill` را از جدول زیر انتخاب کنید. نصب و به‌روزرسانی فایل‌های محلی نیازمند مجوز مربوط به میزبان است؛ فرمان‌های بالا هنگام خواندن README خودکار اجرا نمی‌شوند.

هنگام فعال‌سازی `karavi-rule`، نصب و کشف هر سه وابستگی `karavi-council`، `karavi-folder` و `karavi-judge` باید جداگانه تأیید شود؛ [قرارداد نصب canonical](./skills/karavi-rule/references/installation.md) مرجع فرمان‌ها و شرایط تأیید است.

اگر میزبان نصب خودکار ندارد، `SKILL.md` مهارت منتخب از [فهرست مهارت‌ها](./skills/README.md) و referenceهای ارجاع‌شده را از همین مخزن در اختیار آن بگذارید؛ صرف کپی‌کردن فایل، ادعای نصب یا فعال‌شدن در همهٔ میزبان‌ها نیست.

## مهارت‌ها

| مهارت | دسته | کارکرد |
|---|---|---|
| [`karavi-prompt`](./skills/karavi-prompt/) | Prompt pipeline | هر پرامپتی که به agent داده می‌شود ابتدا مهندسی و بهینه‌سازی می‌شود، سپس در کادر «در حال اجرا» به کاربر نمایش داده می‌شود، و تنها پس از عبور از guard به‌صورت مسلح‌شده dispatch می‌شود. |
| [`karavi-terminal`](./skills/karavi-terminal/) | Operator session | جلسهٔ ترمینال Windows نظارت‌شده: PowerShell، Windows Terminal، SSH، WSL، read-only خودکار و mutation با تأیید. |
| [`karavi-folder`](./skills/karavi-folder/) | Pipeline / caretaker | اسکلت استاندارد `karavi/` را به‌صورت کامل (پیش‌فرض Full: ۲۱ فولدر) می‌سازد، فولدرهای قبلی/قدیمی را تغییر نام و مهاجرت می‌دهد (بخش ۱)، و اطلاعات موقت (`karavi.temp.*`) و کش را به‌شکل امن پاک می‌کند (بخش ۲). |
| [`karavi-asterisk-voip`](./skills/karavi-asterisk-voip/) | VoIP / telephony reference | راهنمای توسعه و عیب‌یابی Asterisk، FreePBX، SIP/PJSIP، RTP، AMI، ARI، AGI، Dialplan، IVR، Queue و CDR/CEL با تمرکز بر امنیت، idempotency، observability و تست. |
| [`karavi-council`](./skills/karavi-council/) | Planning / architecture | شورای تصمیم‌گیری فنی برای context sweep، گزینه‌ها، red-team، ADR، specification، plan و readiness قبل از اجرا؛ تصمیم‌های فنی داخل scope را خودکار می‌کند. |
| [`karavi-judge`](./skills/karavi-judge/) | Quality / acceptance | داوری مستقل مبتنی بر evidence با relevance mask هفت حوزه، failure scenario، Completion Envelope و verdictهای `accept|block|fail` بدون Block بی‌مورد برای اختلاف advisory یا findingهای low/medium. |
| [`karavi-rule`](./skills/karavi-rule/) | Global rule router | فعال‌سازی منبع canonical قوانین، نصب اجباری `karavi-council`، `karavi-folder` و `karavi-judge` و واگذاری هم‌پوشانی‌های workflow به skill صاحب آن. |
| [`karavi-deploy-github-plesk`](./skills/karavi-deploy-github-plesk/) | Deployment / CI-CD | مسیر انتشار GitHub Actions به Plesk با تگ دقیق `publish`، branch و path اختصاصی، webhook و بررسی smoke. |
| [`karavi-deploy-gitlab-plesk`](./skills/karavi-deploy-gitlab-plesk/) | Deployment / CI-CD | انتشار بدون zip از GitLab به Plesk؛ push تگ دقیق `publish`، مراحل `test → build → health` و بررسی Health و Swagger. |

## انتخاب مهارت

- جلسه ترمینال Windows/PowerShell با تأیید mutation؟ → `/karavi-terminal`
- نوشتن یا ارسال پرامپت به agent؟ → `/karavi-prompt arm "<request>"`
- راه‌اندازی، ساختار کامل و مهاجرت ساختارهای قبلی `karavi/`؟ → `/karavi-folder init` یا `/karavi-folder create` (پیش‌فرض: کامل / Full)
- پاک‌کردن لاگ‌ها / کش / آرت‌فکت‌ها؟ → `/karavi-folder clean` (با `--deep` برای پاک‌سازی کامل)
- فعال‌سازی قوانین جهانی و نصب وابستگی‌های اجباری؟ → `/karavi-rule`
- معماری، ADR یا برنامه‌ریزی پیامددار؟ → `/karavi-council`
- پذیرش نهایی delivery بر اساس evidence؟ → `/karavi-judge`
- عیب‌یابی یا طراحی Asterisk/FreePBX، SIP و RTP؟ → `/karavi-asterisk-voip`
- انتشار GitHub Actions به Plesk؟ → `/karavi-deploy-github-plesk`
- انتشار GitLab CI/CD به Plesk با بررسی Swagger/Health؟ → `/karavi-deploy-gitlab-plesk`

ترتیب وقتی چند مورد کاربرد دارد: اول مسلح‌کردن پرامپت (`karavi-prompt`)، سپس
برنامه‌ریزی (`karavi-council`)، سپس اجرا زیر مدل مجوز ترمینال
(`karavi-terminal`)، و در پایان پذیرش (`karavi-judge`).

## استفاده و مرز اجرا

نام‌های `/karavi-*` در این راهنما درخواست به دستیارند، نه الزاماً command قابل اجرا در shell. پشتیبانی از slash command به میزبان بستگی دارد؛ در غیر این صورت نام skill و درخواست دقیق را در پیام بنویسید.

```text
با karavi-deploy-gitlab-plesk فقط پیکربندی CI این مخزن را بررسی کن:
تگ publish، ترتیب test سپس build سپس health، و بررسی Swagger و Health.
هیچ تگ، push یا Deploy اجرا نکن.
```

برای یک درخواست قابل اجرا، scope، فایل یا پروژهٔ هدف، نتیجهٔ مورد انتظار و روش تأیید را مشخص کنید. مسیرها، دامنه، owner و runtime باید از پیکربندی همان پروژه استخراج شوند.

- نصب و فراخوانی skill مجوز خودکار برای حذف، تغییر زیرساخت، Git mutation، انتشار یا Deploy نیست.
- `karavi-council` در readiness پایان می‌یابد و خودش پیاده‌سازی یا استقرار نمی‌کند.
- `karavi-judge` داوری می‌کند؛ نتیجهٔ نامشخص یا بررسی اجرا‌نشده را موفق اعلام نمی‌کند.
- رمز، token، private key، URL محرمانهٔ webhook و اطلاعات شخصی نباید وارد پیام، Git، نمونه یا گزارش شوند.
- FTP/SFTP/FTPS و انتقال remote فقط با مجوز مستقل `Deploy` مجازند؛ پیش‌نمایش محلی مجوز انتقال نیست.

## خروجی و اعتبارسنجی

این مخزن یک برنامه یا pipeline آماده برای همهٔ پروژه‌ها نیست؛ دستورالعمل‌ها و helperهای اختصاصی ارائه می‌کند. خروجی بسته به مهارت، پرامپت مهندسی‌شده، گزارش بررسی، برنامهٔ مکتوب، ساختار workspace یا تغییر پیکربندی پروژه است.

1. بعد از نصب، کشف skill در میزبان، وجود `SKILL.md` و تطابق `name` را بررسی کنید.
2. قبل از اجرا، پیش‌نیازها، ورودی‌ها و سطح مجوز را از README و `SKILL.md` همان مهارت بخوانید.
3. فقط بررسی واقعاً اجراشده را گزارش کنید؛ اعتبار لینک و syntax جای تست runtime یا تأیید استقرار واقعی نیست.
4. فرمان‌های verifier و آزمون‌های موجود در راهنمای هر مهارت آمده‌اند؛ همهٔ مهارت‌ها script یا test suite ندارند.

## نگهداری مستندات

فهرست کامل و راهنمای ساختار در [skills/README.md](./skills/README.md)، قواعد مشارکت در [skills/AGENTS.md](./skills/AGENTS.md) و راهنمای یکپارچه‌سازی در [skills/CLAUDE.md](./skills/CLAUDE.md) قرار دارند. برای تغییر رفتار، ابتدا `SKILL.md` و referenceهای مرتبط را مبنا قرار دهید و README و فهرست‌ها را هماهنگ کنید؛ README نباید قابلیت تازه‌ای را بدون پیاده‌سازی وعده دهد.

## محتوا

```
skills/
├── AGENTS.md / CLAUDE.md / README.md      ایندکس مهارت‌ها
└── <skill-name>/
    ├── SKILL.md          ورودی / تصمیم‌گیری
    ├── README.md         مستندات کاربر
    ├── LICENSE           Apache-2.0
    ├── references/       یک فایل برای هر موضوع، on-demand
    ├── scripts/          اسکریپت‌های اختیاری
    └── tests/            آزمون‌های اختیاری، مانند Pester
```

قالب فایل‌ها UTF-8 **بدون** BOM است. Windows PowerShell 5.1 فایل `.ps1`
بدون BOM را با code page سیستم می‌خواند، بنابراین اسکریپت‌های این مخزن
ASCII-only هستند و هر گلیف غیر-ASCII از روی code point ساخته می‌شود —
نمونه: `Get-KaraviPromptGlyph` در `karavi-prompt/scripts/karavi-prompt.common.psm1`.

## License

[Apache-2.0](./LICENSE)؛ فایل LICENSE هر مهارت نیز در پوشهٔ خودش قرار دارد.
