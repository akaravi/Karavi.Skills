# karavi-asterisk-voip

مرجع جامع، مهندسی‌شده و **نسخه‌آگاه (Version-Aware)** برای توسعه، راه‌اندازی، اتصال برنامه‌های سازمانی، تست و عیب‌یابی سامانه‌های تلفنی مبتنی بر **Asterisk و VoIP**.

- **نسخه کانونیکال مرجع:** `Asterisk 22 LTS`
- **سازگاری و ارتقا:** نکات انطباق برای Asterisk 16 Legacy، Asterisk 20 LTS و Asterisk 24

این مهارت یک راهنمای کامل عملیاتی برای برنامه‌نویسان دات‌نت (.NET)، پایتون و مهندسان شبکه و مخابرات است تا بتوانند بدون ریسک تداخل در محیط‌های عملیاتی تماس، سرویس‌های تلفنی پایدار بسازند.

---

## ۱. ساختار مهارت و دسته‌بندی موضوعی

```text
skills/karavi-asterisk-voip/
├── SKILL.md              نقطه ورود، چک‌لیست‌ها و قواعد تصمیم‌گیری
├── README.md             مستندات اصلی، دستورات و مثال‌های کاربردی
└── references/           بیش از ۶۰ مرجع تخصصی بر اساس تفکیک دامنه‌ها:
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

## ۲. سناریوهای کاربردی همراه با کدهای اجرایی

### سناریو ۱: ایجاد ترانک امن PJSIP در `pjsip.conf`
پیکربندی ترانک خروجی به سمت ارائه‌دهنده سرویس (Sip Provider) با احراز هویت و ثبت (Registration):

```ini
; ====================================================================
; PJSIP Trunk Configuration — Endpoint, AOR, Auth, Registration
; ====================================================================

[transport-udp]
type=transport
protocol=udp
bind=0.0.0.0:5060

[trunk-telco-reg]
type=registration
outbound_auth=trunk-telco-auth
server_uri=sip:sip.telco-provider.ir
client_uri=sip:9821000000@sip.telco-provider.ir
retry_interval=60
expiration=3600

[trunk-telco-auth]
type=auth
auth_type=userpass
username=9821000000
password=ENV_TELCO_SECRET ; سکرت‌ها هرگز نباید هاردکد شوند

[trunk-telco-aor]
type=aor
contact=sip:sip.telco-provider.ir:5060

[trunk-telco]
type=endpoint
context=from-telco-incoming
disallow=all
allow=alaw,ulaw,g729
aors=trunk-telco-aor
outbound_auth=trunk-telco-auth
direct_media=no
force_rport=yes
rewrite_contact=yes
```

---

### سناریو ۲: پردازش تماس با FastAGI در سی‌شارپ (.NET Core BackgroundService)
پیاده‌سازی یک سرور سبک TCP برای پاسخ‌گویی به درخواست‌های دیال‌پلن استریسک:

```csharp
using System.IO;
using System.Net;
using System.Net.Sockets;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;

public class FastAgiServer : BackgroundService
{
    private readonly ILogger<FastAgiServer> _logger;
    private readonly TcpListener _listener = new(IPAddress.Any, 4573);

    public FastAgiServer(ILogger<FastAgiServer> logger) => _logger = logger;

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _listener.Start();
        _logger.LogInformation("FastAGI listener running on port 4573...");

        while (!stoppingToken.IsCancellationRequested)
        {
            var client = await _listener.AcceptTcpClientAsync(stoppingToken);
            _ = HandleAgiSessionAsync(client, stoppingToken);
        }
    }

    private async Task HandleAgiSessionAsync(TcpClient client, CancellationToken ct)
    {
        using var stream = client.GetStream();
        using var reader = new StreamReader(stream);
        using var writer = new StreamWriter(stream) { AutoFlush = true };

        // 1. خواندن هدرهای اولیه AGI تا سطر خالی
        string line;
        string callerId = "unknown";
        while (!string.IsNullOrEmpty(line = await reader.ReadLineAsync(ct)))
        {
            if (line.StartsWith("agi_callerid:"))
                callerId = line.Substring("agi_callerid:".Length).Trim();
        }

        _logger.LogInformation("Incoming call via FastAGI from {CallerId}", callerId);

        // 2. ارسال دستور استریسک: پخش پیام صوتی خوش‌آمد
        await writer.WriteLineAsync("STREAM FILE custom-welcome \"#\"");
        var response = await reader.ReadLineAsync(ct);

        // 3. تنظیم متغیر در دیال‌پلن
        await writer.WriteLineAsync("SET VARIABLE CUSTOMER_STATUS \"VIP\"");
        await reader.ReadLineAsync(ct);
    }
}
```

---

### سناریو ۳: کنترل تماس تعاملی با WebSocket و ARI (Asterisk REST Interface)
ورود تماس به برنامه Stasis و انتقال تماس به مقصد دیگر با درخواست HTTP:

**دیال‌پلن در `extensions.conf`:**
```ini
[default]
exten => 9000,1,NoOp(Entry point for ARI Stasis Application)
 same => n,Answer()
 same => n,Stasis(VoiceBotApp)
 same => n,Hangup()
```

**کد کنترل‌کننده در Node.js یا C# با ARI WebSocket:**
```javascript
const WebSocket = require('ws');
const axios = require('axios');

const ARI_URL = 'http://127.0.0.1:8088/ari';
const AUTH_HEADER = { auth: { username: 'ariuser', password: process.env.ARI_PASSWORD } };

const ws = new WebSocket('ws://127.0.0.1:8088/ari/events?api_key=ariuser:' + process.env.ARI_PASSWORD + '&app=VoiceBotApp');

ws.on('message', async (data) => {
    const event = JSON.parse(data);
    if (event.type === 'StasisStart') {
        const channelId = event.channel.id;
        console.log(`Call entered VoiceBotApp on channel ${channelId}`);

        // پخش فایل صوتی از طریق REST API
        await axios.post(`${ARI_URL}/channels/${channelId}/play?media=sound:hello-world`, {}, AUTH_HEADER);
    }
});
```

---

### سناریو ۴: عیب‌یابی کیفیت صدا و افت پکت RTP در لینوکس
بررسی بلادرنگ ترافیک مدیا و عیب‌یابی تأخیر صدا بدون ایجاد بار روی سرور:

```bash
# ۱. مانیتورینگ جریان RTP به تفکیک پکت‌ها و Jitter
asterisk -rx "pjsip show channelstats"

# ۲. ضبط فشرده پکت‌های SIP و RTP یک تماس خاص با sngrep
sngrep -c -O /tmp/call-debug.pcap port 5060 or portrange 10000-20000

# ۳. بررسی باز بودن محدوده پورت‌های مدیا در فایروال
iptables -L -n -v | grep 10000:20000
```

---

## ۳. دستورات پرکاربرد استریسک در CLI

| دستور | کاربرد | نمونه خروجی مورد انتظار |
|---|---|---|
| `pjsip show endpoints` | وضعیت تمام شماره‌های داخلی و خطوط | نام، وضعیت (Avail/Unavailable) و AOR |
| `core show channels` | تعداد تماس‌های فعال در لحظه | لیست لاین‌ها و کانال‌های فعال در حال مکالمه |
| `queue show <queue_name>` | وضعیت صف، اپراتورها و تماس‌گیرندگان در صف | لیست کاربران لاگین‌شده و تماس‌های منتظر |
| `module reload res_pjsip.so` | اعمال تغییرات کانفیگ بدون قطعی سرور | تایید بارگذاری مجدد ماژول SIP |
| `logger reload` | تازه‌سازی فایل‌های لاگ استریسک | چرخش و اعمال لاگ‌های جدید در `/var/log/asterisk/` |

---

## ۴. مرزهای ایمنی و امنیت مخابراتی (Security Safeguards)

1. **جلوگیری از Toll Fraud:** دسترسی تماس‌های بین‌المللی یا ترانک‌های خروجی نباید در کانتکست‌های پیش‌فرض مثل `default` یا `from-sip` باز باشد.
2. **جداسازی شبکه مدیا و سیگنالینگ:** پورت‌های RTP (`10000-20000`) باید با فایروال تنها به مقاصد معتبر محدود شوند.
3. **عدم افشای سکرت‌ها:** پسورد ترانک‌ها و کاربران ARI هرگز نباید در ریپازیتوری ذخیره شود؛ همیشه از متغیرهای محیطی یا سکرت والت استفاده کنید.
4. **تغییرات Live PBX:** هرگونه کامند مخرب نظیر `core restart now` یا تغییرات دیال‌پلن در محیط پروداکشن نیازمند مجوز صریح است.

---

## ۵. نصب مهارت

```bash
npx skills add https://github.com/akaravi/Karavi.Skills --skill karavi-asterisk-voip
```

---

## ۶. License

Apache-2.0
