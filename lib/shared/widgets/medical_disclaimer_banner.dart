import 'package:flutter/material.dart';

/// Medical disclaimer banner required by Google Play Health Apps policy.
///
/// Must be displayed on any screen containing:
/// - Vaccine tracking
/// - Growth monitoring (weight, height)
/// - Pregnancy / LMP tracking
/// - Blood type or medical information
///
/// Google Play policy: apps must NOT claim to be certified medical devices
/// or provide medical diagnoses. This banner clarifies the app's scope.
class MedicalDisclaimerBanner extends StatelessWidget {
  const MedicalDisclaimerBanner({super.key, this.compact = false});

  /// When true, shows a shorter single-line version for tight layouts.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (compact) {
      return _CompactDisclaimer(isDark: isDark);
    }

    return _FullDisclaimer(isDark: isDark);
  }
  static String _fullText(String lang) {
    switch (lang) {
      case 'fr':
        return 'Les informations fournies sont destinées au suivi et ne remplacent pas l\'avis d\'un médecin spécialiste.';
      case 'en':
        return 'Information is for tracking only and does not replace professional medical advice.';
      case 'ar':
      default:
        return 'المعلومات الواردة للتتبع والتوثيق فقط، ولا تغني عن استشارة الطبيب المختص.';
    }
  }

  static String _compactText(String lang) {
    switch (lang) {
      case 'fr':
        return 'Suivi indicatif — veuillez consulter votre médecin spécialiste';
      case 'en':
        return 'Tracking only — please consult your specialist doctor';
      case 'ar':
      default:
        return 'للتتبع فقط — يُرجى استشارة طبيبك المختص';
    }
  }
}

class _FullDisclaimer extends StatelessWidget {
  const _FullDisclaimer({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    final isRtl = lang == 'ar';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF2D2A1A)
            : const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? const Color(0xFF5C4A00).withValues(alpha: 0.6)
              : const Color(0xFFF9A825).withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: isDark ? const Color(0xFFFDD835) : const Color(0xFFF57F17),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              MedicalDisclaimerBanner._fullText(lang),
              style: TextStyle(
                fontSize: 12,
                height: 1.5,
                color: isDark
                    ? const Color(0xFFFDD835)
                    : const Color(0xFF6D4C00),
              ),
              textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactDisclaimer extends StatelessWidget {
  const _CompactDisclaimer({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    final isRtl = lang == 'ar';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 14,
            color: isDark ? Colors.amber.shade300 : Colors.orange.shade700,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              MedicalDisclaimerBanner._compactText(lang),
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.amber.shade300 : Colors.orange.shade800,
              ),
              textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
