import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/extensions/l10n_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../l10n/app_localizations.dart';
import '../../profile/models/profile_models.dart';
import '../../profile/providers/profile_providers.dart';
import '../../vaccines/providers/vaccine_providers.dart';
import '../../vaccines/widgets/vaccine_card.dart';
import '../../../shared/widgets/page_header_with_filter.dart';
import '../../../core/theme/app_typography.dart';

/// Vaccinations tab - vaccine calendar with child selector.
class VaccinationsTab extends ConsumerStatefulWidget {
  const VaccinationsTab({super.key});

  @override
  ConsumerState<VaccinationsTab> createState() => _VaccinationsTabState();
}

class _VaccinationsTabState extends ConsumerState<VaccinationsTab> {
  Child? _selectedChild;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final textColor = isDark ? Colors.white : AppColors.onSurfaceLight;
    final bgColor = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;
    final secondaryText = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    final childrenAsync = ref.watch(childrenProvider);
    ref.watch(vaccineSchedulerProvider); // Schedule notifications

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: childrenAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _buildErrorState(l10n, textColor, secondaryText),
          data: (children) {
            if (children.isEmpty) {
              return _buildNoChildrenState(l10n, primary, textColor, secondaryText);
            }

            // Auto-select first child if none selected
            _selectedChild ??= children.first;

            // Make sure selected child still exists
            if (!children.any((c) => c.id == _selectedChild?.id)) {
              _selectedChild = children.first;
            }

            return Column(
              children: [
                PageHeaderWithFilter(
                  title: l10n.homeVaccineCalendarTitle,
                  subtitle: l10n.homeVaccineCalendarSubtitle,
                  icon: Icons.vaccines_rounded,
                  childrenList: children,
                  selectedChildId: _selectedChild?.id,
                  allowAll: false,
                  onChildSelected: (id) {
                    if (id != null) {
                      setState(() {
                        _selectedChild = children.firstWhere(
                          (c) => c.id == id,
                          orElse: () => children.first,
                        );
                      });
                    }
                  },
                ),

                // Vaccine list
                Expanded(
                  child: _buildVaccineList(l10n, _selectedChild!, isDark, textColor),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildVaccineList(
    AppLocalizations l10n,
    Child child,
    bool isDark,
    Color textColor,
  ) {
    final vaccinesAsync = ref.watch(
      vaccineGroupsWithStatusProvider((
        childId: child.id,
        birthDate: child.birthDate,
      )),
    );

    return vaccinesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text(
          l10n.healthErrorWithDetail('$error'),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.error),
        ),
      ),
      data: (vaccineGroups) {
        return ListView.builder(
          padding: const EdgeInsetsDirectional.fromSTEB(
            AppSpacing.screenPaddingH,
            AppSpacing.sm,
            AppSpacing.screenPaddingH,
            100, // Bottom padding for nav bar
          ),
          itemCount: vaccineGroups.length,
          itemBuilder: (context, index) {
            final group = vaccineGroups[index];
            return VaccineCard(
              childId: child.id,
              vaccineGroup: group,
              onMarkComplete: () => _showMarkCompleteDialog(child, group),
              onMarkIncomplete: () => _showMarkIncompleteDialog(child, group),
            );
          },
        );
      },
    );
  }

  void _showMarkCompleteDialog(Child child, VaccineGroupWithStatus group) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final textColor = isDark ? Colors.white : AppColors.onSurfaceLight;

    DateTime selectedDate = DateTime.now();
    final notesController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsetsDirectional.fromSTEB(
            AppSpacing.screenPaddingH,
            AppSpacing.lg,
            AppSpacing.screenPaddingH,
            MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                l10n.homeVaccineMarkComplete,
                style: AppTypography.fromContext(context, fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${group.group.ageFr} - ${group.group.vaccineCodesLabel}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: textColor.withValues(alpha: 0.7)),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Date picker
              Text(
                l10n.homeVaccineDateLabel,
                style: AppTypography.fromContext(context, fontSize: 14, fontWeight: FontWeight.w500, color: textColor),
              ),
              const SizedBox(height: AppSpacing.xs),
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: child.birthDate,
                    lastDate: DateTime.now(),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: Theme.of(context).colorScheme.copyWith(
                            primary: isDark
                                ? AppColors.primaryDark
                                : AppColors.primaryLight,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    setModalState(() => selectedDate = picked);
                  }
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
                        color: textColor.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        DateFormat('d MMMM yyyy', 'fr').format(selectedDate),
                        style: AppTypography.fromContext(context, fontSize: 15, color: textColor),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Notes field
              Text(
                l10n.healthNotesOptional,
                style: AppTypography.fromContext(context, fontSize: 14, fontWeight: FontWeight.w500, color: textColor),
              ),
              const SizedBox(height: AppSpacing.xs),
              TextField(
                controller: notesController,
                maxLines: 2,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: textColor),
                decoration: InputDecoration(
                  hintText: l10n.homeVaccineNotesHint,
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
              const SizedBox(height: AppSpacing.lg),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        l10n.healthCancel,
                        style: AppTypography.fromContext(context, fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          ref
                              .read(vaccineActionsProvider.notifier)
                              .markCompleted(
                                childId: child.id,
                                vaccineGroupId: group.group.id,
                                completedAt: selectedDate,
                                notes: notesController.text.isNotEmpty
                                    ? notesController.text
                                    : null,
                              );
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                l10n.homeVaccineMarkedComplete,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          l10n.confirm,
                          style: AppTypography.fromContext(context, fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMarkIncompleteDialog(Child child, VaccineGroupWithStatus group) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.onSurfaceLight;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          l10n.homeVaccineCancelTitle,
          style: AppTypography.fromContext(context, fontSize: 14, fontWeight: FontWeight.bold, color: textColor),
        ),
        content: Text(
          l10n.homeVaccineCancelMessage(group.group.ageFr),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: textColor.withValues(alpha: 0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.homeVaccineNo,
              style: AppTypography.fromContext(context, fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(vaccineActionsProvider.notifier)
                  .markIncomplete(
                    childId: child.id,
                    vaccineGroupId: group.group.id,
                  );
              Navigator.pop(context);
            },
            child: Text(
              l10n.homeVaccineYesCancel,
              style: AppTypography.fromContext(context, fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoChildrenState(
    AppLocalizations l10n,
    Color primary,
    Color textColor,
    Color secondaryText,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.child_care_rounded, size: 50, color: primary),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              l10n.noChildrenTitle,
              style: AppTypography.fromContext(context, fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.homeVaccineNoChildrenHint,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: secondaryText),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(
    AppLocalizations l10n,
    Color textColor,
    Color secondaryText,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 60, color: AppColors.error),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.healthLoadingError,
              style: AppTypography.fromContext(context, fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.homeLoadDataError,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: secondaryText),
            ),
          ],
        ),
      ),
    );
  }
}
