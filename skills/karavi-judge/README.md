# karavi-judge

مهارت **quality / acceptance gate** برای بررسی مستقل نتیجهٔ implementation، plan
یا integrated delivery بر اساس evidence، معیارهای 7Expert و verdict نهایی Judge.
این skill برای جلوگیری از پذیرش ناقص و همچنین تبدیل blockerهای فنی به تصمیم‌های
مهم و قابل‌اجرا طراحی شده است؛ اختلاف advisory و findingهای low/medium به‌تنهایی
مانع ادامهٔ کار نیستند.

## پوشش

- Karavi به‌عنوان ورودی کاربر و orchestrator اصلی
- زنجیرهٔ `Karavi → judge-verdict → هفت expert`
- بررسی scope و acceptance criteria
- هفت expert مستقل، هرکدام برای یک حوزهٔ مشخص، زیر نظر Judge
- relevance mask واحد از fan-in هفت expert مستقل
- ارزیابی evidence، security، parity، contract، tests و budget
- بررسی failure scenario برای profileهای standard و critical
- طبقه‌بندی findingها با severity، confidence، impact و verify method
- تفکیک warning، degraded، block و fail
- ثبت اختلاف Agent Main، هفت expert، Customer و subagent بدون حل بی‌صدا
- Completion Envelope شامل Check 1، Check 2، Check 3 و JudgeVerdict
- verdict نهایی `accept|block|fail`
- route کردن improvement و new-scope بدون اجرای خودکار آن‌ها

## نصب

```bash
pnpm dlx skills add https://github.com/akaravi/Karavi.Skills --skill karavi-judge
```

## استفاده

در چت agent، زمانی از `/karavi-judge` استفاده کنید که یک plan، تغییر کد،
migration، release candidate یا خروجی چند agent باید قبل از تحویل مستقل بررسی شود.

نمونهٔ درخواست:

```text
/karavi-judge نتیجهٔ پیاده‌سازی و evidence تست‌های این scope را بررسی کن
```

این دستور در چت agent اجرا می‌شود، نه shell. پیش‌نیاز بررسی، packet مشخص از
scope، out-of-scope، profile و acceptance، نتیجهٔ Agent Main، فایل‌های تغییرکرده،
diff و evidence تازهٔ verification است. خروجی هفت expert مستقل و Customer در صورت
فعال‌شدن نیز باید در fan-in ثبت شود؛ evidence امنیت، parity، contract و budget
فقط در صورت ارتباط و وجود مقدار واقعی لازم است. نصب skill به‌خودی‌خود Botهای
میزبان یا دسترسی لازم را فراهم نمی‌کند؛ seat غایب باید صریحاً missing/degraded باشد.

برای نمونه، همراه درخواست بالا مسیر artifactهای نتیجه و تست، معیار پذیرش،
profile=`standard` و findingهای باز را ارائه کنید. نام یک command یا برنامهٔ
اجرای تست، نتیجهٔ واقعی محسوب نمی‌شود.

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

### roster اجباری expertها

هر حوزه یک Bot مستقل دارد و همه زیر نظر `judge-verdict` کار می‌کنند؛ خود
`judge-verdict` نیز زیرمجموعهٔ `Karavi` است:

| Bot | حوزه |
|---|---|
| `judge-management-business` | Management & Business |
| `judge-ux-ui` | UX/UI |
| `judge-frontend` | Frontend |
| `judge-backend-architecture` | Backend & Architecture |
| `judge-infrastructure-security` | Infrastructure & Security |
| `judge-quality-testing` | Quality & Testing |
| `judge-content-seo` | Content & SEO |

`judge-verdict` تنها Bot مجاز به صدور `accept|block|fail` است. Bot تجمیعی
`judge-7expert` معتبر نیست و نباید به‌جای هفت expert استفاده شود.

ورودی کاربر باید به Bot `Karavi` داده شود. Karavi یک packet واحد به
`judge-verdict` می‌دهد؛ Judge آن را بین هفت Expert توزیع می‌کند، موضع هرکدام را
(`approve|reject|abstain|degraded`) جمع می‌کند، رأی‌ها را مقایسه می‌کند و فقط
سپس verdict نهایی را به Karavi برمی‌گرداند.

Judge باید scope و evidence یکسان را مستقل برای هر هفت Bot ارسال کند، خروجی‌ها
را fan-in کند، missing/degraded را صریح ثبت کند و سپس verdict واحد صادر کند.

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

گزارش به‌صورت JSON یا جدول evidence-first ارائه می‌شود و حداقل `verdict`،
`lifecycle`، `profile`، `scope`، `relevanceMask`، `rubricStatus`، `findings`،
`failureScenario`، `newEvidence`، `openFindings`، `completionEnvelope`،
`resumeCondition` و `nextAction` را دارد. lifecycle با verdict یکی نیست.
نام هر هفت handle، relevance، position و evidence آن‌ها و owner بالادستی
Karavi باید دیده شود. در profileهای standard/critical حداقل یک مسیر منفی
واقعاً اجرا یا evidence آن بازرسی می‌شود؛ محیط ناموجود PASS نیست.

برای بررسی گزارش، [قرارداد evidence](references/evidence-contract.md) و
[envelope](references/completion-envelope.md) را با ورودی تطبیق دهید؛ فقط delta
نسبت به verdict قبلی دوباره بررسی می‌شود. در `judge-plan-loop` سقف cycleها
`quick=2`، `standard=4` و `critical=6` است و هر finding حداکثر دو تلاش اصلاح
توسط Agent Main دارد؛ Judge اصلاح‌کننده نیست.

ابهام منبع: بخش Verdict algorithm در `SKILL.md` خروجی دقیقاً یکی از
`accept|block|fail` می‌خواهد، اما برای finding فنی معمولاً `decision-required`
توصیه می‌کند؛ بخش circuit breaker نیز `block|fail` را بدون شرط صریح hard stop
می‌آورد. `decision-required` را وضعیت/action همراه decision packet ثبت کنید،
نه verdict چهارم، و این تعارض را در گزارش نگه دارید؛ از آن مجوز توقف یا accept
بدون evidence نسازید.


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
