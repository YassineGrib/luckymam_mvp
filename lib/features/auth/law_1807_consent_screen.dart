import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/services/compliance_service.dart';
import '../../core/services/analytics_service.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/buttons/primary_button.dart';

/// Screen requiring the user to consent to Algerian Law 18-07 on personal data protection.
class Law1807ConsentScreen extends StatefulWidget {
  const Law1807ConsentScreen({super.key});

  @override
  State<Law1807ConsentScreen> createState() => _Law1807ConsentScreenState();
}

class _Law1807ConsentScreenState extends State<Law1807ConsentScreen> {
  final _complianceService = ComplianceService();
  final _analyticsService = AnalyticsService();
  bool _isAccepted = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Log analytical event when user views the consent screen
    _analyticsService.logLaw1807Viewed();
  }

  Future<void> _handleContinue() async {
    final l10n = AppLocalizations.of(context)!;
    
    if (!_isAccepted) {
      // Log analytics event for blocked action
      await _analyticsService.logLaw1807Blocked();
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.law1807Error,
            style: GoogleFonts.outfit(fontWeight: FontWeight.w500),
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

      // Log analytics event for accepted action
      await _analyticsService.logLaw1807Accepted();

      if (!mounted) return;
      context.go('/home');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
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
    final bodyColor = isDark ? Colors.white70 : Colors.black87;
    final cardBgColor = isDark ? AppColors.surfaceDark : Colors.white;
    final secondaryTextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPaddingH,
            vertical: AppSpacing.screenPaddingV,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.md),
              
              // Icon & Title Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.magentaPink.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.gavel_rounded,
                      color: AppColors.magentaPink,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      l10n.law1807Title,
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppSpacing.lg),
              
              // Legal Text Container (Scrollable)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: cardBgColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Scrollbar(
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(right: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.law1807Text,
                            textAlign: TextAlign.justify,
                            style: GoogleFonts.outfit(
                              fontSize: 14.5,
                              height: 1.7,
                              color: bodyColor,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Divider(color: isDark ? AppColors.dividerDark : AppColors.dividerLight),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            isRtl 
                              ? 'مرجع الامتثال القانوني: القانون الجزائري رقم 18-07 المتعلق بحماية الأشخاص الطبيعيين في مجال معالجة المعطيات ذات الطابع الشخصي.'
                              : 'Référence d\'alignement légal : Loi Algérienne n° 18-07 relative à la protection des personnes physiques dans le traitement des données à caractère personnel.',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              color: secondaryTextColor,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: AppSpacing.lg),
              
              // Checkbox row (Target at least 48px high for accessibility)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isAccepted = !_isAccepted;
                  });
                },
                behavior: HitTestBehavior.opaque,
                child: Container(
                  constraints: const BoxConstraints(minHeight: 48),
                  padding: const EdgeInsets.symmetric(vertical: 4),
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
                        activeColor: AppColors.magentaPink,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        side: BorderSide(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          width: 1.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.law1807Checkbox,
                          style: GoogleFonts.outfit(
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
              
              const SizedBox(height: AppSpacing.lg),
              
              // Continue button
              PrimaryButton(
                text: l10n.continueText,
                onPressed: _handleContinue,
                isLoading: _isLoading,
              ),
              
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }
}
