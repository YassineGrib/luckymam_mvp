import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../core/extensions/l10n_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../l10n/app_localizations.dart';
import '../../profile/models/profile_models.dart';
import '../models/appointment.dart';
import '../providers/health_providers.dart';
import '../widgets/appointment_card.dart';
import '../../../core/theme/app_typography.dart';

String _healthDateLocale(String languageCode) =>
    languageCode == 'fr' ? 'fr_FR' : languageCode;

/// Appointments screen — list of doctor visits with file attachments.
class AppointmentsScreen extends ConsumerStatefulWidget {
  const AppointmentsScreen({super.key, required this.child});
  final Child child;

  @override
  ConsumerState<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends ConsumerState<AppointmentsScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final bgColor = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;
    final textColor = isDark ? Colors.white : AppColors.onSurfaceLight;
    final secondary = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    final apptAsync = ref.watch(appointmentsProvider(widget.child.id));

    return Scaffold(
      backgroundColor: bgColor,
      body: apptAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            l10n.healthErrorWithDetail('$e'),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.error),
          ),
        ),
        data: (appointments) {
          if (appointments.isEmpty) {
            return _buildEmpty(primary, secondary, l10n);
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPaddingH,
              AppSpacing.md,
              AppSpacing.screenPaddingH,
              100,
            ),
            itemCount: appointments.length,
            itemBuilder: (_, i) => AppointmentCard(
              appointment: appointments[i],
              onDelete: () => _confirmDelete(appointments[i]),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          l10n.healthAppointmentFab,
          style: AppTypography.fromContext(context, fontSize: 14, fontWeight: FontWeight.w600),
        ),
        onPressed: () => _showAddSheet(context, primary, textColor, isDark),
      ),
    );
  }

  Widget _buildEmpty(Color primary, Color secondary, AppLocalizations l10n) =>
      Center(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_note_outlined,
            size: 64,
            color: primary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.healthNoAppointmentsTitle,
            style: AppTypography.fromContext(context, fontSize: 18, fontWeight: FontWeight.bold, color: secondary),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.healthNoAppointmentsHint,
            style: AppTypography.fromContext(context, fontSize: 13, color: secondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );

  void _confirmDelete(Appointment appt) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.onSurfaceLight;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          l10n.healthDeleteAppointmentTitle,
          style: AppTypography.fromContext(context, fontSize: 14, fontWeight: FontWeight.bold, color: textColor),
        ),
        content: Text(
          appt.doctorName,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: textColor.withValues(alpha: 0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.healthCancel, style: Theme.of(context).textTheme.bodyMedium),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref
                  .read(appointmentActionsProvider.notifier)
                  .deleteAppointment(
                    childId: widget.child.id,
                    appointment: appt,
                  );
            },
            child: Text(
              l10n.healthDelete,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddSheet(
    BuildContext context,
    Color primary,
    Color textColor,
    bool isDark,
  ) {
    final l10n = context.l10n;
    final dateLocale = _healthDateLocale(
      Localizations.localeOf(context).languageCode,
    );
    DateTime selectedDate = DateTime.now();
    AppointmentType selectedType = AppointmentType.pediatre;
    final doctorCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    final attachedFiles = <File>[];
    final surface = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.screenPaddingH,
            AppSpacing.lg,
            AppSpacing.screenPaddingH,
            MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.lg,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: textColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  l10n.healthNewAppointment,
                  style: AppTypography.fromContext(context, fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
                ),
                const SizedBox(height: AppSpacing.md),

                // Doctor name
                TextField(
                  controller: doctorCtrl,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: textColor),
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: l10n.healthDoctorName,
                    labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: textColor.withValues(alpha: 0.6)),
                    prefixIcon: Icon(
                      Icons.person_outline_rounded,
                      color: primary,
                    ),
                    filled: true,
                    fillColor: isDark
                        ? AppColors.inputBackgroundDark
                        : AppColors.inputBackgroundLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark
                            ? AppColors.inputBorderDark
                            : AppColors.inputBorderLight,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark
                            ? AppColors.inputBorderDark
                            : AppColors.inputBorderLight,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                // Type dropdown
                DropdownButtonFormField<AppointmentType>(
                  initialValue: selectedType,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: textColor),
                  dropdownColor: isDark
                      ? AppColors.surfaceDark
                      : AppColors.surfaceLight,
                  decoration: InputDecoration(
                    labelText: l10n.healthSpecialty,
                    labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: textColor.withValues(alpha: 0.6)),
                    prefixIcon: Icon(
                      Icons.local_hospital_outlined,
                      color: primary,
                    ),
                    filled: true,
                    fillColor: isDark
                        ? AppColors.inputBackgroundDark
                        : AppColors.inputBackgroundLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark
                            ? AppColors.inputBorderDark
                            : AppColors.inputBorderLight,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark
                            ? AppColors.inputBorderDark
                            : AppColors.inputBorderLight,
                      ),
                    ),
                  ),
                  items: AppointmentType.values
                      .map(
                        (t) => DropdownMenuItem(
                          value: t,
                          child: Text(
                            healthAppointmentTypeLabel(l10n, t),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: textColor),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setModal(() => selectedType = v);
                  },
                ),
                const SizedBox(height: AppSpacing.sm),

                // Date picker
                GestureDetector(
                  onTap: () async {
                    final p = await showDatePicker(
                      context: ctx,
                      initialDate: selectedDate,
                      firstDate: widget.child.birthDate,
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (p != null) setModal(() => selectedDate = p);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.inputBackgroundDark
                          : AppColors.inputBackgroundLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? AppColors.inputBorderDark
                            : AppColors.inputBorderLight,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 20,
                          color: primary,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          DateFormat('d MMMM yyyy', dateLocale).format(
                            selectedDate,
                          ),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: textColor),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                // Notes
                TextField(
                  controller: notesCtrl,
                  maxLines: 2,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: textColor),
                  decoration: InputDecoration(
                    hintText: l10n.healthNotesObservationsOptional,
                    hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: textColor.withValues(alpha: 0.4)),
                    filled: true,
                    fillColor: isDark
                        ? AppColors.inputBackgroundDark
                        : AppColors.inputBackgroundLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark
                            ? AppColors.inputBorderDark
                            : AppColors.inputBorderLight,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark
                            ? AppColors.inputBorderDark
                            : AppColors.inputBorderLight,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                // File attachment row
                Row(
                  children: [
                    _AttachBtn(
                      label: l10n.healthAttachPhoto,
                      icon: Icons.camera_alt_outlined,
                      primary: primary,
                      textColor: textColor,
                      onTap: () async {
                        final picked = await ImagePicker().pickImage(
                          source: ImageSource.gallery,
                          imageQuality: 80,
                        );
                        if (picked != null) {
                          setModal(() => attachedFiles.add(File(picked.path)));
                        }
                      },
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _AttachBtn(
                      label: l10n.healthAttachPdfFile,
                      icon: Icons.attach_file_rounded,
                      primary: primary,
                      textColor: textColor,
                      onTap: () async {
                        final result = await FilePicker.platform.pickFiles(
                          allowMultiple: false,
                          type: FileType.custom,
                          allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
                        );
                        if (result != null &&
                            result.files.single.path != null) {
                          setModal(
                            () => attachedFiles.add(
                              File(result.files.single.path!),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),

                // File preview strip
                if (attachedFiles.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    height: 64,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: attachedFiles.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (_, i) => Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              attachedFiles[i],
                              width: 64,
                              height: 64,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                width: 64,
                                height: 64,
                                color: AppColors.error.withValues(alpha: 0.1),
                                child: const Icon(
                                  Icons.picture_as_pdf_rounded,
                                  color: AppColors.error,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: GestureDetector(
                              onTap: () =>
                                  setModal(() => attachedFiles.removeAt(i)),
                              child: Container(
                                width: 18,
                                height: 18,
                                decoration: const BoxDecoration(
                                  color: AppColors.error,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close_rounded,
                                  size: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),

                // Save button
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () async {
                        if (doctorCtrl.text.trim().isEmpty) return;
                        Navigator.pop(ctx);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              attachedFiles.isNotEmpty
                                  ? l10n.healthUploadingFiles
                                  : l10n.healthSaving,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            duration: const Duration(seconds: 30),
                          ),
                        );

                        final ok = await ref
                            .read(appointmentActionsProvider.notifier)
                            .addAppointment(
                              childId: widget.child.id,
                              date: selectedDate,
                              doctorName: doctorCtrl.text.trim(),
                              type: selectedType,
                              notes: notesCtrl.text.isNotEmpty
                                  ? notesCtrl.text
                                  : null,
                              files: attachedFiles,
                            );

                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              ok
                                  ? l10n.healthAppointmentSaved
                                  : l10n.healthSaveError,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            backgroundColor: ok
                                ? AppColors.success
                                : AppColors.error,
                          ),
                        );
                      },
                      child: Text(
                        l10n.healthSave,
                        style: AppTypography.fromContext(context, fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AttachBtn extends StatelessWidget {
  const _AttachBtn({
    required this.label,
    required this.icon,
    required this.primary,
    required this.textColor,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final Color primary;
  final Color textColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Expanded(
    child: OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16, color: primary),
      label: Text(
        label,
        style: AppTypography.fromContext(context, fontSize: 13, color: primary),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: primary.withValues(alpha: 0.4)),
        padding: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
  );
}
