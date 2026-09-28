# karavi-judge

مهارت **quality / acceptance gate** برای بررسی مستقل نتیجهٔ implementation، plan
یا integrated delivery بر اساس evidence، معیارهای 7Expert و verdict نهایی Judge.
این skill برای جلوگیری از پذیرش ناقص و همچنین تبدیل blockerهای فنی به تصمیم‌های
مهم و قابل‌اجرا طراحی شده است؛ اختلاف advisory و findingهای low/medium به‌تنهایی
مانع ادامهٔ کار نیستند.

## پوشش

- بررسی scope و acceptance criteria
- relevance mask واحد برای هر هفت حوزهٔ 7Expert
- ارزیابی evidence، security، parity، contract، tests و budget
- بررسی failure scenario برای profileهای standard و critical
- طبقه‌بندی findingها با severity، confidence، impact و verify method
- تفکیک warning، degraded، block و fail
- ثبت اختلاف Agent Main، 7Expert، Customer و subagent بدون حل بی‌صدا
- Completion Envelope شامل Check 1، Check 2، Check 3 و JudgeVerdict
- verdict نهایی `accept|block|fail`
- route کردن improvement و new-scope بدون اجرای خودکار آن‌ها

## نصب

```bash
npx skills add https://github.com/akaravi/Karavi.Skills --skill karavi-judge
```

## استفاده

در چت agent، زمانی از `/karavi-judge` استفاده کنید که یک plan، تغییر کد،
migration، release candidate یا خروجی چند agent باید قبل از تحویل مستقل بررسی شود.

نمونهٔ درخواست:

```text
/karavi-judge نتیجهٔ پیاده‌سازی و evidence تست‌های این scope را بررسی کن
```

## حالت‌های بررسی

| Profile | روش بررسی |
|---|---|
| `quick` | relevance mask داخلی و خلاصهٔ یک‌خطی؛ failure scenario فقط در صورت ریسک |
| `standard` | جدول فشرده برای حوزه‌های relevant و حداقل یک failure scenario |
| `critical` | بررسی کامل هفت حوزه، failure scenario و تمام gateهای مرتبط |

هفت حوزه همیشه در mask حضور دارند:

1. Management & Business
2. UX/UI
3. Frontend
4. Backend & Architecture
5. Infrastructure & Security
6. Quality & Testing
7. Content & SEO

فقط حوزه‌های `relevant` تحلیل عمیق و `verifyMethod` تولید می‌کنند؛ حوزه‌های
`not-relevant` با دلیل کوتاه ثبت می‌شوند.

## معیار Block

- findingهای `info|low|medium` ثبت و route می‌شوند و به‌تنهایی Block نیستند.
- اختلاف Customer یا 7Expert به‌تنهایی Block نیست؛ فقط اختلاف حل‌نشده‌ای که
  acceptance، امنیت، contract، parity یا یکپارچگی داده را واقعاً ناممکن کند، Block است.
- defect `high|critical` با evidence معتبر و مرتبط با scope یک تصمیم مهم ایجاد
  می‌کند تا Agent Main بهترین remediation، fallback، rollback یا گزینهٔ حفظ scope
  را انتخاب کند؛ فقط hard safety/authorization stop می‌تواند اجرای پروژه را متوقف کند.
- missing evidence فقط وقتی Block است که یک gate ضروری باشد یا پذیرش نتیجه بدون
  آن از نظر ایمنی ممکن نباشد.
- new-scope گزارش می‌شود و به scope فعلی وارد نمی‌شود.
- نبودن seat یا tool اختیاری به‌عنوان `degraded` ثبت می‌شود، نه product failure.
- هر blocker فنی باید به decision packet شامل evidence، گزینه‌ها، trade-off،
  owner، action، verify method و residual risk تبدیل شود.

## Completion Envelope

خروجی نهایی باید یک envelope واحد با بخش‌های زیر باشد:

```text
Check 1 — scopeComplete
Check 2 — crossSectionComplete
Check 3 — 7ExpertSummary
JudgeVerdict
```

هر بخش باید status، evidence جدید و action داشته باشد. `accept` فقط زمانی مجاز
است که scope و cross-section کامل باشند، gateهای ضروری پاس شده باشند و finding
blocking باز وجود نداشته باشد. پس از accept حداکثر پنج next action معتبر و خارج
از scope نمایش داده می‌شود.

## مرز ایمنی

این skill مجوز implementation، اصلاح خودکار، commit، push، merge، Deploy، FTP،
افشای secret یا گسترش scope را ایجاد نمی‌کند. Judge فقط fan-in را ارزیابی می‌کند؛
کار را اجرا نمی‌کند و تست‌های بدون تغییر را تکرار نمی‌کند.

## منابع

جزئیات بررسی حوزه‌ها و rubric در مسیرهای زیر به‌صورت on-demand بارگذاری می‌شوند:

- [`references/relevance-mask.md`](references/relevance-mask.md) — معیار انتخاب حوزه‌های 7Expert
- [`references/verdict-rubric.md`](references/verdict-rubric.md) — severity، disagreement و failure scenario
- [`references/evidence-contract.md`](references/evidence-contract.md) — قرارداد ورودی، finding و evidence
- [`references/completion-envelope.md`](references/completion-envelope.md) — قرارداد Completion Envelope و gate نهایی
- [`references/resilience.md`](references/resilience.md) — lifecycle، cycle limit، degraded و resume
- [`SKILL.md`](SKILL.md) — entry point و قرارداد Judge

## License

Apache-2.0
