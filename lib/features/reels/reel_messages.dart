/// Copy scoped to the reel feature until the next localization generation.
String reelMessage(String language, String key) {
  const messages = {
    'fr': {
      'error': 'Impossible de charger la vidéo. Vérifiez votre connexion.',
      'actionError':
          'Action impossible. Vérifiez la connexion et les autorisations, puis réessayez.',
      'saved': 'Vidéo enregistrée dans la galerie.',
    },
    'en': {
      'error': 'Unable to load video. Check your connection.',
      'actionError':
          'Unable to complete this action. Check your connection and permissions, then retry.',
      'saved': 'Video saved to gallery.',
    },
    'ar': {
      'error': 'تعذر تحميل الفيديو. تحققي من الاتصال.',
      'actionError':
          'تعذر إتمام العملية. تحققي من الاتصال والأذونات ثم أعيدي المحاولة.',
      'saved': 'تم حفظ الفيديو في المعرض.',
    },
  };
  return (messages[language] ?? messages['fr']!)[key]!;
}
