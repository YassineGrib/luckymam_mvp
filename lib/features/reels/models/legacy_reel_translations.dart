/// Fallback for canonical seed documents whose old importer discarded translations.
/// Explicit document translations always take precedence.
String? legacyReelText(String id, String language, String field) {
  const titles = {
    'reel_1': {
      'fr': 'Soins de bébé',
      'en': 'Baby care',
      'ar': 'العناية بالرضيع',
    },
    'reel_2': {
      'fr': 'Guide Nutrition',
      'en': 'Nutrition guide',
      'ar': 'دليل التغذية السليمة',
    },
    'reel_3': {
      'fr': 'Premiers Pas',
      'en': 'First steps',
      'ar': 'الخطوات الأولى',
    },
    'reel_app': {
      'fr': 'Découvrir Luckymam',
      'en': 'Discover Luckymam',
      'ar': 'اكتشفي Luckymam',
    },
  };
  const descriptions = {
    'reel_1': {
      'fr':
          'Les gestes essentiels pour prendre soin de votre nouveau-né au quotidien.',
      'en': 'Essential everyday care for your newborn.',
      'ar': 'الخطوات الأساسية للعناية اليومية بطفلك حديث الولادة',
    },
    'reel_2': {
      'fr':
          "Alimentation équilibrée pour maman et bébé — conseils d’une nutritionniste.",
      'en':
          'Balanced nutrition for mother and baby — advice from a nutritionist.',
      'ar': 'التغذية المتوازنة للأم والطفل — نصائح أخصائي تغذية',
    },
    'reel_3': {
      'fr':
          "Comment accompagner votre enfant dans l’apprentissage de la marche.",
      'en': 'How to support your child as they learn to walk.',
      'ar': 'كيفية دعم طفلك في تعلم المشي والموازنة',
    },
    'reel_app': {
      'fr':
          "Présentation de l’application Luckymam pour les mamans algériennes.",
      'en': 'Introducing Luckymam for Algerian mothers.',
      'ar': 'تعرفي على تطبيق Luckymam للأمهات الجزائريات',
    },
  };
  return (field == 'title' ? titles : descriptions)[id]?[language];
}
