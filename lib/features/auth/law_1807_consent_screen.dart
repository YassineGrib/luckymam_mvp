import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/services/compliance_service.dart';
import '../../core/services/analytics_service.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/buttons/primary_button.dart';
import '../../core/theme/app_typography.dart';

/// Screen requiring the user to consent to Algerian Law 18-07 on personal data protection.
class Law1807ConsentScreen extends StatefulWidget {
  const Law1807ConsentScreen({super.key});

  @override
  State<Law1807ConsentScreen> createState() => _Law1807ConsentScreenState();
}

class _Law1807ConsentScreenState extends State<Law1807ConsentScreen> {
  final _complianceService = ComplianceService();
  final _analyticsService = AnalyticsService();
  final ScrollController _scrollController = ScrollController();
  bool _isAccepted = false;
  bool _isLoading = false;
  bool _hasScrolledToBottom = false;

  @override
  void initState() {
    super.initState();
    // Log analytical event when user views the consent screen
    _analyticsService.logLaw1807Viewed();
    _scrollController.addListener(_scrollListener);
    
    // Check if the content is short enough that it doesn't need scrolling
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        if (_scrollController.position.maxScrollExtent <= 0) {
          setState(() {
            _hasScrolledToBottom = true;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.hasClients) {
      final position = _scrollController.position;
      if (position.maxScrollExtent <= 0 || position.pixels >= position.maxScrollExtent - 20) {
        if (!_hasScrolledToBottom) {
          setState(() {
            _hasScrolledToBottom = true;
          });
        }
      }
    }
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
            style: AppTypography.fromContext(context, fontSize: 14, fontWeight: FontWeight.w500),
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
    final bodyColor = isDark ? Colors.white70 : Colors.black87;
    final cardBgColor = isDark ? AppColors.surfaceDark : Colors.white;
    final secondaryTextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

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
                      color: AppColors.magentaPink.withValues(alpha: 0.12),
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
                      style: AppTypography.fromContext(context, fontSize: 20, fontWeight: FontWeight.bold, color: titleColor),
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
                        color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Scrollbar(
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      padding: const EdgeInsets.only(right: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.law1807Text,
                            textAlign: TextAlign.justify,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: bodyColor, height: 1.7),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Divider(color: isDark ? AppColors.dividerDark : AppColors.dividerLight),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            l10n.authLaw1807LegalRef,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: secondaryTextColor),
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
                  if (!_hasScrolledToBottom) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          l10n.authLaw1807ScrollWarning,
                          style: AppTypography.fromContext(context, fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        backgroundColor: AppColors.magentaPink,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                    return;
                  }
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
                        onChanged: !_hasScrolledToBottom
                            ? null
                            : (value) {
                                setState(() {
                                  _isAccepted = value ?? false;
                                });
                              },
                        activeColor: AppColors.magentaPink,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        side: BorderSide(
                          color: _hasScrolledToBottom
                              ? (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)
                              : Colors.grey.withValues(alpha: 0.5),
                          width: 1.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.law1807Checkbox,
                          style: AppTypography.fromContext(context, fontSize: 15, fontWeight: FontWeight.w600, color: _hasScrolledToBottom
                                ? titleColor
                                : (isDark ? Colors.white38 : Colors.black38)),
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
