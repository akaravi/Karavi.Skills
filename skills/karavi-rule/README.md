# karavi-rule

Skill مرکزی برای فعال‌سازی قانون جهانی Karavi، نصب اجباری سه skill پایه و
هدایت هر درخواست به صاحب درست آن.

در پاسخ‌های conversational این Skill، خطاب کاربر باید `رفیق جونم` باشد و در
code، log، metadata یا artifact درج نشود.

## مسئولیت

`karavi-rule` منبع canonical قوانین را فعال می‌کند و موجودبودن این سه skill
را در runtime بررسی می‌کند؛ نبود dependency نباید به‌عنوان نصب موفق گزارش شود:

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

### نصب خود `karavi-rule`

ابتدا خود Skill اصلی را نصب کنید:

```powershell
pnpm dlx skills add https://github.com/akaravi/Karavi.Skills --skill karavi-rule
```

پس از نصب، وجود و خوانایی فایل `SKILL.md` را در runtime Agent بررسی کنید.

نصب خود skill با فعال‌سازی global یکی نیست. اجرای init به PowerShell، دسترسی
نوشتن مقصدهای global و درخت canonical روی همان ماشین نیاز دارد. این skill
منبع قانون غایب را تولید یا با یک نسخهٔ حدسی جایگزین نمی‌کند و workflowهای
Council، Folder یا Judge را به‌جای صاحبشان اجرا نمی‌کند.

### نصب وابستگی‌های اجباری

`karavi-rule` برای اجرای کامل خود به این سه Skill وابسته است؛ هر سه را جداگانه
نصب و سپس Verify کنید:

```powershell
npx skills add https://github.com/akaravi/Karavi.Skills --skill karavi-council
npx skills add https://github.com/akaravi/Karavi.Skills --skill karavi-folder
npx skills add https://github.com/akaravi/Karavi.Skills --skill karavi-judge
```

فرمان‌های dependency بالا عین قرارداد canonical در
[`installation.md`](references/installation.md) هستند؛ در پروژه‌هایی که اجرای
Node با pnpm الزامی است، معادل هر خط `pnpm dlx skills add ... --skill <name>`
است. هر dependency جداگانه نصب و بررسی می‌شود؛ نصب گروهی نباید خطای یک مورد را
پنهان کند.

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
& .agents/skills/karavi-rule/scripts/karavi-rule.init.ps1 -Language en
```

نمونه از root پروژه و با فرض نصب در `.agents/skills/karavi-rule/` است؛ مسیر
واقعی skill را جایگزین کنید. `-Language fa` سطح global فارسی را انتخاب می‌کند.
helper پارامتر `-SourceRoot` برای ریشهٔ واقعی درخت canonical دارد و در آن
`Agent.Global.Rule\sync-global-rules.ps1` را فراخوانی می‌کند؛ خود helper موتور
Sync جداگانه‌ای نیست. `-NoBackup` فقط با پذیرش صریح از دست‌رفتن نسخهٔ قبلی مجاز
است. فایل‌های generated را دستی ویرایش نکنید.

این دستور فقط Sync رسمی را فراخوانی می‌کند، برای مقصدها backup می‌سازد و پس از
نوشتن hash، body، encoding و نبود sidecar قدیمی را verify می‌کند.

## خروجی و verification فعال‌سازی

Sync جدیدترین `assembledPrompt.v*.txt` را resolve می‌کند؛ مسیر نسخهٔ بالا هویت
منبع مستند فعلی است، نه مجوز ثابت‌کردن یک نسخهٔ قدیمی. نبود canonical source
یا Sync رسمی یعنی نصب ناقص است و نباید موفقیت گزارش شود.

گزارش فعال‌سازی باید مسیر و هویت source فعال، نتیجه و exit status هر سه نصب،
مسیر skillهای discoverشده، خوانایی UTF-8 و `name` دقیق `SKILL.md`، تصمیم routing
و next action با verifyMethod را ثبت کند. پیام خروجی initializer به‌تنهایی
جایگزین evidence بررسی hash/body/encoding مقصدها نیست.

برای dependency ناموجود، `decision-required` ثبت و فقط کار امن و غیرمخرب
مستقل از آن ادامه داده می‌شود. هیچ نصب یا init، مجوز دسترسی secret، Git mutation،
Deploy یا تغییر production نیست؛ مقدار credential یا raw log حساس در گزارش نیاید.
`karavi-prompt` در routing پرامپت مرتبط است، اما برخلاف سه skill پایه dependency
نصب اجباری این skill نیست.


## مراجع

- [`SKILL.md`](SKILL.md)
- [`references/installation.md`](references/installation.md)
- [`references/skill-routing.md`](references/skill-routing.md)
- [`references/coverage-matrix.md`](references/coverage-matrix.md)
- [`references/global-rules-complete.md`](references/global-rules-complete.md)
- [`references/migration.md`](references/migration.md)

## License

Apache-2.0
