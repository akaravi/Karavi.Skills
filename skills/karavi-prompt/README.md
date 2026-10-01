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
| `/karavi-prompt auto on` | فعال‌سازی خودکار تسلیح برای تمام ساب‌ایجنت‌ها | `& .\scripts\karavi-prompt.auto.ps1 -On` |
| `/karavi-prompt auto off` | بازگشت به حالت دستی و غیرفعال‌سازی تسلیح خودکار | `& .\scripts\karavi-prompt.auto.ps1 -Off` |
| `/karavi-prompt auto status` | مشاهده وضعیت فعلی رهگیری خودکار و ایجنت‌های هدف | `& .\scripts\karavi-prompt.auto.ps1 -Status` |

هنگامی که `auto on` است، ایجنت اصلی بدون نیاز به دستور مجدد کاربر، پرامپت ارسالی به subagent را ابتدا مهندسی، اسکن سکرت/تزریق و کادر‌بندی کرده و سپس ارسال می‌کند.

## نصب

```bash
npx skills add https://github.com/akaravi/Karavi.Skills --skill karavi-prompt
```

## استفاده

```powershell
# ۱) spec بنویس (الگو در references/templates.md)
# ۲) arm کن: guard + panel + ledger + متن dispatch
& .agents/skills/karavi-prompt/scripts/karavi-prompt.arm.ps1 -Spec .\spec.json -RepoRoot (Get-Location)

# guard را مستقل روی یک run ذخیره‌شده دوباره اجرا کن
& .agents/skills/karavi-prompt/scripts/karavi-prompt.guard.ps1 -Run <envelope.json>

# فقط کادر را دوباره رسم کن
& .agents/skills/karavi-prompt/scripts/karavi-prompt.panel.ps1 -Run <envelope.json> -Format Markdown

# ledger
& .agents/skills/karavi-prompt/scripts/karavi-prompt.ledger.ps1 -Id <runId> -Event closed -Outcome accept -Score 4.2

# پاک‌سازی runهای قدیمی (karavi-folder clean زیرپوشهٔ runs/ را نمی‌بیند)
& .agents/skills/karavi-prompt/scripts/karavi-prompt.ledger.ps1 -Purge -OlderThanDays 14 -WhatIf

# کادر ASCII برای ترمینالی که UTF-8 را نمی‌کشد
& .agents/skills/karavi-prompt/scripts/karavi-prompt.panel.ps1 -Run <envelope.json> -Ascii
```

# فعال و غیرفعال‌سازی خودکار تسلیح پرامپت‌ها به ساب‌ایجنت‌ها
& .agents/skills/karavi-prompt/scripts/karavi-prompt.auto.ps1 -On -Targets task,pm-builder
& .agents/skills/karavi-prompt/scripts/karavi-prompt.auto.ps1 -Off
& .agents/skills/karavi-prompt/scripts/karavi-prompt.auto.ps1 -Status

خروجی `arm.ps1`: کادر، سپس `RUN`، `VERDICT`، `ENVELOPE`، `PROMPT`، و پس از
`---DISPATCH---` خودِ متن مسلح‌شده. روی `block` هیچ کادری رسم نمی‌شود و فقط
یافته‌ها گزارش می‌شوند.

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
├── scripts/      guard · panel · arm · ledger · verify
└── tests/        Pester
```

## تأیید

```powershell
& .agents/skills/karavi-prompt/scripts/verify-karavi-prompt-skill.ps1
Invoke-Pester .agents/skills/karavi-prompt/tests
```

## مرتبط

- [`karavi-rule`](../karavi-rule/) — لایهٔ قوانین و routing
- [`karavi-council`](../karavi-council/) — تصمیم معماری و specification
- [`karavi-judge`](../karavi-judge/) — داوری نهایی بر اساس evidence
- [`karavi-terminal`](../karavi-terminal/) — مجوز mutation؛ کادر آن را جایگزین نمی‌کند
- [`karavi-folder`](../karavi-folder/) — ساختار `karavi/`؛ `clean` زیرپوشهٔ `karavi-prompt/runs/` را نمی‌بیند، برای آن `-Purge` همین skill را اجرا کن

## License

Apache-2.0
