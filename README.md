# Karavi.Skills

مخزن مهارت‌ها (Skills) برای دستیارهای کدنویسی AI — Cursor، Claude Code،
Antigravity، OpenCode، Codex و Cline.

این مخزن طبق ساختار و روش‌شناسی استاندارد مهارت‌ها (Skills) نوشته و مدیریت می‌شود:
هر مهارت در `skills/<name>/` با `SKILL.md` (entry point)، `README.md`، `LICENSE`،
`references/` و (در صورت نیاز) `scripts/` قرار می‌گیرد. `SKILL.md` زیر ۵۰۰ خط
نگه داشته می‌شود و جزئیات در `references/` به‌صورت on-demand بارگذاری می‌شود.

## نصب

```bash
npx skills add https://github.com/akaravi/Karavi.Skills --skill karavi-folder
npx skills add https://github.com/akaravi/Karavi.Skills --skill karavi-rule
npx skills add https://github.com/akaravi/Karavi.Skills --skill karavi-prompt
```

## مهارت‌ها

| مهارت | دسته | کارکرد |
| [`karavi-prompt`](./skills/karavi-prompt/) | Prompt pipeline | هر پرامپتی که به agent داده می‌شود ابتدا مهندسی و بهینه‌سازی می‌شود، سپس در کادر «در حال اجرا» به کاربر نمایش داده می‌شود، و تنها پس از عبور از guard به‌صورت مسلح‌شده dispatch می‌شود. |
| [`karavi-terminal`](./skills/karavi-terminal/) | Operator session | جلسهٔ ترمینال Windows نظارت‌شده: PowerShell، Windows Terminal، SSH، WSL، read-only خودکار و mutation با تأیید. |
| [`karavi-folder`](./skills/karavi-folder/) | Pipeline / caretaker | اسکلت استاندارد `karavi/` را به‌صورت کامل (پیش‌فرض Full: ۲۱ فولدر) می‌سازد، فولدرهای قبلی/قدیمی را تغییر نام و مهاجرت می‌دهد (بخش ۱)، و اطلاعات موقت (`karavi.temp.*`) و کش را به‌شکل امن پاک می‌کند (بخش ۲). |
| [`karavi-asterisk-voip`](./skills/karavi-asterisk-voip/) | VoIP / telephony reference | راهنمای توسعه و عیب‌یابی Asterisk، FreePBX، SIP/PJSIP، RTP، AMI، ARI، AGI، Dialplan، IVR، Queue و CDR/CEL با تمرکز بر امنیت، idempotency، observability و تست. |
| [`karavi-council`](./skills/karavi-council/) | Planning / architecture | شورای تصمیم‌گیری فنی برای context sweep، گزینه‌ها، red-team، ADR، specification، plan و readiness قبل از اجرا؛ تصمیم‌های فنی داخل scope را خودکار می‌کند. |
| [`karavi-judge`](./skills/karavi-judge/) | Quality / acceptance | داوری مستقل مبتنی بر evidence با relevance mask هفت حوزه، failure scenario، Completion Envelope و verdictهای `accept|block|fail` بدون Block بی‌مورد برای اختلاف advisory یا findingهای low/medium. |
| [`karavi-rule`](./skills/karavi-rule/) | Global rule router | فعال‌سازی منبع canonical قوانین، نصب اجباری `karavi-council`، `karavi-folder` و `karavi-judge` و واگذاری هم‌پوشانی‌های workflow به skill صاحب آن. |

## انتخاب مهارت

- جلسه ترمینال Windows/PowerShell با تأیید mutation؟ → `/karavi-terminal`
- نوشتن یا ارسال پرامپت به agent؟ → `/karavi-prompt arm "<request>"`
- راه‌اندازی، ساختار کامل و مهاجرت ساختارهای قبلی `karavi/`؟ → `/karavi-folder init` یا `/karavi-folder create` (پیش‌فرض: کامل / Full)
- پاک‌کردن لاگ‌ها / کش / آرت‌فکت‌ها؟ → `/karavi-folder clean` (با `--deep` برای پاک‌سازی کامل)
- فعال‌سازی قوانین جهانی و نصب وابستگی‌های اجباری؟ → `/karavi-rule`
- معماری، ADR یا برنامه‌ریزی پیامددار؟ → `/karavi-council`
- پذیرش نهایی delivery بر اساس evidence؟ → `/karavi-judge`
ترتیب وقتی چند مورد کاربرد دارد: اول مسلح‌کردن پرامپت (`karavi-prompt`)، سپس
برنامه‌ریزی (`karavi-council`)، سپس اجرا زیر مدل مجوز ترمینال
(`karavi-terminal`)، و در پایان پذیرش (`karavi-judge`).

## محتوا

```
skills/
├── AGENTS.md / CLAUDE.md / README.md      ایندکس مهارت‌ها
└── <skill-name>/
    ├── SKILL.md          ورودی / تصمیم‌گیری
    ├── README.md         مستندات کاربر
    ├── LICENSE           Apache-2.0
    ├── references/       یک فایل برای هر موضوع، on-demand
    ├── scripts/          اسکریپت‌های可选
    └── tests/            تست‌های Pester
```

قالب فایل‌ها UTF-8 **بدون** BOM است. Windows PowerShell 5.1 فایل `.ps1`
بدون BOM را با code page سیستم می‌خواند، بنابراین اسکریپت‌های این مخزن
ASCII-only هستند و هر گلیف غیر-ASCII از روی code point ساخته می‌شود —
نمونه: `Get-KaraviPromptGlyph` در `karavi-prompt/scripts/karavi-prompt.common.psm1`.

## License

Apache-2.0
