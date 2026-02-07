import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../l10n/app_localizations.dart';

/// Privacy policy screen.
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.onSurfaceLight;
    final secondaryColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.privacy,
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
            _buildSection(
              context,
              icon: Icons.security_rounded,
              title: l10n.dataProtection,
              content: l10n.dataProtectionDesc,
              textColor: textColor,
              secondaryColor: secondaryColor,
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildSection(
              context,
              icon: Icons.visibility_off_rounded,
              title: l10n.medicalDataPrivacy,
              content: l10n.medicalDataPrivacyDesc,
              textColor: textColor,
              secondaryColor: secondaryColor,
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildSection(
              context,
              icon: Icons.delete_outline_rounded,
              title: l10n.dataDeleteTitle,
              content: l10n.dataDeleteDesc,
              textColor: textColor,
              secondaryColor: secondaryColor,
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildSection(
              context,
              icon: Icons.cloud_off_rounded,
              title: l10n.offlineData,
              content: l10n.offlineDataDesc,
              textColor: textColor,
              secondaryColor: secondaryColor,
            ),
            const SizedBox(height: AppSpacing.xl),
            Center(
              child: Text(
                'MVP - ${l10n.appName} 2026',
                style: GoogleFonts.outfit(fontSize: 12, color: secondaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
    required Color textColor,
    required Color secondaryColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E2E) : Colors.white;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primaryLight, size: 24),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  content,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: secondaryColor,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
