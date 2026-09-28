# karavi-council

مهارت **planning-first** برای تبدیل درخواست‌های مبهم، معماری‌های حساس و تغییرات
چندبخشی به یک تصمیم فنی مستند و plan قابل‌اجرا، قبل از شروع implementation.
این skill از شواهد repository، مستندات رسمی، تحلیل گزینه‌ها، red-team، ADR و
بررسی آمادگی استفاده می‌کند و در مرحلهٔ readiness متوقف می‌شود.

## پوشش

- context sweep و ثبت brief، context و assumption ledger
- تفکیک نقش‌های Chair / Agent Main، Principal، Adversary و Customer
- framing مستقل مسئله و تعریف scope / out-of-scope
- مقایسهٔ گزینه‌های واقعی با trade-off، هزینه، امنیت، migration و rollback
- red-team، pre-mortem و ثبت residual risk
- تصمیم‌های معماری الزام‌آور و ADR با evidence و invalidation condition
- specification شامل contract، failure path، i18n، theme، accessibility و acceptance
- plan چندبخشی با dependency، owner، file، command، test و micro-step
- fresh-context executor simulation برای بخش‌های پرریسک
- readiness gate و تحویل plan بدون اجرای کد

## نصب

```bash
npx skills add https://github.com/akaravi/Karavi.Skills --skill karavi-council
```

## استفاده

در چت agent، زمانی از `/karavi-council` استفاده کنید که تصمیم فنی، طراحی
معماری، migration، چند consumer، ریسک امنیتی یا چند مسیر اجرایی نیاز به
برنامه‌ریزی مستند قبل از کدنویسی دارد.

نمونهٔ درخواست:

```text
/karavi-council برای تغییر قرارداد API و مهاجرت consumerها یک plan آماده کن
```

## خروجی و ساختار فایل‌ها

خروجی در مسیر زیر قرار می‌گیرد:

```text
docs/planning/<YYYY-MM-DD>-<slug>/
├── _state.md
├── 00-brief.md
├── 01-context.md
├── 02-assumptions.md
├── 03-approaches.md
├── 04-risks.md
├── 05-decisions.md
├── 06-spec.md
├── 07-plan.md
├── 08-readiness.md
└── _work/                 transcript و خروجی‌های میانی
```

هر Part باید scope، prerequisite، dependency، owner، فایل‌های دقیق، action،
expected result، verify method، rollback و completion criteria داشته باشد.

## خودکارسازی تصمیم و مرز Block

- تصمیم فنی داخل scope با Agent Main و بر اساس evidence گرفته و اجرا می‌شود.
- اختلاف advisory، findingهای `info|low|medium` و in-scope improvement به‌صورت
  finding یا route ثبت می‌شوند و به‌تنهایی workflow را متوقف نمی‌کنند.
- new-scope جداگانه گزارش می‌شود و بدون دستور اجرا نمی‌شود.
- فقط defect اثبات‌شدهٔ `high|critical`، نبود prerequisite/evidence ضروری یا
  تصمیم واقعاً user-owned می‌تواند Block ایجاد کند.
- نبودن seat اختیاری با وضعیت `degraded` ثبت می‌شود؛ نتیجهٔ ساختگی تولید نمی‌شود.
- سؤال کاربر فقط برای تصمیمی مجاز است که هم blocking و غیرقابل استنتاج باشد،
  هر دو مسیر فنی نتوانند resolve کنند و هزینهٔ خطا مادی باشد.

## مرز ایمنی

این skill مجوز implementation، commit، push، merge، Deploy، FTP، تغییر production،
دریافت secret یا گسترش scope را ایجاد نمی‌کند. در پایان readiness، plan و blockerهای
واقعی تحویل داده می‌شوند و اجرای کد به مرحلهٔ جداگانه منتقل می‌شود.

## منابع

جزئیات قرارداد artifactها و resilience در مسیرهای زیر به‌صورت on-demand بارگذاری
می‌شوند:

- [`references/artifacts.md`](references/artifacts.md) — قرارداد state، artifact و Part
- [`references/prompts-and-resilience.md`](references/prompts-and-resilience.md) — prompt seatها و رفتار degraded
- [`references/cli-invocation.md`](references/cli-invocation.md) — اجرای read-only و مدیریت sessionهای seatها
- [`references/host-adapters.md`](references/host-adapters.md) — قرارداد قابلیت‌های harness میزبان
- [`references/quality-gates.md`](references/quality-gates.md) — readiness gate و handoff checklist
- [`references/resilience.md`](references/resilience.md) — timeout، rotation، quorum، pause و resume
- [`SKILL.md`](SKILL.md) — entry point و قواعد اصلی تصمیم‌گیری

## License

Apache-2.0
