import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/extensions/l10n_extension.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../l10n/app_localizations.dart';
import '../../profile/models/profile_models.dart';
import '../models/growth_entry.dart';
import '../providers/health_providers.dart';
import '../widgets/growth_chart_widget.dart';
import '../widgets/growth_entry_card.dart';
import '../../../core/theme/app_typography.dart';

String _healthDateLocale(String languageCode) =>
    languageCode == 'fr' ? 'fr_FR' : languageCode;

/// Growth chart screen — log weight/height and view against WHO p50 reference.
class GrowthScreen extends ConsumerStatefulWidget {
  const GrowthScreen({super.key, required this.child});
  final Child child;

  @override
  ConsumerState<GrowthScreen> createState() => _GrowthScreenState();
}

class _GrowthScreenState extends ConsumerState<GrowthScreen> {
  bool _analyticsLogged = false;

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

    final entriesAsync = ref.watch(growthEntriesProvider(widget.child.id));

    return Scaffold(
      backgroundColor: bgColor,
      body: entriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            l10n.healthErrorWithDetail('$e'),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.error),
          ),
        ),
        data: (entries) {
          if (!_analyticsLogged) {
            _analyticsLogged = true;
            AnalyticsService().logEvent('weight_chart_viewed', parameters: {
              'child_id': widget.child.id,
              'entry_count': entries.length,
            });
          }
          return CustomScrollView(
          slivers: [
            // Chart section
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPaddingH,
                  AppSpacing.md,
                  AppSpacing.screenPaddingH,
                  0,
                ),
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.surfaceDark
                      : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark
                        ? AppColors.dividerDark
                        : AppColors.dividerLight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.show_chart_rounded,
                          color: primary,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          l10n.healthWeightChartTitle,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, color: textColor),
                        ),
                        const Spacer(),
                        // WHO reference legend
                        Row(
                          children: [
                            Container(
                              width: 18,
                              height: 2,
                              color: AppColors.smaltBlue.withValues(alpha: 0.5),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              l10n.healthWhoP50,
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: secondary),
                            ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        Row(
                          children: [
                            Container(width: 18, height: 2, color: primary),
                            const SizedBox(width: 4),
                            Text(
                              widget.child.name,
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: secondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SizedBox(
                      height: 220,
                      child: GrowthChartWidget(
                        entries: entries,
                        childBirthDate: widget.child.birthDate,
                        isGirl: widget.child.gender == ChildGender.girl,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Section header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPaddingH,
                  AppSpacing.lg,
                  AppSpacing.screenPaddingH,
                  AppSpacing.sm,
                ),
                child: Text(
                  l10n.healthMeasurementHistory,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: textColor),
                ),
              ),
            ),

            // Entries list
            if (entries.isEmpty)
              SliverToBoxAdapter(child: _buildEmpty(primary, secondary, l10n))
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPaddingH,
                  0,
                  AppSpacing.screenPaddingH,
                  100,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => GrowthEntryCard(
                      entry: entries[i],
                      onDelete: () => _confirmDelete(entries[i]),
                    ),
                    childCount: entries.length,
                  ),
                ),
              ),
          ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          l10n.healthMeasurementFab,
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
        children: [
          const SizedBox(height: AppSpacing.lg),
          Icon(
            Icons.monitor_weight_outlined,
            size: 64,
            color: primary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.healthNoMeasurementsTitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: secondary),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.healthNoMeasurementsHint,
            style: AppTypography.fromContext(context, fontSize: 13, color: secondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );

  void _confirmDelete(GrowthEntry entry) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.onSurfaceLight;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          l10n.healthDeleteMeasurementTitle,
          style: AppTypography.fromContext(context, fontSize: 14, fontWeight: FontWeight.bold, color: textColor),
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
                  .read(growthActionsProvider.notifier)
                  .deleteEntry(childId: widget.child.id, entryId: entry.id);
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
    final weightCtrl = TextEditingController();
    final heightCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
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
                l10n.healthNewMeasurement,
                style: AppTypography.fromContext(context, fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: AppSpacing.md),

              // Date row
              GestureDetector(
                onTap: () async {
                  final p = await showDatePicker(
                    context: ctx,
                    initialDate: selectedDate,
                    firstDate: widget.child.birthDate,
                    lastDate: DateTime.now(),
                  );
                  if (p != null) setModal(() => selectedDate = p);
                },
                child: _InputTile(
                  icon: Icons.calendar_today_rounded,
                  label: DateFormat('d MMMM yyyy', dateLocale).format(
                    selectedDate,
                  ),
                  primary: primary,
                  textColor: textColor,
                  isDark: isDark,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // Weight + height row
              Row(
                children: [
                  Expanded(
                    child: _NumberField(
                      controller: weightCtrl,
                      label: l10n.healthWeightKg,
                      hint: '7.5',
                      isDark: isDark,
                      textColor: textColor,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _NumberField(
                      controller: heightCtrl,
                      label: l10n.healthHeightCm,
                      hint: '68.0',
                      isDark: isDark,
                      textColor: textColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),

              // Notes
              TextField(
                controller: notesCtrl,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: textColor),
                decoration: InputDecoration(
                  hintText: l10n.healthNotesOptional,
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
                      final w = double.tryParse(
                        weightCtrl.text.replaceAll(',', '.'),
                      );
                      final h = double.tryParse(
                        heightCtrl.text.replaceAll(',', '.'),
                      );
                      if (w == null && h == null) return;
                      Navigator.pop(ctx);
                      await ref
                          .read(growthActionsProvider.notifier)
                          .addEntry(
                            childId: widget.child.id,
                            date: selectedDate,
                            weightKg: w,
                            heightCm: h,
                            notes: notesCtrl.text.isNotEmpty
                                ? notesCtrl.text
                                : null,
                          );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              l10n.healthMeasurementSaved,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
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
    );
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

class _InputTile extends StatelessWidget {
  const _InputTile({
    required this.icon,
    required this.label,
    required this.primary,
    required this.textColor,
    required this.isDark,
  });
  final IconData icon;
  final String label;
  final Color primary;
  final Color textColor;
  final bool isDark;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppSpacing.md),
    decoration: BoxDecoration(
      color: isDark
          ? AppColors.inputBackgroundDark
          : AppColors.inputBackgroundLight,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: isDark ? AppColors.inputBorderDark : AppColors.inputBorderLight,
      ),
    ),
    child: Row(
      children: [
        Icon(icon, size: 20, color: primary),
        const SizedBox(width: 8),
        Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: textColor)),
      ],
    ),
  );
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.isDark,
    required this.textColor,
  });
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool isDark;
  final Color textColor;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: textColor),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: textColor.withValues(alpha: 0.6)),
      hintText: hint,
      hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: textColor.withValues(alpha: 0.3)),
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
  );
}
