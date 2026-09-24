# karavi-asterisk-voip

مرجع implementation-oriented و version-aware برای توسعه، بررسی، تست و
عیب‌یابی سامانه‌های مبتنی بر Asterisk و VoIP، با نسخهٔ canonical برابر
`Asterisk 22 LTS` و compatibility notes برای نسخه‌های 20 و 23.

## پوشش

- SIP/PJSIP، RTP، NAT، codec و TLS
- Dialplan، IVR، Queue و Call Routing
- AMI، ARI، AGI و FastAGI
- CDR/CEL، مانیتورینگ و observability
- اتصال به CRM، Call Center، Dialer و سرویس‌های application
- تست قرارداد، integration، media smoke و failure recovery
- Fundamentals، build/deployment/operation، development و Asterisk Test Suite
- CDR/CEL، realtime، security hardening و version compatibility

## نصب

```bash
npx skills add https://github.com/akaravi/Karavi.Skills --skill karavi-asterisk-voip
```

## منابع

جزئیات تخصصی در `references/` و به‌صورت on-demand بارگذاری می‌شوند. مرجع
پروتکل، مستندات رسمی Asterisk است؛ کتابخانه‌های third-party باید با نسخهٔ
هدف Asterisk و رفتار واقعی wire تست شوند.

coverage matrix و validatorهای آفلاین در مسیرهای زیر قرار دارند:

- `references/coverage-matrix.md`
- `scripts/build-doc-index.py`
- `scripts/verify-doc-coverage.py`

## مرز ایمنی

این skill مجوز تغییر live PBX، production، firewall، credential، reload،
restart یا originate تماس را ایجاد نمی‌کند. برای چنین عملیاتی مجوز صریح،
محیط مشخص و verification متناسب لازم است.

## License

Apache-2.0
