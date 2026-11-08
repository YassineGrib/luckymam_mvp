import '../../core/services/safe_log.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/extensions/l10n_extension.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/services/analytics_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../l10n/app_localizations.dart';
import '../profile/providers/profile_providers.dart';
import '../../shared/widgets/auth_logo_background.dart';

/// Language item representation for the onboarding selection.
class _LanguageOption {
  final String code;
  final String nativeName;
  final String badge;

  const _LanguageOption({
    required this.code,
    required this.nativeName,
    required this.badge,
  });
}

/// Screen displayed immediately after Law 18-07 consent validation (LM-ONB-003).
/// Allows the user to select between French, Arabic (RTL), and English.
/// Changes the locale reactively and persistently across the entire app.
class LanguageSelectionScreen extends ConsumerStatefulWidget {
  const LanguageSelectionScreen({super.key, this.isModal = false});

  /// If true, tapping continue pops the screen instead of navigating to /home.
  final bool isModal;

  @override
  ConsumerState<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState
    extends ConsumerState<LanguageSelectionScreen> {
  bool _isSubmitting = false;

  static const List<_LanguageOption> _options = [
    _LanguageOption(code: 'fr', nativeName: 'Français', badge: 'FR'),
    _LanguageOption(code: 'ar', nativeName: 'العربية', badge: 'عربي'),
    _LanguageOption(code: 'en', nativeName: 'English', badge: 'EN'),
  ];

  Future<void> _handleContinue(String selectedCode) async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    try {
      HapticFeedback.mediumImpact();
      // Ensure locale is persisted
      await ref.read(localeProvider.notifier).setLocale(Locale(selectedCode));
      AnalyticsService().logEvent(
        'language_selected',
        parameters: {'language': selectedCode, 'source': 'onboarding'},
      );

      // LM-ONB-004: Automatically generate primary "MAM" profile at the end of onboarding
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      try {
        await ref
            .read(profileServiceProvider)
            .ensureMamProfileCreated(defaultName: l10n.defaultMotherName);
      } catch (e) {
        safeDebugPrint('Error ensuring MAM profile: ${e.runtimeType}');
      }

      if (!mounted) return;
      if (widget.isModal && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
        context.go('/home');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final activeLocale = ref.watch(localeProvider);
    final selectedCode = activeLocale.languageCode;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRtl = context.isRtl;

    final titleColor = isDark ? Colors.white : AppColors.onSurfaceLight;
    final secondaryTextColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final brandAccent = isDark ? AppColors.magentaPink : AppColors.coral;

    final cardBgColor = isDark
        ? Colors.white.withValues(alpha: 0.04)
        : Colors.white.withValues(alpha: 0.85);
    final cardBorderColor = isDark
        ? Colors.white.withValues(alpha: 0.10)
        : AppColors.dividerLight.withValues(alpha: 0.80);

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: Stack(
        children: [
          // Ambient soft background glow & watermark
          const AuthLogoBackground(lightOpacity: 0.06, darkOpacity: 0.04),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPaddingH,
                vertical: AppSpacing.screenPaddingV,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.sm),

                  // Header with badge & title
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: brandAccent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.translate_rounded,
                          color: brandAccent,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.onboardingLanguageTitle,
                              style: AppTypography.fromContext(
                                context,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: titleColor,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              l10n.profileLanguage,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: brandAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Subtitle explanatory card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: cardBgColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: cardBorderColor, width: 1),
                    ),
                    child: Text(
                      l10n.onboardingLanguageSubtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: secondaryTextColor,
                        height: 1.5,
                        fontSize: 13.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Language Options List
                  Expanded(
                    child: ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      itemCount: _options.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, index) {
                        final option = _options[index];
                        final isSelected = option.code == selectedCode;

                        String subtitle;
                        if (option.code == 'ar') {
                          subtitle = l10n.onboardingLanguageArSubtitle;
                        } else if (option.code == 'en') {
                          subtitle = l10n.onboardingLanguageEnSubtitle;
                        } else {
                          subtitle = l10n.onboardingLanguageFrSubtitle;
                        }

                        return Semantics(
                          selected: isSelected,
                          button: true,
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              ref
                                  .read(localeProvider.notifier)
                                  .setLocale(Locale(option.code));
                            },
                            behavior: HitTestBehavior.opaque,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeOutCubic,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? brandAccent.withValues(
                                        alpha: isDark ? 0.16 : 0.08,
                                      )
                                    : cardBgColor,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: isSelected
                                      ? brandAccent
                                      : cardBorderColor,
                                  width: isSelected ? 2 : 1,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: brandAccent.withValues(
                                            alpha: 0.18,
                                          ),
                                          blurRadius: 14,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: isDark ? 0.15 : 0.02,
                                          ),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                              ),
                              child: Row(
                                children: [
                                  // Language Badge / Flag abbreviation
                                  Container(
                                    width: 44,
                                    height: 44,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? brandAccent.withValues(alpha: 0.20)
                                          : (isDark
                                                ? Colors.white.withValues(
                                                    alpha: 0.08,
                                                  )
                                                : Colors.black.withValues(
                                                    alpha: 0.05,
                                                  )),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      option.badge,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                        color: isSelected
                                            ? brandAccent
                                            : titleColor,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 16),

                                  // Title & Subtitle
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          option.nativeName,
                                          style: AppTypography.fromContext(
                                            context,
                                            fontSize: 16,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.w600,
                                            color: titleColor,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          subtitle,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: secondaryTextColor,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  // Radio Selection Indicator
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected
                                          ? brandAccent
                                          : Colors.transparent,
                                      border: Border.all(
                                        color: isSelected
                                            ? brandAccent
                                            : (isDark
                                                  ? Colors.white38
                                                  : Colors.grey.shade400),
                                        width: 2,
                                      ),
                                    ),
                                    child: isSelected
                                        ? const Icon(
                                            Icons.check_rounded,
                                            size: 15,
                                            color: Colors.white,
                                          )
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Bottom Validation Button
                  ElevatedButton(
                    onPressed: _isSubmitting
                        ? null
                        : () => _handleContinue(selectedCode),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brandAccent,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: brandAccent.withValues(
                        alpha: 0.45,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 3,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                l10n.continueText,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                isRtl
                                    ? Icons.arrow_back_rounded
                                    : Icons.arrow_forward_rounded,
                                size: 18,
                              ),
                            ],
                          ),
                  ),

                  const SizedBox(height: AppSpacing.sm),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
