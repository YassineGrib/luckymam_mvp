import 'package:flutter/material.dart';

/// Shared explanation for both profile status entry points.
String motherStatusGuidance(BuildContext context) {
  switch (Localizations.localeOf(context).languageCode) {
    case 'ar':
      return 'لتفعيل حالة الأم، أضيفي طفلاً مولوداً من صفحة الملف الشخصي. تتحدث الحالة تلقائياً بعد إضافته.';
    case 'en':
      return 'To activate Mother status, add a born child from your profile. Your status updates automatically after adding the child.';
    default:
      return 'Pour activer le statut Maman, ajoutez un enfant né depuis votre profil. Le statut se met à jour automatiquement après son ajout.';
  }
}
