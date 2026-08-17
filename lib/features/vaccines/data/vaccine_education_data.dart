import 'package:flutter/material.dart';

/// Localized educational content for a vaccine (description, mechanism, side effects).
class VaccineEducation {
  const VaccineEducation({
    required this.descriptionFr,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.howItWorksFr,
    required this.howItWorksAr,
    required this.howItWorksEn,
    required this.sideEffectsFr,
    required this.sideEffectsAr,
    required this.sideEffectsEn,
    required this.icon,
    required this.color,
  });

  final String descriptionFr;
  final String descriptionAr;
  final String descriptionEn;
  final String howItWorksFr;
  final String howItWorksAr;
  final String howItWorksEn;
  final String sideEffectsFr;
  final String sideEffectsAr;
  final String sideEffectsEn;
  final IconData icon;
  final Color color;

  String getDescription(String locale) =>
      _pick(locale, descriptionFr, descriptionAr, descriptionEn);

  String getHowItWorks(String locale) =>
      _pick(locale, howItWorksFr, howItWorksAr, howItWorksEn);

  String getSideEffects(String locale) =>
      _pick(locale, sideEffectsFr, sideEffectsAr, sideEffectsEn);

  static String _pick(String locale, String fr, String ar, String en) {
    switch (locale) {
      case 'ar':
        return ar;
      case 'en':
        return en;
      default:
        return fr;
    }
  }
}

/// Static rich info for known vaccine codes.
const vaccineEducationData = <String, VaccineEducation>{
  'BCG': VaccineEducation(
    descriptionFr:
        'Le BCG (Bacille Calmette-Guérin) est un vaccin vivant atténué qui protège contre les formes graves de tuberculose, notamment la méningite tuberculeuse chez les nourrissons et les jeunes enfants.',
    descriptionAr:
        'لقاح BCG (باسillus Calmette-Guérin) هو لقاح حي مُضعَّف يحمي من أشكال السل الخطيرة، ولا سيما التهاب السحايا السلي عند الرضع والأطفال الصغار.',
    descriptionEn:
        'BCG (Bacille Calmette-Guérin) is a live attenuated vaccine that protects against severe forms of tuberculosis, especially tuberculous meningitis in infants and young children.',
    howItWorksFr:
        'Le vaccin stimule le système immunitaire à produire des lymphocytes T spécifiques qui reconnaissent et combattent la bactérie Mycobacterium tuberculosis.',
    howItWorksAr:
        'يحفّز اللقاح الجهاز المناعي على إنتاج خلايا T لمحددة تتعرف على بكتيريا Mycobacterium tuberculosis وتحاربها.',
    howItWorksEn:
        'The vaccine stimulates the immune system to produce specific T lymphocytes that recognize and fight Mycobacterium tuberculosis bacteria.',
    sideEffectsFr:
        'Réaction locale au site d\'injection (rougeur, petite plaie), ganglion sous-axillaire bénin. Réactions sévères rares.',
    sideEffectsAr:
        'تفاعل موضعي عند موقع الحقن (احمرار، جرح صغير)، غدة لمفية تحت الإبط حميدة. ردود فعل شديدة نادرة.',
    sideEffectsEn:
        'Local reaction at the injection site (redness, small sore), benign underarm lymph node. Severe reactions are rare.',
    icon: Icons.medical_services_rounded,
    color: Color(0xFF4CAF50),
  ),
  'HBV': VaccineEducation(
    descriptionFr:
        'Le vaccin contre l\'Hépatite B protège contre une infection virale grave du foie pouvant évoluer vers la cirrhose ou le cancer hépatique. Transmissible par le sang et les fluides corporels.',
    descriptionAr:
        'لقاح التهاب الكبد B يحمي من عدوى فيروسية خطيرة للكبد قد تؤدي إلى تليف الكبد أو سرطان الكبد. ينتقل عبر الدم والسوائل الجسمية.',
    descriptionEn:
        'The Hepatitis B vaccine protects against a serious liver viral infection that can progress to cirrhosis or liver cancer. It is transmitted through blood and body fluids.',
    howItWorksFr:
        'Contient des protéines de surface du virus (Ag HBs). L\'organisme développe des anticorps protecteurs (anti-HBs) sans contact avec le virus vivant.',
    howItWorksAr:
        'يحتوي على بروteins سطحية للفيروس (Ag HBs). يطور الجسم أجساماً مضادة واقية (anti-HBs) دون التعرض للفيروس الحي.',
    howItWorksEn:
        'Contains viral surface proteins (HBsAg). The body develops protective antibodies (anti-HBs) without exposure to live virus.',
    sideEffectsFr:
        'Douleur légère au site d\'injection, légère fièvre possible. Effets graves très rares.',
    sideEffectsAr:
        'ألم خفيف عند موقع الحقن، حمى خفيفة محتملة. آثار جانبية خطيرة نادرة جداً.',
    sideEffectsEn:
        'Mild pain at the injection site, possible low fever. Serious effects are very rare.',
    icon: Icons.biotech_rounded,
    color: Color(0xFF2196F3),
  ),
  'DTCaVPI-Hib-HBV': VaccineEducation(
    descriptionFr:
        'Le vaccin hexavalent protège contre 6 maladies en une seule injection : Diphtérie, Tétanos, Coqueluche acellulaire, Poliomyélite inactivée, Haemophilus influenzae type b, et Hépatite B.',
    descriptionAr:
        'اللقاح السداسي يحمي من 6 أمراض في حقنة واحدة: الدifteria، الكزاز، السعال الديكي، شلل الأطفال، Haemophilus influenzae نوع b، والتهاب الكبد B.',
    descriptionEn:
        'The hexavalent vaccine protects against 6 diseases in one injection: Diphtheria, Tetanus, Acellular Pertussis, Inactivated Polio, Haemophilus influenzae type b, and Hepatitis B.',
    howItWorksFr:
        'Combine plusieurs antigènes et toxoïdes pour générer une immunité simultanée contre 6 agents pathogènes, réduisant le nombre total d\'injections requises.',
    howItWorksAr:
        'يجمع عدة antigènes و toxoïdes لتوليد مناعة متزامنة ضد 6 مسببات أمراض، مما يقلل العدد الإجمالي للحقن المطلوبة.',
    howItWorksEn:
        'Combines several antigens and toxoids to generate simultaneous immunity against 6 pathogens, reducing the total number of injections required.',
    sideEffectsFr:
        'Fièvre (fréquente), rougeur et gonflement au site d\'injection. Compresses froides et paracétamol pour soulager.',
    sideEffectsAr:
        'حمى (شائعة)، احمرار وتورم عند موقع الحقن. كمادات باردة وباراسيتامول للتخفيف.',
    sideEffectsEn:
        'Fever (common), redness and swelling at the injection site. Cold compresses and paracetamol for relief.',
    icon: Icons.vaccines_rounded,
    color: Color(0xFFE91E63),
  ),
  'VPOb': VaccineEducation(
    descriptionFr:
        'Le vaccin antipoliomyélitique oral (bivalent) protège contre la poliomyélite, maladie paralysante causée par un entérovirus. L\'Algérie vise l\'éradication totale.',
    descriptionAr:
        'لقاح شلل الأطفال الفموي (ثنائي) يحمي من شلل الأطفال، مرض شلّ يسببه enterovirus. تسعى الجزائر إلى القضاء عليه بالكامل.',
    descriptionEn:
        'Oral bivalent polio vaccine protects against poliomyelitis, a paralyzing disease caused by an enterovirus. Algeria aims for complete eradication.',
    howItWorksFr:
        'Virus atténués administrés oralement. Ils se répliquent dans l\'intestin, induisant une immunité mucosale et systémique.',
    howItWorksAr:
        'فيروسات مُضعَّفة تُعطى فموياً. تتكاثر في الأمعاء، مما يُحدث مناعة مخاطية وجهازية.',
    howItWorksEn:
        'Attenuated viruses given orally. They replicate in the intestine, inducing mucosal and systemic immunity.',
    sideEffectsFr:
        'Excellente tolérance. Très rarement, poliomyélite associée au vaccin (PVDAV) chez les immunodéprimés.',
    sideEffectsAr:
        'تحمّل ممتاز. نادراً جداً، شلل أطفال مرتبط باللقاح (VAPP) لدى الم immunocompromis.',
    sideEffectsEn:
        'Excellent tolerance. Very rarely, vaccine-associated polio (VAPP) in immunocompromised individuals.',
    icon: Icons.medication_liquid_rounded,
    color: Color(0xFF9C27B0),
  ),
  'VPC': VaccineEducation(
    descriptionFr:
        'Le vaccin pneumococcique conjugué prévient les infections à Streptococcus pneumoniae, cause majeure de pneumonie, méningite et septicémie chez les enfants de moins de 2 ans.',
    descriptionAr:
        'لقاح المكورات الرئوية المقترن يمنع infections بـ Streptococcus pneumoniae، سبب رئيسي للالتهاب الرئوي والتهاب السحايا وتسمم الدم لدى الأطفال دون سنتين.',
    descriptionEn:
        'Conjugated pneumococcal vaccine prevents Streptococcus pneumoniae infections, a major cause of pneumonia, meningitis, and sepsis in children under 2.',
    howItWorksFr:
        'Les antigènes polysaccharidiques sont conjugués à une protéine porteuse pour induire une réponse immunologique robuste chez le nourrissons.',
    howItWorksAr:
        'تُقترن antigènes polysaccharidiques ببروtein حامل لتحفيز استجابة مناعية قوية عند الرضيع.',
    howItWorksEn:
        'Polysaccharide antigens are conjugated to a carrier protein to induce a robust immune response in infants.',
    sideEffectsFr:
        'Irritabilité, somnolence, perte d\'appétit, fièvre légère. Symptômes transitoires resolving en 1-2 jours.',
    sideEffectsAr:
        'تهيّج، نعاس، فقدان شهية، حمى خفيفة. أعراض عابرة تختفي خلال 1-2 يوم.',
    sideEffectsEn:
        'Irritability, drowsiness, loss of appetite, mild fever. Transient symptoms resolving in 1–2 days.',
    icon: Icons.air_rounded,
    color: Color(0xFF00BCD4),
  ),
  'ROR': VaccineEducation(
    descriptionFr:
        'Le vaccin ROR (Rougeole-Oreillons-Rubéole) est un vaccin trivalent vivant atténué contre trois maladies virales très contagieuses. La rougeole peut causer des complications sévères chez les jeunes enfants.',
    descriptionAr:
        'لقاح MMR (حصبة-نكاف-حصبة ألمانية) لقاح ثلاثي حي مُضعَّف ضد ثلاث أمراض فيروسية شديدة العدوى. الحصبة قد تسبب مضاعفات خطيرة لدى الأطفال الصغار.',
    descriptionEn:
        'MMR (Measles-Mumps-Rubella) is a live attenuated trivalent vaccine against three highly contagious viral diseases. Measles can cause severe complications in young children.',
    howItWorksFr:
        'Contient des virus vivants atténués des trois maladies. Induit une immunité durable en un minimum de 2 doses.',
    howItWorksAr:
        'يحتوي على فيروسات حية مُضعَّفة للأمراض الثلاثة. يُحدث مناعة دائمة بجرعتين على الأقل.',
    howItWorksEn:
        'Contains live attenuated viruses for all three diseases. Induces lasting immunity with a minimum of 2 doses.',
    sideEffectsFr:
        'Légère éruption cutanée, fièvre, gonflement des glandes 5-12 jours après. Réactions allergiques sévères très rares.',
    sideEffectsAr:
        'طفح جلدي خفيف، حمى، تورم الغدد بعد 5-12 يوماً. ردود فعل تحسسية شديدة نادرة جداً.',
    sideEffectsEn:
        'Mild rash, fever, gland swelling 5–12 days after. Severe allergic reactions are very rare.',
    icon: Icons.coronavirus_rounded,
    color: Color(0xFFFF5722),
  ),
  'DTCa-VPI': VaccineEducation(
    descriptionFr:
        'Le rappel scolaire tétravalent renforce l\'immunité acquise dans l\'enfance contre Diphtérie, Tétanos, Coqueluche et Poliomyélite, avant l\'entrée à l\'école primaire.',
    descriptionAr:
        'الجرعة المنشطة الرباعية المدرسية تعزز المناعة المكتسبة في الطفولة ضد الدifteria والكزاز والسعال الديكي وشلل الأطفال، قبل دخول المدرسة الابتدائية.',
    descriptionEn:
        'The school-age tetravalent booster strengthens childhood immunity against Diphtheria, Tetanus, Pertussis, and Polio before primary school entry.',
    howItWorksFr:
        'Dose de rappel qui booste les anticorps existants. Particulièrement important car l\'immunité de la petite enfance peut diminuer avec le temps.',
    howItWorksAr:
        'جرعة منشطة تعزز الأجسام المضادة الموجودة. مهمة خاصة لأن مناعة الطفولة قد تضعف مع الوقت.',
    howItWorksEn:
        'Booster dose that boosts existing antibodies. Especially important as early childhood immunity may wane over time.',
    sideEffectsFr:
        'Réaction locale au site d\'injection, légère fatigue. Très bien toléré.',
    sideEffectsAr:
        'تفاعل موضعي عند موقع الحقن، تعب خفيف. يُتحمَّل جيداً جداً.',
    sideEffectsEn:
        'Local reaction at the injection site, mild fatigue. Very well tolerated.',
    icon: Icons.school_rounded,
    color: Color(0xFF607D8B),
  ),
  'dT': VaccineEducation(
    descriptionFr:
        'Le vaccin bivalent adulte renforce la protection contre le Tétanos et la Diphtérie, deux maladies potentiellement mortelles. Le rappel décennal maintient une immunité optimale tout au long de la vie.',
    descriptionAr:
        'اللقاح الثنائي للبالغين يعزز الحماية ضد الكزاز والدifteria، مرضين قد يكونان مميتين. الجرعة المنشطة كل عشر سنوات تحافظ على مناعة مثالية طوال الحياة.',
    descriptionEn:
        'The adult bivalent vaccine strengthens protection against Tetanus and Diphtheria, two potentially fatal diseases. The decennial booster maintains optimal immunity throughout life.',
    howItWorksFr:
        'Contient des toxoïdes tétanique et diphtérique — formes inactivées des toxines — qui stimulent la production d\'anticorps neutralisants.',
    howItWorksAr:
        'يحتوي على toxoïdes الكزاز والdifteria — أشكال معطّلة من السموم — تحفّز إنتاج أجسام مضادة neutralisantes.',
    howItWorksEn:
        'Contains tetanus and diphtheria toxoids — inactivated forms of the toxins — that stimulate production of neutralizing antibodies.',
    sideEffectsFr:
        'Rougeur et sensibilité au point d\'injection, légère fatigue. Effets systémiques rares.',
    sideEffectsAr:
        'احمرار وحساسية عند موقع الحقن، تعب خفيف. آثار جهازية نادرة.',
    sideEffectsEn:
        'Redness and tenderness at the injection site, mild fatigue. Systemic effects are rare.',
    icon: Icons.shield_rounded,
    color: Color(0xFF795548),
  ),
};

/// Returns localized education content for [code], or null if unknown.
VaccineEducation? vaccineEducationFor(String code) => vaccineEducationData[code];
