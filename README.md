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
```

## مهارت‌ها

| مهارت | دسته | کارکرد |
| [`karavi-powershell-session`](./skills/karavi-powershell-session/) | Operator session | جلسه PowerShell نظارت‌شده: login کاربر، read-only خودکار، mutation با تأیید. |
| [`karavi-folder`](./skills/karavi-folder/) | Pipeline / caretaker | اسکلت استاندارد `karavi/` را به‌صورت کامل (پیش‌فرض Full: ۱۸ فولدر) می‌سازد، فولدرهای قبلی/قدیمی را تغییر نام و مهاجرت می‌دهد (بخش ۱)، و اطلاعات موقت (`karavi.temp.*`) و کش را به‌شکل امن پاک می‌کند (بخش ۲). |
| [`karavi-asterisk-voip`](./skills/karavi-asterisk-voip/) | VoIP / telephony reference | راهنمای توسعه و عیب‌یابی Asterisk، FreePBX، SIP/PJSIP، RTP، AMI، ARI، AGI، Dialplan، IVR، Queue و CDR/CEL با تمرکز بر امنیت، idempotency، observability و تست. |

## انتخاب مهارت

- جلسه ترمینال PowerShell با تأیید mutation؟ → `/karavi-powershell-session`
- راه‌اندازی، ساختار کامل و مهاجرت ساختارهای قبلی `karavi/`؟ → `/karavi-folder init` یا `/karavi-folder create` (پیش‌فرض: کامل / Full)
- پاک‌کردن لاگ‌ها / کش / آرت‌فکت‌ها؟ → `/karavi-folder clean` (با `--deep` برای پاک‌سازی کامل)
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
