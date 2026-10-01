# Canonical Rule Maintenance & Migration Guide

این سند راهنمای نگهداری، مهاجرت و همگام‌سازی قوانین جهانی پروژه با منبع کانونیکال در مهارت `karavi-rule` است.

---

## ۱. منبع رسمی قوانین (Canonical Source)

تنها منبع رسمی و تغییرناپذیر قوانین پروژه فایل زیر است:
```text
D:\SourceKaravi\Agents.Project\Agent.Global.Rule\assembledPrompt.v4.0.1.txt
```

هنگامی که این فایل به‌روزرسانی می‌شود، باید ماتریس پوشش (`references/coverage-matrix.md`) و متن کامل قوانین (`references/global-rules-complete.md`) با آن هماهنگ شده و اسکریپت رسمی Sync اجرا شود.

---

## ۲. اسکریپت رسمی همگام‌سازی (Official Sync Script)

هیچ اسکریپت واسط یا سفارشی نباید برای سنک کردن فایل‌های قوانین ساخته شود. همگام‌سازی صرفاً از طریق دستور رسمی زیر انجام می‌پذیرد:

```powershell
& "D:\SourceKaravi\Agents.Project\Agent.Global.Rule\Global.Rule\Main\sync-global-rules.ps1"
```

این اسکریپت اقدامات زیر را به صورت خودکار و امن انجام می‌دهد:
1. پشتیبان‌گیری خودکار از مقصدهای جاری با پسوند `.bak`
2. محاسبه هش SHA256 متن قوانین و مقایسه با وضعیت فعلی
3. اطمینان از انکودینگ UTF-8 بدون BOM برای فایل‌های متنی
4. جلوگیری از تغییر دستی و اعمال یکپارچه تغییرات در ابزارهای پشتیبانی‌شده

---

## ۳. اصل ماندگاری قوانین و عدم حذف ناخواسته (Never Silently Delete)

- اگر یک rule ID در نسخه جدید منبع فعال وجود نداشت، آن قانون حذف‌شده تلقی **نمی‌شود**.
- متن کامل قانون باید در `references/global-rules-complete.md` حفظ شود.
- در `references/coverage-matrix.md` وضعیت مالکیت، تریگر اجرایی، روش بررسی (verifyMethod) و شواهد لازم ثبت گردد.
- فرایندهای مربوط به برنامه‌ریزی به `karavi-council`، نگهداری دایرکتوری به `karavi-folder` و داوری به `karavi-judge` واگذار می‌شوند.

---

## ۴. مثال عملیاتی مهاجرت و بررسی وضعیت قوانین

```powershell
# گام ۱: بررسی خوانایی منبع کانونیکال و محاسبه هش
$src = "D:\SourceKaravi\Agents.Project\Agent.Global.Rule\assembledPrompt.v4.0.1.txt"
if (Test-Path $src) {
    $hash = (Get-FileHash -Path $src -Algorithm SHA256).Hash
    Write-Output "Canonical Source Verified. SHA256: $hash"
} else {
    Write-Error "Canonical source file not found at: $src"
}

# گام ۲: اجرای اسکریپت رسمی برای همگام‌سازی در محیط توسعه
& "D:\SourceKaravi\Agents.Project\Agent.Global.Rule\Global.Rule\Main\sync-global-rules.ps1"

# گام ۳: بازرسی عدم وجود BOM و صحت انکودینگ UTF-8 در خروجی‌های جنریت‌شده
Get-ChildItem -Path "skills" -Filter "*.md" -Recurse | ForEach-Object {
    $bytes = [System.IO.File]::ReadAllBytes($_.FullName)
    if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
        Write-Warning "File has UTF-8 BOM: $($_.FullName)"
    }
}
```
