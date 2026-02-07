import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../profile/models/profile_models.dart';
import '../../profile/providers/profile_providers.dart';
import '../../vaccines/providers/vaccine_providers.dart';
import '../../vaccines/widgets/vaccine_card.dart';

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

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: childrenAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _buildErrorState(textColor, secondaryText),
          data: (children) {
            if (children.isEmpty) {
              return _buildNoChildrenState(primary, textColor, secondaryText);
            }

            // Auto-select first child if none selected
            _selectedChild ??= children.first;

            // Make sure selected child still exists
            if (!children.any((c) => c.id == _selectedChild?.id)) {
              _selectedChild = children.first;
            }

            return Column(
              children: [
                // Header
                _buildHeader(primary, textColor, secondaryText),

                // Child selector
                if (children.length > 1)
                  _buildChildSelector(
                    children,
                    primary,
                    textColor,
                    secondaryText,
                  ),

                // Vaccine list
                Expanded(
                  child: _buildVaccineList(_selectedChild!, isDark, textColor),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(Color primary, Color textColor, Color secondaryText) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPaddingH,
        AppSpacing.md,
        AppSpacing.screenPaddingH,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.vaccines_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Calendrier Vaccinal',
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                Text(
                  'Programme National Algérien',
                  style: GoogleFonts.outfit(fontSize: 14, color: secondaryText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildSelector(
    List<Child> children,
    Color primary,
    Color textColor,
    Color secondaryText,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

    return Container(
      height: 70,
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPaddingH,
        vertical: AppSpacing.sm,
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: children.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final child = children[index];
          final isSelected = child.id == _selectedChild?.id;

          return GestureDetector(
            onTap: () => setState(() => _selectedChild = child),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: isSelected ? primary.withValues(alpha: 0.15) : surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? primary : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: isSelected
                        ? primary
                        : secondaryText.withValues(alpha: 0.2),
                    child: Text(
                      child.name.isNotEmpty ? child.name[0].toUpperCase() : '?',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : secondaryText,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        child.name,
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? primary : textColor,
                        ),
                      ),
                      Text(
                        child.ageString,
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: secondaryText,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVaccineList(Child child, bool isDark, Color textColor) {
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
          'Erreur: $error',
          style: GoogleFonts.outfit(color: AppColors.error),
        ),
      ),
      data: (vaccineGroups) {
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPaddingH,
            AppSpacing.sm,
            AppSpacing.screenPaddingH,
            100, // Bottom padding for nav bar
          ),
          itemCount: vaccineGroups.length,
          itemBuilder: (context, index) {
            final group = vaccineGroups[index];
            return VaccineCard(
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
          padding: EdgeInsets.fromLTRB(
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
                'Marquer comme fait',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${group.group.ageFr} - ${group.group.vaccineCodesLabel}',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: textColor.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Date picker
              Text(
                'Date de vaccination',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
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
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Notes field
              Text(
                'Notes (optionnel)',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              TextField(
                controller: notesController,
                maxLines: 2,
                style: GoogleFonts.outfit(color: textColor),
                decoration: InputDecoration(
                  hintText: 'Ex: Docteur Martin, clinique...',
                  hintStyle: GoogleFonts.outfit(
                    color: textColor.withValues(alpha: 0.4),
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
                        'Annuler',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
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
                                'Vaccin marqué comme fait ✓',
                                style: GoogleFonts.outfit(),
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
                          'Confirmer',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.onSurfaceLight;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Annuler le vaccin ?',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        content: Text(
          'Voulez-vous marquer "${group.group.ageFr}" comme non fait ?',
          style: GoogleFonts.outfit(color: textColor.withValues(alpha: 0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Non',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
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
              'Oui, annuler',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoChildrenState(
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
              'Aucun enfant enregistré',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Ajoutez un enfant dans votre profil pour voir son calendrier vaccinal.',
              style: GoogleFonts.outfit(fontSize: 14, color: secondaryText),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(Color textColor, Color secondaryText) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 60, color: AppColors.error),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Erreur de chargement',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Impossible de charger les données',
              style: GoogleFonts.outfit(fontSize: 14, color: secondaryText),
            ),
          ],
        ),
      ),
    );
  }
}
