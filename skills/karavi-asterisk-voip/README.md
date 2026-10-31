# karavi-asterisk-voip

مرجع جامع، مهندسی‌شده و **نسخه‌آگاه (Version-Aware)** برای توسعه، راه‌اندازی، اتصال برنامه‌های سازمانی، تست و عیب‌یابی سامانه‌های تلفنی مبتنی بر **Asterisk و VoIP**.

- **نسخه کانونیکال مرجع:** `Asterisk 22 LTS`
- **سازگاری و ارتقا:** راهنماهای جداگانه برای Asterisk 16، 20، 23 و 24؛ وجود راهنما تضمین سازگاری هر ماژول یا کتابخانه با همهٔ نسخه‌ها نیست.

این مهارت راهنمای دامنه برای برنامه‌نویسان و مهندسان مخابرات است، نه PBX نصب‌شونده یا کتابخانهٔ کلاینت. قراردادهای برنامه، authorization و persistence جای خود را به تنظیمات Asterisk نمی‌دهند. مرجع تصمیم‌گیری و مسیریابی کامل در [SKILL.md](SKILL.md) است.

---

## ۱. ساختار مهارت و دسته‌بندی موضوعی

```text
skills/karavi-asterisk-voip/
├── SKILL.md              نقطه ورود، چک‌لیست‌ها و قواعد تصمیم‌گیری
├── README.md             مستندات اصلی، دستورات و مثال‌های کاربردی
└── references/           مرجع‌های تخصصی بر اساس تفکیک دامنه‌ها:
    ├── pjsip-sip.md                      پیکربندی مدرن PJSIP، ترانک و Endpoint
    ├── ari.md / ari-dotnet-*.md          رابط REST و WebSocket برای کنترل کامل تماس
    ├── ami.md / ami-dotnet-*.md          رویدادها و مانیتورینگ بلادرنگ تماس‌ها با AMI
    ├── agi-fastagi.md                    پردازش اسکریپتی و FastAGI سرور در دات‌نت
    ├── dialplan-ivr.md                   سناریوهای صف، تلفن‌گویا و مسیریابی تماس
    ├── sip-wss-webrtc-webphone.md        تلفن‌های تحت وب و اتصال مرورگر با WebRTC/WSS
    ├── media-webrtc-advanced.md          کدک‌ها، SRTP و بهینه‌سازی رسانه
    ├── security-hardening.md             امن‌سازی پورت‌ها، Fail2ban و فایروال
    ├── testing-sipp-load-faults.md       تست فشار با SIPp و شبیه‌سازی خطا
    └── troubleshooting-runbooks.md       راهنماهای رفع اشکال گام‌به‌گام و اشکال‌یابی
```

---

## ۲. پیش‌نیاز و استفادهٔ عملی

برای مطالعه فقط یک agent با قابلیت خواندن skill لازم است. پیش از پیاده‌سازی یا اتصال زنده، این اطلاعات را از پروژه و محیط واقعی تعیین کنید:

- نسخهٔ دقیق Asterisk/FreePBX، سیستم‌عامل، topology، channel driver (`PJSIP` یا `chan_sip`) و ماژول‌های فعال.
- transport، سیاست codec، مسیر SIP/RTP و NAT، endpoint یا trunk آزمایشی و حساب کم‌اختیار مجاز.
- زبان، نسخهٔ runtime و کتابخانهٔ adapter پروژه؛ .NET، Python، Node.js، SIPp یا Test Suite فقط برای سناریوی مربوط لازم‌اند، نه همهٔ مصرف‌کنندگان.
- scope محیط، مجوز عملیات، قرارداد خطا و دادهٔ برنامه، سیاست recording/PII و rollback.

مهارت را برای طراحی، پیاده‌سازی، review یا عیب‌یابی AMI/ARI/AGI، dialplan، صف و media به‌کار ببرید. برای نصب عمومی سیستم‌عامل، مدیریت رمزها یا اعمال خودکار تغییر production به آن تکیه نکنید.

### سناریو ۱: طراحی ترانک PJSIP

```text
با karavi-asterisk-voip تنظیمات PJSIP این پروژه را بررسی کن.
ابتدا نسخه، transport، NAT و codec policy را از شواهد موجود مشخص کن.
فقط طرح endpoint/AOR/auth/registration و تست‌های لازم را پیشنهاد بده؛
هیچ فایل سرور، reload، registration یا تماس واقعی را اجرا نکن.
```

از [PJSIP پایه](references/pjsip-sip.md)، [ترانک و failover](references/pjsip-advanced.md) و [مدل configuration](references/configuration-model.md) شروع کنید. مقادیر provider و secret باید از تنظیمات مجاز بیایند؛ نوشتن `password=ENV_TELCO_SECRET` به‌خودی‌خود environment expansion ایجاد نمی‌کند. فایل‌های تولیدشدهٔ FreePBX را دستی بازنویسی نکنید.

### سناریو ۲: FastAGI در .NET

برای hosting، framing و shutdown از [FastAGI hosted service](references/fastagi-dotnet-hosted-service.md) و [قرارداد AGI](references/agi-fastagi.md) استفاده کنید. نمونهٔ [حلقهٔ فرمان](references/code-examples.md) الگوی adapter است، نه برنامهٔ آمادهٔ production: خواندن environment تا خط خالی، تفسیر نتیجهٔ هر فرمان، cancellation/hangup، deadline و disposal باید مطابق پروژه آزموده شود. Caller ID را در لاگ خام ننویسید و listener را بدون ACL عمومی نکنید.

### سناریو ۳: ARI، WebSocket و Stasis

```text
برای adapter فعلی پروژه، جریان StasisStart تا playback و Hangup را طراحی کن.
قرارداد REST و WebSocket، correlation، reconnect و cleanup را جدا ثبت کن؛
احراز هویت از secret store پروژه باشد و URL حاوی credential وارد لاگ نشود.
فقط تغییرات محلی و تست‌های قرارداد؛ تماس زنده یا تغییر PBX مجاز نیست.
```

راهنماهای [ARI](references/ari.md)، [ARI در .NET](references/ari-dotnet-websocket-stasis.md) و [نمونه‌های پیاده‌سازی](references/code-examples.md) را با نسخه و کتابخانهٔ واقعی تطبیق دهید. موفقیت درخواست playback یا AMI Originate فقط پذیرش عملیات است؛ رویدادها و media باید نتیجهٔ واقعی را ثابت کنند.

### سناریو ۴: عیب‌یابی Read-Only در Linux

این فرمان‌ها فقط در شل محیط مجاز دارای Asterisk و دسترسی CLI اجرا می‌شوند؛ خروجی ممکن است شناسهٔ تماس یا endpoint داشته باشد و باید قبل از اشتراک ماسک شود:

```bash
asterisk -rx "core show version"
asterisk -rx "pjsip show endpoints"
asterisk -rx "core show channels"
asterisk -rx "pjsip show channelstats"
```

خروجی به نسخه و ماژول‌ها وابسته است. آمار channel فقط یک شاهد است، نه اثبات صدای دوطرفه. packet capture با `sngrep`/`tcpdump` فایل و دادهٔ حساس تولید می‌کند؛ مقصد، مدت، فیلتر، retention و مجوز آن را پیش از اجرا تعیین کنید. دستورات دقیق تشخیص در [مرجع Linux](references/linux-asterisk-command-reference.md) و [runbookها](references/troubleshooting-runbooks.md) آمده‌اند.

---

## ۳. دستورات پرکاربرد استریسک در CLI

| دستور | کاربرد | نمونه خروجی مورد انتظار |
|---|---|---|
| `pjsip show endpoints` | وضعیت تمام شماره‌های داخلی و خطوط | نام، وضعیت (Avail/Unavailable) و AOR |
| `core show channels` | تعداد تماس‌های فعال در لحظه | لیست لاین‌ها و کانال‌های فعال در حال مکالمه |
| `queue show <queue_name>` | وضعیت صف، اپراتورها و تماس‌گیرندگان در صف | لیست کاربران لاگین‌شده و تماس‌های منتظر |
| `module reload res_pjsip.so` | درخواست reload ماژول؛ تغییر وضعیت و نیازمند مجوز صریح | خروجی و اثر وابسته به نسخه/تنظیم؛ تضمین بی‌قطعی نیست |
| `logger reload` | اعمال دوبارهٔ تنظیمات logger؛ نیازمند مجوز | نتیجهٔ reload؛ معادل تضمین چرخش لاگ نیست |

---

## ۴. مرزهای ایمنی و امنیت مخابراتی (Security Safeguards)

1. **جلوگیری از Toll Fraud:** دسترسی تماس‌های بین‌المللی یا ترانک‌های خروجی نباید در کانتکست‌های پیش‌فرض مثل `default` یا `from-sip` باز باشد.
2. **جداسازی شبکه مدیا و سیگنالینگ:** محدودهٔ RTP را از `rtp.conf` واقعی کشف و به peers مجاز محدود کنید؛ `10000-20000` صرفاً یک نمونهٔ رایج است.
3. **عدم افشای سکرت‌ها:** credential، شمارهٔ کامل، recording و PII در Git، chat، fixture و لاگ قرار نگیرد؛ روش تزریق امن باید واقعاً توسط deployment پروژه پشتیبانی شود.
4. **تغییرات Live PBX:** هر reload، restart، Originate، transfer، تغییر credential یا فایروال مجوز صریح همان محیط و عملیات را می‌خواهد؛ نصب مهارت مجوز اجرا نیست.
5. **کنترل تماس:** retry محدود و فقط برای عملیات امن، idempotency و correlation، I/O قابل لغو، UTC و cleanup را در مرز adapter رعایت کنید.

---

## ۵. نصب مهارت

```bash
pnpm dlx skills add https://github.com/akaravi/Karavi.Skills --skill karavi-asterisk-voip
```

این نمونه نیازمند Node.js و `pnpm` موجود و اجازهٔ تغییر کاتالوگ محلی است. نصب skill، Asterisk، FreePBX، runtime، trunk یا ابزارهای تست را نصب/پیکربندی نمی‌کند. مسیر نصب، [SKILL.md](SKILL.md) و references را پس از نصب بررسی کنید؛ سپس نام مهارت و سناریوی موردنظر را در درخواست agent بیاورید.

## ۶. خروجی، شواهد و ارزیابی

خروجی کار باید نسخه و فرض‌ها، adapter و consumerهای متاثر، تغییرات code/config، کلیدهای configuration بدون مقدار محرمانه، ریسک/rollback و وضعیت واقعی تست‌ها را مشخص کند. این skill فایل خروجی ثابت یا PBX آماده تولید نمی‌کند؛ نمونه‌های مرجع الگو هستند.

بررسی‌های ساختاری زیر با Python 3 دارای پشتیبانی type annotationهای به‌کاررفته در اسکریپت‌ها، از ریشهٔ مخزن قابل اجرا هستند:

```bash
python skills/karavi-asterisk-voip/scripts/verify-doc-coverage.py --skill skills/karavi-asterisk-voip --matrix skills/karavi-asterisk-voip/references/coverage-matrix.md
python skills/karavi-asterisk-voip/scripts/verify-examples.py --skill skills/karavi-asterisk-voip
```

اسکریپت اول domainهای ماتریس، فایل‌ها، metadata و لینک‌های router را بررسی می‌کند. دومی headingها، fenceهای نمونه و واژه‌های الزامی مرجع Linux را می‌سنجد؛ کد C# را compile یا تماس/RTP را آزمایش نمی‌کند. هر دو برای موفقیت `0` و برای شکست `1` برمی‌گردانند. [build-doc-index.py](scripts/build-doc-index.py) ابزار جداگانهٔ تولید JSON با `--source` و `--output` است و فایل می‌نویسد؛ برای استفادهٔ عادی لازم نیست.

ارزیابی محصول شامل تست parsing/mapping، auth و timeout، duplicate action، disconnect/reconnect، hangup cleanup، registration، routing و media دوطرفه است. [Test Suite](references/testing-asterisk-test-suite.md) و [SIPp/load/fault](references/testing-sipp-load-faults.md) راهنما هستند، نه ادعای اجرای تست. نبود PBX، trunk، حساب یا مسیر شبکه را با resume condition گزارش کنید؛ از static check نتیجهٔ سلامت تماس نگیرید.

## ۷. نقشهٔ منابع

- [ماتریس پوشش و منابع رسمی](references/coverage-matrix.md)، [سازگاری نسخه](references/version-compatibility.md)، [Asterisk 16](references/asterisk-16-legacy-compatibility.md)، [Asterisk 24](references/asterisk-24-version-matrix.md)
- [مبانی](references/fundamentals.md)، [build/backup/rollback](references/build-deployment-operation.md)، [امن‌سازی](references/security-hardening.md)
- [AMI](references/ami.md)، [قرارداد AMI در .NET](references/ami-dotnet-client-contract.md)، [معماری .NET](references/dotnet-asterisk-implementation.md)
- [Dialplan/IVR](references/dialplan-ivr.md)، [FreePBX/Call File/recording](references/dialplan-freepbx-callfile-recording.md)، [صف و monitoring](references/queue-chanspy-recording-monitoring.md)
- [RTP/media](references/rtp-media-codecs.md)، [WebRTC/WSS](references/sip-wss-webrtc-webphone.md)، [CDR/CEL](references/cdr-cel-realtime.md)، [observability](references/troubleshooting-observability.md)
- [ماتریس یکپارچه‌سازی پروژه](references/karavi-project-integration-matrix.md)، [نمونهٔ پروژه](references/example-projects.md)، [router کامل موضوع‌ها](SKILL.md)

مستندات رسمی [Asterisk](https://docs.asterisk.org/) مرجع پروتکل‌اند؛ کتابخانهٔ ثالث فقط dependency پیاده‌سازی است و رفتار wire آن باید روی نسخهٔ مقصد آزموده شود.

---

## ۸. License

[Apache-2.0](LICENSE)
