import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../capsules/models/capsule.dart';
import '../../capsules/providers/capsule_providers.dart';

/// Bottom sheet to pick an existing capsule to attach to an album event slot.
class CapsulePickerSheet extends ConsumerWidget {
  const CapsulePickerSheet({
    super.key,
    required this.childId,
    required this.onSelected,
  });

  final String childId;
  final ValueChanged<Capsule> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.surfaceDark : Colors.white;
    final textColor = isDark
        ? AppColors.onSurfaceDark
        : AppColors.onSurfaceLight;
    final secondaryColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    final capsulesAsync = ref.watch(capsulesByChildProvider(childId));

    final lang = Localizations.localeOf(context).languageCode;
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.dividerDark
                        : AppColors.dividerLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        lang == 'ar'
                            ? 'اختر كبسولة ذكريات'
                            : lang == 'en'
                                ? 'Choose a Capsule'
                                : 'Choisir une capsule',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close_rounded, color: secondaryColor),
                    ),
                  ],
                ),
              ),
              const Divider(height: 16),
              Expanded(
                child: capsulesAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(
                    child: Text(
                      lang == 'ar'
                          ? 'خطأ في التحميل'
                          : lang == 'en'
                              ? 'Loading error'
                              : 'Erreur de chargement',
                      style: GoogleFonts.outfit(color: secondaryColor),
                    ),
                  ),
                  data: (capsules) {
                    if (capsules.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          child: Text(
                            lang == 'ar'
                                ? 'لا توجد كبسولات لهذا الطفل.\nقومي بإنشاء كبسولة جديدة لهذه المناسبة.'
                                : lang == 'en'
                                    ? 'No capsules for this child.\nCreate a new one for this event.'
                                    : 'Aucune capsule pour cet enfant.\nCréez-en une nouvelle pour ce moment.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              color: secondaryColor,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    }
                    return GridView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            childAspectRatio: 1,
                          ),
                      itemCount: capsules.length,
                      itemBuilder: (context, index) {
                        final capsule = capsules[index];
                        return GestureDetector(
                          onTap: () {
                            onSelected(capsule);
                            Navigator.pop(context);
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              capsule.photoUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: isDark
                                    ? Colors.grey[800]
                                    : Colors.grey[200],
                                child: const Icon(
                                  Icons.broken_image_rounded,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
