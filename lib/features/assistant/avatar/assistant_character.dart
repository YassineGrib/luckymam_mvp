import 'package:flutter/material.dart';

/// The 3 distinct visual character directions supported by the avatar engine.
/// Originates from the CHARACTER_AI specification by Louis Raillé.
enum AssistantCharacter {
  /// Lueur (Default): "Une sphère qui prend la couleur de son état. On sait ce qui se passe sans lire, même de loin."
  lueur,

  /// Mochi: "Un petit pain de riz aplati, yeux ronds et joues qui rosissent. Le plus mignon, un peu moins neutre."
  mochi,

  /// Galet: "Une bille mate avec deux yeux en pilule. Très lisible en tout petit."
  galet;

  String displayName(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    switch (this) {
      case AssistantCharacter.lueur:
        return isAr ? 'بريق (Lueur)' : 'Lueur';
      case AssistantCharacter.mochi:
        return isAr ? 'موتشي (Mochi)' : 'Mochi';
      case AssistantCharacter.galet:
        return isAr ? 'غاليه (Galet)' : 'Galet';
    }
  }

  String displayDescription(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    switch (this) {
      case AssistantCharacter.lueur:
        return isAr
            ? 'كرة مضيئة تأخذ لون حالتها بدقة، تتيح معرفة ما يجري فوراً دون قراءة.'
            : 'Une sphère qui prend la couleur de son état. On sait ce qui se passe sans lire, même de loin.';
      case AssistantCharacter.mochi:
        return isAr
            ? 'كائن هلامي ناعم الملمس، بأعين مستديرة ووجنتين ورديتين دافئتين.'
            : 'Un petit pain de riz aplati, yeux ronds et joues qui rosissent.';
      case AssistantCharacter.galet:
        return isAr
            ? 'حصى أملس بتصميم مينيمالي نقي، وأعين كبسولية واضحة جداً.'
            : 'Une bille mate avec deux yeux en pilule. Très lisible en tout petit.';
    }
  }

  static AssistantCharacter fromString(String? val) {
    switch (val) {
      case 'mochi':
        return AssistantCharacter.mochi;
      case 'galet':
        return AssistantCharacter.galet;
      case 'lueur':
      default:
        return AssistantCharacter.lueur; // Default is always Lueur!
    }
  }
}
