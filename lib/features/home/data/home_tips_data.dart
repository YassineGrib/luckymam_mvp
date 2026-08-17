import '../../profile/models/profile_models.dart';

/// Localized daily tips by user status — FR / AR / EN.
abstract final class HomeTipsData {
  static String tipFor(String locale, UserStatus status) {
    final tips = _tips[locale]?[status] ?? _tips['fr']![status]!;
    final dayOfYear = DateTime.now()
        .difference(DateTime(DateTime.now().year, 1, 1))
        .inDays;
    return tips[dayOfYear % tips.length];
  }

  static const Map<String, Map<UserStatus, List<String>>> _tips = {
    'fr': {
      UserStatus.hope: _tipsHopeFr,
      UserStatus.pregnant: _tipsPregnantFr,
      UserStatus.mom: _tipsMomFr,
    },
    'ar': {
      UserStatus.hope: _tipsHopeAr,
      UserStatus.pregnant: _tipsPregnantAr,
      UserStatus.mom: _tipsMomAr,
    },
    'en': {
      UserStatus.hope: _tipsHopeEn,
      UserStatus.pregnant: _tipsPregnantEn,
      UserStatus.mom: _tipsMomEn,
    },
  };

  static const _tipsHopeFr = [
    'Prenez soin de vous : une alimentation équilibrée prépare votre corps à accueillir la vie.',
    'Le stress peut influencer la fertilité. Accordez-vous des moments de sérénité.',
    'Tenez un journal de votre cycle — chaque donnée compte.',
    "L'acide folique est essentiel dès maintenant. Parlez-en à votre médecin.",
    'Votre chemin est unique. Célébrez chaque étape, aussi petite soit-elle.',
    'La patience est une force. Votre moment viendra 💜',
  ];

  static const _tipsPregnantFr = [
    'Parlez à votre bébé ! Il reconnaît déjà votre voix dès le 6ème mois.',
    'Une promenade quotidienne de 20 minutes est bénéfique pour vous deux.',
    'Hydratez-vous bien — votre corps travaille double en ce moment.',
    "Notez vos ressentis aujourd'hui. Ce journal sera précieux plus tard.",
    'Chaque coup de pied est un message d\'amour 🩷',
    'Reposez-vous sans culpabilité. C\'est du travail, accoucher !',
  ];

  static const _tipsMomFr = [
    'Parlez à votre bébé ! Il reconnaît déjà votre voix.',
    'Prenez du temps pour vous. Une maman heureuse = un bébé heureux.',
    'Chaque moment est précieux. Capturez-le dans une capsule !',
    'La musique calme peut aider votre bébé à s\'apaiser.',
    'Les câlins libèrent de l\'ocytocine, l\'hormone du bonheur.',
    'Votre bébé apprend en vous observant. Souriez souvent !',
    'N\'oubliez pas de boire beaucoup d\'eau.',
    'Faites des pauses. Le repos est essentiel.',
    'Célébrez chaque petit progrès de votre enfant.',
    'Respirez profondément. Vous êtes une super maman !',
  ];

  static const _tipsHopeAr = [
    'اعتني بنفسك: التغذية المتوازنة تُهيّئ جسمك لاستقبال الحياة.',
    'التوتر قد يؤثر على الخصوبة. امنحي نفسك لحظات من الهدوء.',
    'دوّني دورتك — كل معلومة مهمة.',
    'حمض الفوليك أساسي من الآن. تحدثي مع طبيبك.',
    'رحلتك فريدة. احتفلي بكل خطوة، مهما كانت صغيرة.',
    'الصبر قوة. لحظتك ستأتي 💜',
  ];

  static const _tipsPregnantAr = [
    'تحدثي مع طفلك! إنه يتعرف على صوتك من الشهر السادس.',
    'المشي 20 دقيقة يومياً مفيد لك ولطفلك.',
    'اشربي الماء جيداً — جسمك يعمل بجهد مضاعف الآن.',
    'سجّلي مشاعرك اليوم. سيكون هذا اليوميات ثميناً لاحقاً.',
    'كل ركلة هي رسالة حب 🩷',
    'استريحي دون ذنب. الولادة عمل شاق!',
  ];

  static const _tipsMomAr = [
    'تحدثي مع طفلك! إنه يتعرف على صوتك.',
    'خصصي وقتاً لنفسك. أم سعيدة = طفل سعيد.',
    'كل لحظة ثمينة. احفظيها في كبسولة!',
    'الموسيقى الهادئة تساعد طفلك على الاسترخاء.',
    'العناق يُفرز الأوكسيتوسin، هرمون السعادة.',
    'طفلك يتعلم منك. ابتسمي كثيراً!',
    'لا تنسي شرب الماء بانتظام.',
    'خذي فترات راحة. الراحة ضرورية.',
    'احتفلي بكل تقدم صغير لطفلك.',
    'تنفسي بعمق. أنتِ أم رائعة!',
  ];

  static const _tipsHopeEn = [
    'Take care of yourself: a balanced diet prepares your body for new life.',
    'Stress can affect fertility. Give yourself moments of calm.',
    'Keep a cycle journal — every data point matters.',
    'Folic acid is essential now. Talk to your doctor.',
    'Your path is unique. Celebrate every step, however small.',
    'Patience is strength. Your moment will come 💜',
  ];

  static const _tipsPregnantEn = [
    'Talk to your baby! They recognize your voice from the 6th month.',
    'A daily 20-minute walk benefits you both.',
    'Stay hydrated — your body is working overtime.',
    'Note how you feel today. This journal will be precious later.',
    'Every kick is a message of love 🩷',
    'Rest without guilt. Giving birth is hard work!',
  ];

  static const _tipsMomEn = [
    'Talk to your baby! They already recognize your voice.',
    'Make time for yourself. A happy mom = a happy baby.',
    'Every moment is precious. Capture it in a capsule!',
    'Calm music can help your baby relax.',
    'Hugs release oxytocin, the happiness hormone.',
    'Your baby learns by watching you. Smile often!',
    'Remember to drink plenty of water.',
    'Take breaks. Rest is essential.',
    'Celebrate every small milestone of your child.',
    'Breathe deeply. You are an amazing mom!',
  ];
}
