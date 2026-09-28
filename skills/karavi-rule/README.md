# karavi-rule

Skill مرکزی برای فعال‌سازی قانون جهانی Karavi، نصب اجباری سه skill پایه و
هدایت هر درخواست به صاحب درست آن.

در پاسخ‌های conversational این Skill، خطاب کاربر باید `رفیق جونم` باشد و در
code، log، metadata یا artifact درج نشود.

## مسئولیت

`karavi-rule` منبع canonical قوانین را فعال می‌کند و تضمین می‌کند این سه skill
در runtime موجود باشند:

- `karavi-council` برای plan، معماری، گزینه‌ها، ADR و readiness؛
- `karavi-folder` برای ساختار، migration و cleanup فولدرهای workspace؛
- `karavi-judge` برای review مستقل، evidence gate و verdict نهایی.

قوانین cross-cutting مانند scope، secret، Git، Deploy/FTP، encoding، امنیت،
i18n و accessibility در Global Rule باقی می‌مانند. رویه‌هایی که با سه skill
هم‌پوشانی دارند در v4 حذف و به استفاده از skill مربوط واگذار شده‌اند.

برای جلوگیری از حذف ناخواسته قانون، متن کامل قوانین در
[`references/global-rules-complete.md`](references/global-rules-complete.md) و مالکیت
و مسیر فعال‌سازی تمام ۱۲۲ rule ID در
[`references/coverage-matrix.md`](references/coverage-matrix.md) نگهداری می‌شود.
هیچ rule ID صرفاً به‌دلیل نبودن در v4 حذف‌شده تلقی نمی‌شود.

## نصب

```powershell
npx skills add https://github.com/akaravi/Karavi.Skills --skill karavi-council
npx skills add https://github.com/akaravi/Karavi.Skills --skill karavi-folder
npx skills add https://github.com/akaravi/Karavi.Skills --skill karavi-judge
```

هر سه دستور باید جداگانه اجرا و سپس از نظر وجود و خوانایی `SKILL.md` بررسی
شوند. نصب این skill مجوز commit، push، Deploy، FTP، تغییر production یا scope
جدید ایجاد نمی‌کند.

## منبع قانون

```text
D:\SourceKaravi\Agents.Project\Agent.Global.Rule\assembledPrompt.v4.0.1.txt
```

پس از ایجاد منبع، Sync رسمی باید اجرا شود تا همه Agentها از یک hash و body
استفاده کنند. `block` برای هر اختلاف فنی به‌صورت خودکار توقف نیست؛ ابتدا باید
به decision packet با evidence، گزینه‌ها، تصمیم، owner، action، verifyMethod و
ریسک باقی‌مانده تبدیل شود. فقط hard safety/authorization stop می‌تواند اجرای
کار را متوقف کند.

## مقداردهی اولیه Global

برای قرار دادن قوانین در Global همه Agentهای پشتیبانی‌شده، دستور زیر را اجرا
کنید:

```powershell
/karavi-rule init
```

معادل PowerShell آن:

```powershell
& .\scripts\karavi-rule.init.ps1 -Language en
```

این دستور فقط Sync رسمی را فراخوانی می‌کند، برای مقصدها backup می‌سازد و پس از
نوشتن hash، body، encoding و نبود sidecar قدیمی را verify می‌کند.

## مراجع

- [`SKILL.md`](SKILL.md)
- [`references/installation.md`](references/installation.md)
- [`references/skill-routing.md`](references/skill-routing.md)
- [`references/coverage-matrix.md`](references/coverage-matrix.md)
- [`references/global-rules-complete.md`](references/global-rules-complete.md)
- [`references/migration.md`](references/migration.md)

## License

Apache-2.0
