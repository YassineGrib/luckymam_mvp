import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/services/compliance_service.dart';
import '../../core/services/analytics_service.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/auth_logo_background.dart';
import '../../shared/widgets/buttons/primary_button.dart';
import '../../core/theme/app_typography.dart';

/// Screen requiring the user to consent to Algerian Law 18-07 on personal data protection.
class Law1807ConsentScreen extends StatefulWidget {
  const Law1807ConsentScreen({
    super.key,
    this.complianceService,
    this.analyticsService,
  });

  final ComplianceService? complianceService;
  final AnalyticsService? analyticsService;

  @override
  State<Law1807ConsentScreen> createState() => _Law1807ConsentScreenState();
}

class _Law1807ConsentScreenState extends State<Law1807ConsentScreen> {
  late final ComplianceService _complianceService;
  late final AnalyticsService _analyticsService;
  final ScrollController _scrollController = ScrollController();
  bool _isAccepted = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _complianceService = widget.complianceService ?? ComplianceService();
    _analyticsService = widget.analyticsService ?? AnalyticsService();
    // Log analytical event when user views the consent screen
    _analyticsService.logLaw1807Viewed();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    final l10n = AppLocalizations.of(context)!;

    if (!_isAccepted) {
      await _analyticsService.logLaw1807Blocked();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.law1807Error,
            style: AppTypography.fromContext(
              context,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Save consent to user profile & append-only compliance audit log
      await _complianceService.saveConsent(
        consent: true,
        textVersion: '18-07-v1',
        fullText: l10n.law1807Text,
      );

      await _analyticsService.logLaw1807Accepted();

      if (!mounted) return;
      context.go('/select-language');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.errorWithMessage(e.toString())),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final titleColor = isDark ? Colors.white : AppColors.onSurfaceLight;
    final bodyColor = isDark
        ? Colors.white.withValues(alpha: 0.88)
        : AppColors.onSurfaceLight.withValues(alpha: 0.90);
    final secondaryTextColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final brandAccent = isDark ? AppColors.magentaPink : AppColors.coral;

    // Flat, semi-transparent card styling to blend seamlessly into background
    final cardBgColor = isDark
        ? Colors.white.withValues(alpha: 0.04)
        : Colors.white.withValues(alpha: 0.60);
    final cardBorderColor = isDark
        ? Colors.white.withValues(alpha: 0.10)
        : AppColors.dividerLight.withValues(alpha: 0.80);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: Stack(
        children: [
          // Background brand watermark
          const AuthLogoBackground(
            lightOpacity: 0.06,
            darkOpacity: 0.04,
          ),

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
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.shield_outlined,
                          color: brandAccent,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          l10n.law1807Title,
                          style: AppTypography.fromContext(
                            context,
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: titleColor,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Legal Text Container: Flat, semi-transparent, comfortable scrolling
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: cardBgColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: cardBorderColor, width: 1),
                      ),
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Core legal clause
                            Text(
                              l10n.law1807Text,
                              textAlign: TextAlign.justify,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: bodyColor,
                                    height: 1.65,
                                    fontSize: 14,
                                  ),
                            ),

                            const SizedBox(height: AppSpacing.md),

                            // Clickable Link to Full Legal Text & Privacy Policy
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => context.push('/privacy-policy'),
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: brandAccent.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: brandAccent.withValues(alpha: 0.20),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.description_outlined,
                                        size: 18,
                                        color: brandAccent,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          l10n.law1807ReadFullTerms,
                                          style: AppTypography.fromContext(
                                            context,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: brandAccent,
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        size: 12,
                                        color: brandAccent,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: AppSpacing.md),

                            Divider(color: cardBorderColor, height: 1),

                            const SizedBox(height: AppSpacing.sm),

                            // Official Legal Reference citation
                            Text(
                              l10n.authLaw1807LegalRef,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: secondaryTextColor,
                                    fontSize: 11,
                                    height: 1.4,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Easy Checkbox Row: Large hit target (min 56px), single-tap instant toggle, no scroll lock
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _isAccepted = !_isAccepted;
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 56),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Checkbox(
                              value: _isAccepted,
                              onChanged: (value) {
                                setState(() {
                                  _isAccepted = value ?? false;
                                });
                              },
                              activeColor: brandAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              side: BorderSide(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                                width: 1.5,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                l10n.law1807Checkbox,
                                style: AppTypography.fromContext(
                                  context,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: titleColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Continue button
                  PrimaryButton(
                    text: l10n.continueText,
                    onPressed: _handleContinue,
                    isLoading: _isLoading,
                  ),

                  const SizedBox(height: AppSpacing.xs),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
