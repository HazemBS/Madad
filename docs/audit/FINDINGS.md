# نتائج التدقيق

لا تحتوي هذه الجداول على قيم أسرار.

| ID | Severity | Category | Location | Finding | Evidence | Impact | Recommended fix | Status |
|---|---|---|---|---|---|---|---|---|
| F-01 | High | Checkout | `lib/features/cart/checkout_page.dart` | ضغطتان سريعتان كان يمكن أن تنشئا طلبين قبل إعادة البناء | الزر يُعطّل بعد `setState` فقط | طلب مكرر | إرجاع فوري إذا كان الإرسال جاريًا، وتعطيل الزر | Fixed |
| F-02 | High | Pricing | `lib/features/orders/orders_controller.dart` | رسوم التوصيل كانت تُقبل كما يمررها المستدعي | المعامل `deliveryFee` | إجمالي غير صحيح إذا تغيّر الرقم | الحساب من مجموع العناصر داخل المتحكم | Fixed |
| F-03 | High | Orders | `OrdersController.placeOrder` | لم يكن هناك رفض لسلة فارغة داخل المتحكم | الفحص كان في الواجهة فقط | طلب بلا عناصر إذا استُدعي المتحكم مباشرة | `ArgumentError` عند قائمة فارغة | Fixed |
| F-04 | High | Secrets | `lib/core/config/supabase_config.dart` | عنوان المشروع والمفتاح العام وكلمة مرور الحساب التجريبي مكتوبة في المصدر | ثوابت في ملف الإعداد، القيم غير مذكورة هنا | من يملك التطبيق يستطيع استخدام حساب العرض | إخراج الأسرار قبل الإنتاج والإبقاء على الدخول التجريبي للعرض فقط | Open |
| F-05 | High | Network | `lib/main.dart` | التشغيل الحقيقي يهيئ عميلًا بعيدًا حتى لو فشل تحميل الكتالوج | `Supabase.initialize` ثم التقاط الخطأ للكتالوج فقط | العرض المتصل يلمس مشروعًا خارجيًا؛ الاختبارات المحلية لا تفعل ذلك | للعرض دون شبكة شغّل الاختبارات أو ابنِ مسارًا محليًا صريحًا | Open |
| F-06 | High | Trust boundary | السلة و`MadadStore.createOrder` | سعر الوحدة المخزّن في عنصر السلة يأتي من الجهاز | `CartItem.product.wholesalePrice` | عميل معدَّل يمكن أن يرسل سعرًا خاطئًا لاحقًا | الخادم يعيد قراءة السعر والمخزون | Open |
| F-07 | Medium | Platform | `android/app/build.gradle.kts` | إصدار أندرويد يوقَّع بمفتاح التنقيح | `signingConfig` يشير إلى debug | لا يصلح للنشر | مفتاح إصدار خاص قبل المتجر | Open |
| F-08 | Medium | Identity | `applicationId` | المعرف ما زال `com.example.rafd_v01` | `build.gradle.kts` | تعارض وشكل غير نهائي | تغيير المعرف قبل النشر دون كسر العرض | Open |
| F-09 | Medium | UX | `product_details_page.dart` | شريط الكمية والأزرار في صف واحد وقد يُصغَّر النص | `FittedBox` و`Expanded` | قراءة أضعف على الشاشات الضيقة | صف أوضح بعد العرض إذا ضاق الوقت | Open |
| F-10 | Medium | Privacy | `AndroidManifest.xml` | النسخ الاحتياطي كان بالمبدئ يسمح بنسخ جلسة الدخول | عدم وجود `allowBackup` | استخراج جلسة من نسخة احتياطية | `android:allowBackup="false"` | Fixed |
| F-11 | Medium | Input | `checkout_page.dart` | الملاحظات بلا حد | حقل حر | نص ضخم يصل لاحقًا للخادم | حد 240 حرفًا | Fixed |
| F-12 | Medium | Auth | `login_page.dart` | الضغط المتكرر قبل إعادة البناء | `_busy` يُضبط داخل `setState` فقط | محاولتا دخول | إرجاع فوري عند الانشغال | Fixed |
| F-13 | Medium | Logout | `SessionController` | الخروج لا يفرغ السلة المحلية | السلة تبقى في الذاكرة | مستخدم تالٍ على نفس العملية قد يرى السلة | تفريغ السلة عند الخروج قبل بيتا | Open |
| F-14 | Low | Legacy | `core/**` | كود رَفْد القديم باقٍ ومستبعد من التحليل | `analysis_options.yaml` | إرباك للقارئ لا للمستخدم | إبقاؤه كما طُلب سابقًا وعدم ربطه | Open |
| F-15 | Low | Dependencies | `pubspec.yaml` | `flutter_lints` 6 وعدة حزم عابرة أحدث | `flutter pub outdated` | لا ثغرة مؤكدة في هذا التدقيق | لا ترقية كبرى قبل العرض | Open |
| F-16 | Low | iOS | `Info.plist` | الاتجاه الأفقي مسموح | مصفوفة الاتجاهات | تخطيط لم يُراجع أفقيًا | قصر الهاتف على العمودي لاحقًا | Open |
| F-17 | Low | Verification | لقطات الشاشة | تعذر حفظ لقطات `screenshots/final_audit/` | اختبار الالتقاط توقف، والتشغيل الحي يرسل طلبات | لا أرشيف بصري لهذه الجولة | التقاط اللقطات يدويًا على بناء محلي بلا شبكة | Open |
