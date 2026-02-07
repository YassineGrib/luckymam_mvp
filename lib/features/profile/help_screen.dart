import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../l10n/app_localizations.dart';

/// Help and support screen with FAQ and contact options.
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.onSurfaceLight;
    final secondaryColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final cardColor = isDark ? const Color(0xFF1E1E2E) : Colors.white;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.helpAndSupport,
          style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // FAQ Section
            Text(
              l10n.faqTitle,
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _FaqItem(
              question: l10n.faqAddChild,
              answer: l10n.faqAddChildAnswer,
              cardColor: cardColor,
              textColor: textColor,
              secondaryColor: secondaryColor,
            ),
            _FaqItem(
              question: l10n.faqCycle,
              answer: l10n.faqCycleAnswer,
              cardColor: cardColor,
              textColor: textColor,
              secondaryColor: secondaryColor,
            ),
            _FaqItem(
              question: l10n.faqEditInfo,
              answer: l10n.faqEditInfoAnswer,
              cardColor: cardColor,
              textColor: textColor,
              secondaryColor: secondaryColor,
            ),
            _FaqItem(
              question: l10n.faqDataSecurity,
              answer: l10n.faqDataSecurityAnswer,
              cardColor: cardColor,
              textColor: textColor,
              secondaryColor: secondaryColor,
            ),
            const SizedBox(height: AppSpacing.xl),

            // Contact Section
            Text(
              l10n.contactUs,
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _ContactTile(
              icon: Icons.email_outlined,
              title: l10n.emailSupport,
              subtitle: l10n.emailSupportHint,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.sendEmailPrompt),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              cardColor: cardColor,
              textColor: textColor,
              secondaryColor: secondaryColor,
            ),
            const SizedBox(height: AppSpacing.sm),
            _ContactTile(
              icon: Icons.chat_bubble_outline_rounded,
              title: l10n.liveChat,
              subtitle: l10n.liveChatUnavailable,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.featureComingSoon),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
              cardColor: cardColor,
              textColor: textColor,
              secondaryColor: secondaryColor,
            ),
            const SizedBox(height: AppSpacing.xl),

            // App Info
            Center(
              child: Column(
                children: [
                  Text(
                    '${l10n.appName} MVP',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.appVersion,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: secondaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FaqItem extends StatefulWidget {
  const _FaqItem({
    required this.question,
    required this.answer,
    required this.cardColor,
    required this.textColor,
    required this.secondaryColor,
  });

  final String question;
  final String answer;
  final Color cardColor;
  final Color textColor;
  final Color secondaryColor;

  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: widget.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => setState(() => _isExpanded = !_isExpanded),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.question,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: widget.textColor,
                      ),
                    ),
                  ),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: widget.secondaryColor,
                  ),
                ],
              ),
              if (_isExpanded) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  widget.answer,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    color: widget.secondaryColor,
                    height: 1.5,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.cardColor,
    required this.textColor,
    required this.secondaryColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color cardColor;
  final Color textColor;
  final Color secondaryColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primaryLight, size: 22),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: secondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: secondaryColor, size: 20),
          ],
        ),
      ),
    );
  }
}
