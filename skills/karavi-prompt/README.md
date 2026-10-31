# karavi-prompt

مهارت **prompt arming pipeline** برای agentهای کدنویسی. هر پرامپتی که کاربر
می‌خواهد به یک agent بدهد، اول **مهندسی و بهینه‌سازی** می‌شود، سپس در یک **کادر
«در حال اجرا»** به کاربر نمایش داده می‌شود، و تنها پس از آن **مسلح‌شده** به agent
تحویل داده می‌شود.

```text
RAW → INTAKE → ENGINEER → GUARD → PANEL → DISPATCH → LEDGER
```

## چرا این skill وجود دارد

ارسال مستقیم متن خام به agent یعنی از دست دادن کنترل. سه چیز در این مسیر
گم می‌شود: **قالب خروجی** (agent خودش حدس می‌زند)، **مرز اعتماد** (محتوای فایل یا
URL می‌تواند خودش را دستور جا بزند)، و **معیار پایان** (کار تمام شده یا نه؟).
`karavi-prompt` هر سه را به یک قرارداد قابل بازرسی تبدیل می‌کند و پیش از هر
اجرا یک کادر نشان می‌دهد.

## چرخهٔ کار

| مرحله | کار |
|---|---|
| `INTAKE` | قرارداد نیت: goal، scope، outOfScope، constraints، acceptance، verifyMethod، target، untrusted |
| `ENGINEER` | ساخت پرامپت مسلح‌شده: ترتیب لایه‌ها، tag، تعریف عملیاتی، grounding، قالب خروجی، بودجهٔ توکن |
| `GUARD` | اسکن secret، injection، taint، قرارداد، placeholder، arm-delta، بودجه، portability، mode |
| `PANEL` | نمایش یک کادر شامل run، target، verdict، اندازه، digest و خودِ پرامپت مسلح‌شده |
| `DISPATCH` | ارسال عیناً همان متن مسلح‌شده، فقط به یک target |
| `LEDGER` | ثبت digest، verdict و outcome در `karavi-prompt.jsonl` |

## کادر «در حال اجرا»

```text
╔══════════════════════════════════════════════════════════════════════╗
║  KARAVI · PROMPT ARMED · IN EXECUTION                              ║
╠══════════════════════════════════════════════════════════════════════╣
║  RUN     : kp-20261001T081455Z-4f9ac2                             ║
║  STAGE   : DISPATCH   (RAW → ENGINEER → GUARD → PANEL)             ║
║  TARGET  : host=omp agent=task model=frontier mode=read-only       ║
║  GUARD   : PASS  secret=0 injection=0 taint=0 contract=ok          ║
║  SIZE    : raw=118 tok -> armed=402 tok (+241%)                   ║
║  DIGEST  : sha256:4f9ac2…                                         ║
╠══════════════════════════════════════════════════════════════════════╣
║  ARMED PROMPT                                                      ║
║  ─────────────                                                     ║
║  …                                                                 ║
╚══════════════════════════════════════════════════════════════════════╝
```

در hostهایی که shell ندارند، همان اطلاعات به شکل **markdown** (یا JSON) تولید
می‌شود. کادر، قرارداد است؛ اسکریپت فقط راحتی است، نه تنها پیاده‌سازی guard.

## قواعد سخت‌گیرانه

1. پرامپت خام هرگز dispatch نمی‌شود.
2. کادر پیش از dispatch اجباری است.
3. guard **fail-closed** است: هر یافتهٔ `block` اجرا را متوقف می‌کند.
4. secret هرگز وارد کادر، ledger یا dispatch نمی‌شود؛ به `[REDACTED]` تبدیل می‌شود.
5. دادهٔ untrusted همیشه داخل tag برچسب‌خورده و فقط-داده تعریف می‌شود.
6. dispatch دقیقاً همان متن مسلح‌شده است — نه خلاصه، نه بازآرایی.
7. mode در کادر اعلام می‌شود؛ کادر مجوز mutation جایگزین `karavi-terminal` نمی‌شود.
8. هر اجرا یک خط در ledger ثبت می‌کند؛ run بسته‌نشده به eval set کمک نمی‌کند.

## حالت خودکار (auto on / auto off)

`karavi-prompt` علاوه بر اجرای دستی، از مکانیزم **هدایت خودکار (Auto Mode)** پشتیبانی می‌کند تا قبل از dispatch هر پرامپتی به subagentها، خودکار مسلح و مهار شود:

| دستور چت | اثر | معادل اسکریپتی |
|---|---|---|
| `/karavi-prompt auto on` | فعال‌سازی سیاست تسلیح برای subagentها | `karavi-prompt.auto.ps1 -On` |
| `/karavi-prompt auto off` | بازگشت به حالت دستی | `karavi-prompt.auto.ps1 -Off` |
| `/karavi-prompt auto status` | مشاهدهٔ state و targetها | `karavi-prompt.auto.ps1 -Status` |

هنگامی که `auto on` است، ایجنت اصلی بدون نیاز به دستور مجدد کاربر، پرامپت ارسالی به subagent را ابتدا مهندسی، اسکن سکرت/تزریق و کادر‌بندی کرده و سپس ارسال می‌کند.

helper فقط state را ذخیره/نمایش می‌دهد؛ نصب hook عمومی در همهٔ hostها انجام
نمی‌دهد. رعایت این state و عبور dispatch از pipeline مسئولیت agent/adapter میزبان
است. Auto Mode مجوز mutation، network یا دورزدن guard نیست.

## نصب

```bash
pnpm dlx skills add https://github.com/akaravi/Karavi.Skills --skill karavi-prompt
```

## استفاده

برای helperها PowerShell و دسترسی به فایل‌های skill لازم است. نمونه‌ها از root
repository و با فرض نصب در `.agents/skills/karavi-prompt/` هستند؛ مسیر واقعی نصب
را جایگزین کنید. بدون shell، agent باید guard را اعمال و panel markdown را طبق
[قرارداد panel](references/panel-and-dispatch.md) تولید کند. این skill جایگزین
ویرایش معمول کد یا verdict پذیرش `karavi-judge` نیست.

قبل از `arm`، spec را مطابق [schema واقعی](references/arming-pipeline.md#spec-schema)
بسازید: `rawPrompt` و `armedPrompt`، `intent` شامل goal، scope، outOfScope،
constraints، acceptance، verifyMethod و untrusted و نیز `target` در سطح بالای
JSON با host، agent، model و mode. helper متن خام را خودش مهندسی نمی‌کند؛
agent باید `armedPrompt` کامل را پیش از اجرای آن آماده کند. spec نیز نباید secret
داشته باشد؛ guard مجوز ذخیرهٔ credential در فایل ورودی نیست.

```powershell
# ۱) spec بنویس (الگو در references/templates.md)
# ۲) arm کن: guard + panel + ledger + متن dispatch
& .agents/skills/karavi-prompt/scripts/karavi-prompt.arm.ps1 -Spec .\spec.json -RepoRoot (Get-Location)

# مقدارهای نمونه را با مسیر ENVELOPE و شناسهٔ RUN خروجی بالا جایگزین کنید
$envelopePath = '.\path-to-returned-envelope.json'
$runId = 'returned-run-id'

# guard را مستقل روی یک run ذخیره‌شده دوباره اجرا کن
& .agents/skills/karavi-prompt/scripts/karavi-prompt.guard.ps1 -Run $envelopePath

# فقط کادر را دوباره رسم کن
& .agents/skills/karavi-prompt/scripts/karavi-prompt.panel.ps1 -Run $envelopePath -Format Markdown

# ledger
& .agents/skills/karavi-prompt/scripts/karavi-prompt.ledger.ps1 -Id $runId -Event closed -Outcome accept -Score 4.2

# پاک‌سازی runهای قدیمی (karavi-folder clean زیرپوشهٔ runs/ را نمی‌بیند)
& .agents/skills/karavi-prompt/scripts/karavi-prompt.ledger.ps1 -Purge -OlderThanDays 14 -WhatIf

# کادر ASCII برای ترمینالی که UTF-8 را نمی‌کشد
& .agents/skills/karavi-prompt/scripts/karavi-prompt.panel.ps1 -Run $envelopePath -Ascii

# فعال و غیرفعال‌سازی خودکار تسلیح پرامپت‌ها به ساب‌ایجنت‌ها
& .agents/skills/karavi-prompt/scripts/karavi-prompt.auto.ps1 -On -Targets task,pm-builder
& .agents/skills/karavi-prompt/scripts/karavi-prompt.auto.ps1 -Off
& .agents/skills/karavi-prompt/scripts/karavi-prompt.auto.ps1 -Status
```

خروجی `arm.ps1`: کادر، سپس `RUN`، `VERDICT`، `ENVELOPE`، `PROMPT`، و پس از
`---DISPATCH---` خودِ متن مسلح‌شده. روی `block` هیچ کادری رسم نمی‌شود و فقط
یافته‌ها گزارش می‌شوند.

helper فقط متن dispatch را **خروجی می‌دهد**؛ فراخوانی agent هدف بر عهدهٔ میزبان
است. مثال panel بالا نمایشی است و نتیجهٔ تست یا اجرای واقعی نیست. روی `pass|warn`
ابتدا panel را نمایش دهید و سپس همان متن را به یک target بدهید؛ تغییر متن یا
target نیاز به re-arm، digest و panel تازه دارد.

artifactها شامل envelope، متن خام، armed text و panel در
`karavi.temp.status/karavi-prompt/runs/` و ledger در
`karavi.temp.status/karavi-prompt/karavi-prompt.jsonl` هستند. پس از پاسخ target،
run را با outcome واقعی ببندید؛ score نمونه فقط در صورت ارزیابی واقعی استفاده شود.
`-Purge -WhatIf` صرفاً preview است؛ حذف واقعی نیازمند مجوز است و ledger را پاک نمی‌کند.

## کدهای خروجی

| کد | معنی |
|---|---|
| `0` | `pass` — کادر رسم شد، dispatch آزاد است |
| `1` | `block` — secret، injection یا mode؛ چیزی dispatch نشد |
| `2` | `warn` — کادر با یافته‌ها رسم شد؛ dispatch مجاز است |
| `3` | خطای ورودی — spec ناقص، فایل ناخوانا، JSON نامعتبر |

## دانش تجمیع‌شده

محتوای `references/` از مجموعهٔ مهارت‌های prompt-engineering استخراج و بازساخت
شده است: معماری هفت‌لایه، ساختاردهی XML، playbook بهینه‌سازی، کاتالوگ
anti-pattern، طراحی constraint و guardrail، مدل اعتماد و injection، grounding و
RAG، پرامپت ابزار و agent، CoT و chaining، و rubric ارزیابی هشت‌بُعدی.

| فایل | موضوع |
|---|---|
| [arming-pipeline.md](references/arming-pipeline.md) | قرارداد مرحله‌ها، schema spec و envelope، state machine |
| [panel-and-dispatch.md](references/panel-and-dispatch.md) | مشخصات کادر، فرم markdown، host adapterها، dispatch |
| [prompt-architecture.md](references/prompt-architecture.md) | هفت لایه، XML در برابر markdown، ترتیب |
| [optimization-playbook.md](references/optimization-playbook.md) | کلاس مدل، کاتالوگ تکنیک، بودجهٔ توکن، فشرده‌سازی |
| [anti-patterns.md](references/anti-patterns.md) | کاتالوگ نقص‌ها با اصلاح |
| [constraints-and-guardrails.md](references/constraints-and-guardrails.md) | طیف constraint، meta-rule، guardrail، تست |
| [security-and-injection.md](references/security-and-injection.md) | مدل taint، لایه‌های دفاع، red-team |
| [grounding-and-context.md](references/grounding-and-context.md) | quote-then-answer، context بلند، project map |
| [agent-and-tool-prompts.md](references/agent-and-tool-prompts.md) | ابزار، دوام multi-turn، handoff |
| [reasoning-and-chaining.md](references/reasoning-and-chaining.md) | سطح CoT، chaining، اعتبارسنجی بین‌مرحله‌ای |
| [evaluation-and-scoring.md](references/evaluation-and-scoring.md) | rubric هشت‌بُعدی، eval set، A/B، regression |
| [templates.md](references/templates.md) | اسکلت پرامپت مسلح‌شده برای هر کلاس |

## ساختار فایل

```text
skills/karavi-prompt/
├── SKILL.md      نقطهٔ ورود، تصمیم‌گیری و قرارداد
├── README.md     مستندات کاربر
├── LICENSE       Apache-2.0
├── references/   بارگذاری on-demand، یک فایل برای هر موضوع
├── scripts/      guard · panel · arm · ledger · auto · verify
└── tests/        Pester
```

## تأیید

```powershell
& .agents/skills/karavi-prompt/scripts/verify-karavi-prompt-skill.ps1
Invoke-Pester .agents/skills/karavi-prompt/tests
```

این‌ها روش‌های verification برای نصب محلی‌اند، نه ادعای موفقیت اجرا. علاوه بر
ساختار، acceptance هر run نیازمند intent کامل، untrusted برچسب‌خورده، guard بدون
block، panel پیش از dispatch، متن یکسان و outcome ثبت‌شده است. guard تشخیص
الگویی است، نه تضمین کشف همهٔ secretها یا injectionها؛ قضاوت مهندسی همچنان لازم است.


## مرتبط

- [`karavi-rule`](../karavi-rule/) — لایهٔ قوانین و routing
- [`karavi-council`](../karavi-council/) — تصمیم معماری و specification
- [`karavi-judge`](../karavi-judge/) — داوری نهایی بر اساس evidence
- [`karavi-terminal`](../karavi-terminal/) — مجوز mutation؛ کادر آن را جایگزین نمی‌کند
- [`karavi-folder`](../karavi-folder/) — ساختار `karavi/`؛ `clean` زیرپوشهٔ `karavi-prompt/runs/` را نمی‌بیند، برای آن `-Purge` همین skill را اجرا کن

## License

Apache-2.0
