import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/extensions/l10n_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../l10n/app_localizations.dart';
import '../models/appointment.dart';
import '../../../core/theme/app_typography.dart';

String healthAppointmentTypeLabel(AppLocalizations l10n, AppointmentType type) =>
    switch (type) {
      AppointmentType.generaliste => l10n.healthApptTypeGeneraliste,
      AppointmentType.pediatre => l10n.healthApptTypePediatre,
      AppointmentType.dentiste => l10n.healthApptTypeDentiste,
      AppointmentType.ophtalmologue => l10n.healthApptTypeOphtalmologue,
      AppointmentType.cardiologue => l10n.healthApptTypeCardiologue,
      AppointmentType.autre => l10n.healthApptTypeAutre,
    };

String _healthDateLocale(String languageCode) =>
    languageCode == 'fr' ? 'fr_FR' : languageCode;

/// Card displaying an appointment with doctor info, type chip, and file thumbnails.
class AppointmentCard extends StatelessWidget {
  const AppointmentCard({
    super.key,
    required this.appointment,
    required this.onDelete,
    this.onTap,
  });

  final Appointment appointment;
  final VoidCallback onDelete;
  final VoidCallback? onTap;

  Color _typeColor(AppointmentType type) => switch (type) {
    AppointmentType.pediatre => const Color(0xFF4CAF50),
    AppointmentType.dentiste => AppColors.smaltBlue,
    AppointmentType.ophtalmologue => const Color(0xFF9C27B0),
    AppointmentType.cardiologue => AppColors.error,
    AppointmentType.generaliste => AppColors.casablanca,
    AppointmentType.autre => AppColors.textSecondaryLight,
  };

  IconData _typeIcon(AppointmentType type) => switch (type) {
    AppointmentType.pediatre => Icons.child_care_rounded,
    AppointmentType.dentiste => Icons.medical_services_outlined,
    AppointmentType.ophtalmologue => Icons.visibility_outlined,
    AppointmentType.cardiologue => Icons.favorite_border_rounded,
    AppointmentType.generaliste => Icons.local_hospital_outlined,
    AppointmentType.autre => Icons.person_outline_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final textColor = isDark ? Colors.white : AppColors.onSurfaceLight;
    final secondary = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final typeColor = _typeColor(appointment.type);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.sm,
              ),
              child: Row(
                children: [
                  // Type icon
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _typeIcon(appointment.type),
                      color: typeColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appointment.doctorName,
                          style: AppTypography.fromContext(context, fontSize: 15, fontWeight: FontWeight.w600, color: textColor),
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: typeColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                healthAppointmentTypeLabel(
                                  l10n,
                                  appointment.type,
                                ),
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600, color: typeColor),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              DateFormat(
                                'd MMM yyyy',
                                _healthDateLocale(
                                  Localizations.localeOf(context).languageCode,
                                ),
                              ).format(appointment.date),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: secondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Delete
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.error,
                      size: 20,
                    ),
                    onPressed: onDelete,
                  ),
                ],
              ),
            ),

            // Notes
            if (appointment.notes != null && appointment.notes!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  AppSpacing.sm,
                ),
                child: Text(
                  appointment.notes!,
                  style: AppTypography.fromContext(context, fontSize: 13, color: secondary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

            // File thumbnails
            if (appointment.fileUrls.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  AppSpacing.md,
                ),
                child: SizedBox(
                  height: 64,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: appointment.fileUrls.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, i) {
                      final url = appointment.fileUrls[i];
                      final isPdf = url.toLowerCase().contains('.pdf');
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: isPdf
                            ? Container(
                                width: 64,
                                height: 64,
                                color: AppColors.error.withValues(alpha: 0.1),
                                child: const Icon(
                                  Icons.picture_as_pdf_rounded,
                                  color: AppColors.error,
                                  size: 28,
                                ),
                              )
                            : CachedNetworkImage(
                                imageUrl: url,
                                width: 64,
                                height: 64,
                                fit: BoxFit.cover,
                                placeholder: (_, _) => Container(
                                  width: 64,
                                  height: 64,
                                  color: isDark
                                      ? AppColors.surfaceContainerDark
                                      : AppColors.surfaceContainerLight,
                                ),
                                errorWidget: (_, _, _) => const Icon(
                                  Icons.broken_image_outlined,
                                  size: 28,
                                ),
                              ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
