# Karavi.Skills

مخزن مهارت‌ها (Skills) برای دستیارهای کدنویسی AI — Cursor، Claude Code،
Antigravity، OpenCode، Codex و Cline.

این مخزن طبق روش‌شناسی ریپوی مرجع `NTK.Agent.mem0/skills` نوشته و مدیریت می‌شود:
هر مهارت در `skills/<name>/` با `SKILL.md` (entry point)، `README.md`، `LICENSE`،
`references/` و (در صورت نیاز) `scripts/` قرار می‌گیرد. `SKILL.md` زیر ۵۰۰ خط
نگه داشته می‌شود و جزئیات در `references/` به‌صورت on-demand بارگذاری می‌شود.

## نصب

```bash
npx skills add https://github.com/akaravi/Karavi.Skills --skill karavi-folder
```

## مهارت‌ها

| مهارت | دسته | کارکرد |
|---|---|---|
| [`karavi-folder`](./skills/karavi-folder/) | Pipeline / caretaker | اسکلت استاندارد `karavi/` را می‌سازد (بخش ۱) و اطلاعات موقت — لاگ، کش، آرت‌فکت build/publish — را به‌شکل امن حذف می‌کند (بخش ۲). |

## انتخاب مهارت

- ساختار `karavi/` در یک مخزن لازم دارید؟ → `/karavi-folder create` (با `--full` برای فولدرهای اختیاری)
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
    └── scripts/          karavi-folder.create.ps1 · karavi-folder.clean.ps1
```

## License

Apache-2.0