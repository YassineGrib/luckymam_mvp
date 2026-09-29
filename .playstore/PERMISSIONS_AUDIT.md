# 📋 الدليل الشامل والتدقيق الفني لصلاحيات LuckyMam (Google Play Permissions Audit)

> **تاريخ التدقيق:** 29 سبتمبر 2026  
> **حالة الالتزام:** ⚠️ يحتاج تنظيف وتحديث فوري ليتوافق مع سياسات Google Play (2024 - 2026)  
> **الملف المعني:** `android/app/src/main/AndroidManifest.xml`

---

## 🎯 1. ملخص تنفيذي خاص بصلاحيات اختيار الصور والوسائط (Photo Picker)

### ❓ سؤال المستخدم الرئيسي: "ما هي الصلاحيات التي نستعملها لاختيار الصور وما هو الأفضل؟"

في الإصدارات الحديثة من نظام أندرويد وسياسات Google Play الصارمة (2024-2026):
1. **Google Play تمنع منعاً باتاً طلب صلاحية `READ_MEDIA_IMAGES` أو `READ_EXTERNAL_STORAGE`** إلا للتطبيقات التي وظيفتها الأساسية هي "إدارة وتصفح كامل ملفات وسائط الجهاز" (مثل تطبيقات المعرض Gallery أو تطبيقات مكافحة الفيروسات).
2. تطبيق **LuckyMam** يحتاج اختيار صورة للأم، وصورة للطفل، وصور لكبسولات الذكريات، والوصفات الطبية. هذه تسمى في سياسة جوجل: **"اختيار عرضي ومحدد للصور" (Infrequent / Targeted Photo Selection)**.
3. **الحل القياسي المعتمد من Google:** استخدام **منتقي الصور التابع للنظام (Android Photo Picker)** المدعوم تلقائياً في مكتبة `image_picker: ^1.1.2` الموجودة في تطبيقنا.
4. **المفاجأة التقنية الكبرى:** 
   - الـ **Photo Picker لا يحتاج أي صلاحية نهائياً! (0 Permissions)** على أندرويد 13 فما فوق، ومدعوم رجعياً عبر Google Play Services حتى أندرويد 11 و 12.
   - المستخدم يفتح واجهة النظام الآمنة، ويختار فقط الصور التي يريدها، والتطبيق يستلم رابط الوصول للصورة المحددة فقط دون الوصول لباقي استوديو المستخدم.
5. **الخطر القاتل في الكود الحالي:** 
   - وجود السطرين:
     ```xml
     <uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
     <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" android:maxSdkVersion="32" />
     ```
     **يفرض على التطبيق ملء استمارة إعلان أذونات الوسائط (Permissions Declaration Form) في Google Play Console، وبما أن LuckyMam ليس تطبيق ألبوم/مدير ملفات عام للهاتف، فسيتم رفض التطبيق فوراً (Policy Rejection: Broad Photo Access)!**

---

## 🔍 2. الجرد الشامل لكافة الصلاحيات الموجودة حالياً في `AndroidManifest.xml`

| # | الصلاحية (Permission) | الغرض في التطبيق | التصنيف الأمني | موقف سياسة Google Play | الإجراء الموصى به |
| :-: | :--- | :--- | :---: | :--- | :--- |
| **1** | `android.permission.INTERNET` | الاتصال بـ Firebase و Chargily والخدمات السحابية. | عادي (Normal) | ✅ مسموح تلقائياً بدون موافقة يدوية. | **إبقاء** (ضروري جداً). |
| **2** | `android.permission.ACCESS_NETWORK_STATE` | مراقبة حالة الشبكة والانقطاع وإعادة المحاولة. | عادي (Normal) | ✅ مسموح تلقائياً. | **إبقاء** (ضروري). |
| **3** | `android.permission.POST_NOTIFICATIONS` | إرسال إشعارات التنبيه (FCM والإشعارات المحلية) على أندرويد 13+ (API 33+). | خطيرة (Dangerous) | ✅ مسموح، يتطلب نافذة طلب صلاحية وقت التشغيل. | **إبقاء** (طلب موافقة الأم بلباقة). |
| **4** | `android.permission.VIBRATE` | الاهتزاز عند التنبيهات واللمس التفاعلي (Haptics). | عادي (Normal) | ✅ مسموح تلقائياً. | **إبقاء**. |
| **5** | `android.permission.RECEIVE_BOOT_COMPLETED` | إعادة جدولة تنبيهات اللقاحات والمواعيد بعد إعادة تشغيل الهاتف. | عادي (Normal) | ✅ مسموح لتطبيقات المواعيد والتقويم. | **إبقاء**. |
| **6** | `android.permission.RECORD_AUDIO` | تسجيل الملاحظات الصوتية ودقات قلب الجنين في الكبسولات (`record: ^6.2.0`). | خطيرة (Dangerous) | ⚠️ مسموح بشرط عدم التسجيل في الخلفية وطلب الإذن فقط عند ضغط زر الميكروفون. | **إبقاء** مع إضافة نافذة شرح (Rationale) تسبق الطلب. |
| **7** | `android.permission.CAMERA` | التقاط صورة فورية للأم أو الطفل عبر الكاميرا. | خطيرة (Dangerous) | ⚠️ إذا كان التطبيق يستخدم فقط كاميرا النظام عبر `image_picker` فالمكتبة تستخدم Intent ولا تشترط الصلاحية، لكن إبقاؤها مقبول إذا تم توضيح السبب. | **إبقاء** (أو حذفها إذا اعتمدنا بالكامل على System Camera Intent). |
| **8** | `android.permission.SCHEDULE_EXACT_ALARM` | مواعيد التذكير باللقاحات بدقة الثواني (`flutter_local_notifications`). | أذونات خاصة (Special Access) | ❌ **خطر شديد (High Rejection Risk)!** جوجل تحظرها إلا لتطبيقات المنبه وساعة التوقيف. | **تعديل:** إما استبدالها بـ `USE_EXACT_ALARM`، أو الاعتماد على التنبيهات المرنة غير المجدولة بالثانية. |
| **9** | `android.permission.READ_MEDIA_IMAGES` | قراءة صور المعرض على أندرويد 13+. | خطيرة مقيدة (Restricted) | ❌ **خطر رفض مؤكد!** جوجل تشترط Photo Picker بدلاً منها. | **حذف فوري** (الـ Photo Picker لا يحتاجها). |
| **10** | `android.permission.READ_MEDIA_AUDIO` | قراءة الملفات الصوتية على أندرويد 13+. | خطيرة مقيدة (Restricted) | ❌ **غير مستعملة إطلاقاً!** التطبيق يسجل صوته بنفسه ولا يقرأ مكتبة موسيقى الهاتف. | **حذف فوري**. |
| **11** | `android.permission.READ_EXTERNAL_STORAGE` | قراءة الملفات في أندرويد 12 وما قبله. | خطيرة مقيدة | ❌ **غير مطلوبة** لأن `image_picker` و `file_picker` يستعملان System SAF و Photo Picker. | **حذف فوري**. |
| **12** | `android.permission.WRITE_EXTERNAL_STORAGE` (`maxSdkVersion="29"`) | حفظ صور الألبوم أو الكبسولات في معرض الجهاز عبر مكتبة `gal`. | عادية حتى API 29 | ✅ آمنة لأنها محصورة بـ `android:maxSdkVersion="29"`. أندرويد 10+ يستخدم MediaStore بدون أذونات. | **إبقاء مع حصرها بـ maxSdkVersion=29**. |

---

## 🛠️ 3. الصيغة المثالية المقترحة لملف `AndroidManifest.xml` (Zero Rejection Manifest)

هذه هي قائمة الصلاحيات النظيفة 100% التي تضمن قبول التطبيق في Google Play دون طلب أي استثناءات معقدة أو استمارات تبرير للوسائط:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <!-- 1. الشبكة والاتصال السحابي -->
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>

    <!-- 2. الإشعارات والجدولة المحلية -->
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    <uses-permission android:name="android.permission.VIBRATE"/>
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
    
    <!-- بديل آمن لـ SCHEDULE_EXACT_ALARM يتوافق مع سياسة التذكيرات التقويمية (أندرويد 13/14) -->
    <uses-permission android:name="android.permission.USE_EXACT_ALARM"/>

    <!-- 3. الميزات التفاعلية الاختيارية (بموافقة المستخدم اللحظية) -->
    <uses-permission android:name="android.permission.RECORD_AUDIO"/>
    <uses-permission android:name="android.permission.CAMERA"/>

    <!-- 4. حفظ الصور المطبوعة في المعرض لأجهزة أندرويد القديمة فقط (Android ≤ 9 / API 29) -->
    <uses-permission 
        android:name="android.permission.WRITE_EXTERNAL_STORAGE" 
        android:maxSdkVersion="29"/>

    <!-- 
      ملاحظة هامة:
      تم حذف READ_MEDIA_IMAGES و READ_MEDIA_AUDIO و READ_EXTERNAL_STORAGE
      عملاً بسياسة Google Play Photo Picker Mandatory Policy.
      اختيار الصور يعمل بنسبة 100% بدون هذه الأذونات عبر Photo Picker التابع للنظام.
    -->
```

---

## 📱 4. كيف يرى المستخدم تجربة اختيار الصور بعد التحديث؟
1. تضغط الأم على **"المعرض"** في أي شاشة (تعديل البروفايل، كبسولة، فحص طبي).
2. يفتح فوراً **منتقي صور أندرويد الرسمي (Android System Photo Picker)** مع تصميم عصري وسلس.
3. لن تظهر للأم أي رسالة منبثقة مزعجة تطلب الإذن بالوصول إلى "كافة الصور والفيديوهات على جهازك".
4. تختار الأم الصورة المناسبة، وتعود للتطبيق فوراً.
5. يحصل التطبيق على أعلى درجات الأمان والخصوصية في متجر Google Play.

---

## 🔒 5. بطاقة البيانات للمتجر (Data Safety Form Mapping للصلاحيات)
عند تعبئة استبيان الأذونات وسلامة البيانات في Google Play Console:
- **هل يجمع التطبيق بيانات صوتية؟** -> نعم (تسجيلات صوتية اختيارية للكبسولات)، مرتبطة بحساب المستخدم، مشفرة أثناء النقل، ولا تُشارك مع أي طرف ثالث.
- **هل يجمع التطبيق صوراً أو فيديوهات؟** -> نعم (صور الألبوم والبروفايل)، مجمعة لغرض وظائف التطبيق (App Functionality)، مشفرة أثناء النقل، ولا تُشارك مع أي طرف ثالث.
- **هل يطلب التطبيق صلاحية وصول شامل لملفات الوسائط (Broad Media Access)؟** -> **لا (NO)** -> وهذا هو المفتاح لتجنب التدقيق اليدوي المعقد والرفض!
