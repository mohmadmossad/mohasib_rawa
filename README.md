محاسب روعة - النسخة النهائية (v4)

هذه الحزمة تحتوي على مشروع Flutter متكامل مبدئي يحتوي على:
- نظام صلاحيات متكامل (اختيارات لكل مستخدم).
- واجهة فاتورة متقدمة (بحث برمز الباركود، إضافة يدوي، خصم، ضريبة).
- تصدير إلى Excel (xlsx) وطباعة PDF.
- نسخ احتياطي/استعادة عبر Google Drive (scaffold + خطوات إعداد OAuth).
- طباعة حرارية عبر Bluetooth (مساعد مبدئي).
- جدولة نسخ احتياطي تلقائي باستخدام WorkManager (Android).

ملاحظات هامة قبل التشغيل:
1) فك الضغط وانقل المجلد إلى workspace مشروع Flutter أو افتح كـ project جديد.
2) شغّل الأوامر التالية في التيرمنال داخل المشروع:
   flutter pub get
   flutter pub run build_runner build --delete-conflicting-outputs
3) لتفعيل Google Drive:
   - افتح Google Cloud Console، فعّل Drive API، وأنشئ OAuth Client ID لتطبيق Android مع SHA-1.
   - ضع بيانات الاعتماد/ملف google-services.json أو اتبع المكتبة المستخدمة.
   - راجع lib/services/drive_service.dart لإعداد client id scopes.
4) لإجراء طباعة بلوتوث حقيقية أضف الأذونات التالية في AndroidManifest.xml:
   <uses-permission android:name="android.permission.BLUETOOTH" />
   <uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
   <uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
   <uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
   ولـ Android 12+ قد تحتاج أذونات إضافية.
5) لتشغيل الجدولة التلقائية (نسخ احتياطي يومي) يتم استخدام workmanager. راجع lib/services/scheduler.dart.
6) تسجيل الدخول الافتراضي: admin / admin (مخزن في Isar كتجربة).

إذا أردت، أستطيع الآن:
- توليد ملف google-services.json مُهيأ (أحتاج منك client id وSHA-1). 
- إضافة مثال عملي لطابعة ESC/POS محددة (أحتاج طراز الطابعة أو بروتوكولها).
- أو شرح خطوة بخطوة لتثبيت المشروع على هاتفك.

رابط التحميل داخل المحادثة بعد الإنشاء.

--
تم إضافة إعداد Codemagic داخل المجلد `.ci/codemagic.yaml` لبناء APK/AAB تلقائياً.
