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
```

## مهارت‌ها

| مهارت | دسته | کارکرد |
| [`karavi-terminal`](./skills/karavi-terminal/) | Operator session | جلسهٔ ترمینال Windows نظارت‌شده: PowerShell، Windows Terminal، SSH، WSL، read-only خودکار و mutation با تأیید. |
| [`karavi-folder`](./skills/karavi-folder/) | Pipeline / caretaker | اسکلت استاندارد `karavi/` را به‌صورت کامل (پیش‌فرض Full: ۱۸ فولدر) می‌سازد، فولدرهای قبلی/قدیمی را تغییر نام و مهاجرت می‌دهد (بخش ۱)، و اطلاعات موقت (`karavi.temp.*`) و کش را به‌شکل امن پاک می‌کند (بخش ۲). |
| [`karavi-asterisk-voip`](./skills/karavi-asterisk-voip/) | VoIP / telephony reference | راهنمای توسعه و عیب‌یابی Asterisk، FreePBX، SIP/PJSIP، RTP، AMI، ARI، AGI، Dialplan، IVR، Queue و CDR/CEL با تمرکز بر امنیت، idempotency، observability و تست. |
| [`karavi-council`](./skills/karavi-council/) | Planning / architecture | شورای تصمیم‌گیری فنی برای context sweep، گزینه‌ها، red-team، ADR، specification، plan و readiness قبل از اجرا؛ تصمیم‌های فنی داخل scope را خودکار می‌کند. |
| [`karavi-judge`](./skills/karavi-judge/) | Quality / acceptance | داوری مستقل مبتنی بر evidence با relevance mask هفت حوزه، failure scenario، Completion Envelope و verdictهای `accept|block|fail` بدون Block بی‌مورد برای اختلاف advisory یا findingهای low/medium. |
| [`karavi-rule`](./skills/karavi-rule/) | Global rule router | فعال‌سازی منبع canonical قوانین، نصب اجباری `karavi-council`، `karavi-folder` و `karavi-judge` و واگذاری هم‌پوشانی‌های workflow به skill صاحب آن. |

## انتخاب مهارت

- جلسه ترمینال Windows/PowerShell با تأیید mutation؟ → `/karavi-terminal`
- راه‌اندازی، ساختار کامل و مهاجرت ساختارهای قبلی `karavi/`؟ → `/karavi-folder init` یا `/karavi-folder create` (پیش‌فرض: کامل / Full)
- پاک‌کردن لاگ‌ها / کش / آرت‌فکت‌ها؟ → `/karavi-folder clean` (با `--deep` برای پاک‌سازی کامل)
- فعال‌سازی قوانین جهانی و نصب وابستگی‌های اجباری؟ → `/karavi-rule`
## محتوا

```
skills/
├── AGENTS.md / CLAUDE.md / README.md      ایندکس مهارت‌ها
└── karavi-folder/
    ├── SKILL.md          ورودی / تصمیم‌گیری
    ├── README.md         مستندات کاربر
    ├── LICENSE           Apache-2.0
    ├── references/       folders.md (بخش ۱) · cleanup.md (بخش ۲)
    └── scripts/          karavi-folder.init.ps1 · karavi-folder.create.ps1 · karavi-folder.clean.ps1
```

## License

Apache-2.0
