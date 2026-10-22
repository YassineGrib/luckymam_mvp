/**
 * Critical red flag detection for maternal and infant medical emergencies.
 * Bypasses all LLM logic to escalate immediately to medical professionals.
 */
export function detectRedFlag(text, locale = 'fr') {
  if (!text || typeof text !== 'string') return null;

  const normalized = text
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '');

  const isArabic = locale.startsWith('ar');
  const isEnglish = locale.startsWith('en');

  // 1. Heavy bleeding
  const hasBleeding =
    normalized.includes('saignement') ||
    normalized.includes('perte de sang') ||
    normalized.includes('hemorragie') ||
    text.includes('نزيف') ||
    text.includes('دم كثيف') ||
    text.includes('نزول دم') ||
    normalized.includes('heavy bleeding') ||
    normalized.includes('hemorrhage');

  // 2. Fetal movements
  const hasFetalIssues =
    normalized.includes('ne bouge plus') ||
    normalized.includes('plus de mouvements') ||
    normalized.includes('arret des mouvements') ||
    normalized.includes('bebe ne bouge pas') ||
    text.includes('حركة الجنين') ||
    text.includes('الجنين لا يتحرك') ||
    text.includes('توقف حركة') ||
    normalized.includes('no fetal movement') ||
    normalized.includes('baby stopped moving');

  // 3. Newborn fever (< 3 months)
  const hasNewbornFever =
    (normalized.includes('fievre') && (normalized.includes('bebe') || normalized.includes('nouveau-ne'))) ||
    (normalized.includes('temperature') && normalized.includes('bebe')) ||
    text.includes('حمى رضيع') ||
    text.includes('سخانة البيبي') ||
    text.includes('حرارة الرضيع') ||
    (normalized.includes('fever') && (normalized.includes('baby') || normalized.includes('newborn')));

  // 4. Breathing difficulty
  const hasBreathingDifficulty =
    normalized.includes('ne respire pas') ||
    normalized.includes('difficulte a respirer') ||
    normalized.includes('etouffement') ||
    normalized.includes('asphyxie') ||
    text.includes('ضيق التنفس') ||
    text.includes('لا يتنفس') ||
    text.includes('اختناق') ||
    normalized.includes('cannot breathe') ||
    normalized.includes('difficulty breathing') ||
    normalized.includes('choking');

  // 5. Convulsions / Seizures
  const hasSeizures =
    normalized.includes('convulsion') ||
    normalized.includes('crise depilepsie') ||
    text.includes('تشنج') ||
    text.includes('صرع') ||
    normalized.includes('seizure') ||
    normalized.includes('convulsion');

  // 6. Severe abdominal pain
  const hasSeverePain =
    (normalized.includes('douleur intense') || normalized.includes('douleur aigue')) &&
    (normalized.includes('ventre') || normalized.includes('abdomen') || normalized.includes('grossesse')) ||
    text.includes('ألم بطن شديد') ||
    text.includes('مغص حاد جدا') ||
    normalized.includes('severe abdominal pain');

  // 7. Self-harm / distress
  const hasSelfHarm =
    normalized.includes('me faire du mal') ||
    normalized.includes('suicide') ||
    normalized.includes('en finir') ||
    text.includes('إيذاء نفسي') ||
    text.includes('الانتحار') ||
    normalized.includes('harm myself') ||
    normalized.includes('suicide');

  const triggered =
    hasBleeding ||
    hasFetalIssues ||
    hasNewbornFever ||
    hasBreathingDifficulty ||
    hasSeizures ||
    hasSeverePain ||
    hasSelfHarm;

  if (!triggered) return null;

  if (isArabic) {
    return {
      message:
        '⚠️ تنبيه طبي عاجل: هذه الأعراض تتطلب تقييماً طبياً فورياً ولا يمكن الانتظار.\n' +
        'يرجى التوجه فوراً إلى أقرب مصلحة استعجالات توليد أو طب أطفال، أو استشارة طبيبتكِ على الفور، أو الاتصال بالحماية المدنية والإسعاف (14 / 15). صحتكِ وصحة طفلكِ هي الأولوية القصوى دائماً.',
    };
  }

  if (isEnglish) {
    return {
      message:
        '⚠️ Urgent Medical Alert: These symptoms require immediate professional medical evaluation.\n' +
        'Please go to the nearest emergency clinic immediately or contact emergency services (14 / 15). The safety of you and your baby is the top priority.',
    };
  }

  return {
    message:
      '⚠️ Alerte médicale urgente : Ces symptômes nécessitent une évaluation médicale immédiate sans attendre.\n' +
      'Rends-toi immédiatement aux urgences maternité/pédiatrie les plus proches ou contacte les urgences (14 / 15). Ta sécurité et celle de ton bébé passent avant tout.',
  };
}
