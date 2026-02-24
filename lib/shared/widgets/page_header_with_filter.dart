import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../features/profile/models/profile_models.dart';

/// Unifie le titre de la page et le "baby selector" (compact)
/// Utilisé dans Timeline, Capsules, Health, Vaccinations, Memory Book.
class PageHeaderWithFilter extends StatelessWidget {
  const PageHeaderWithFilter({
    super.key,
    required this.title,
    this.subtitle,
    this.subtitleWidget,
    required this.icon,
    this.iconGradient,
    this.iconColor,
    this.showBackButton = false,
    this.trailing,
    required this.childrenList,
    required this.selectedChildId,
    required this.onChildSelected,
    this.allowAll = false,
  });

  /// Titre principal de la page
  final String title;

  /// Sous-titre text (utilisé si subtitleWidget est null)
  final String? subtitle;

  /// Widget custom pour le sous-titre (pour des affichages complexes, ex: "5 restantes")
  final Widget? subtitleWidget;

  /// Icône dans le conteneur carré 44x44
  final IconData icon;

  /// Optionnel: le dégradé de fond de l'icône (par défaut primaryGradient)
  final Gradient? iconGradient;

  /// Optionnel: la couleur unie de fond de l'icône si on ne veut pas de dégradé
  final Color? iconColor;

  /// Faut-il afficher le bouton de retour ?
  final bool showBackButton;

  /// Un widget optionnel placé tout à droite du titre (ex: le bouton "Capturer")
  final Widget? trailing;

  /// Liste des profils enfants existants
  final List<Child> childrenList;

  /// L'ID de l'enfant actuellement sélectionné (null = "Tous")
  final String? selectedChildId;

  /// L'action lors de la sélection
  final ValueChanged<String?> onChildSelected;

  /// Booléen: ajouter l'option "Tous" en première position ?
  final bool allowAll;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final textColor = isDark ? Colors.white : AppColors.onSurfaceLight;
    final secondaryText = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Titre Bar Harmonieuse
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPaddingH,
            AppSpacing.md,
            AppSpacing.screenPaddingH,
            AppSpacing.sm,
          ),
          child: Row(
            children: [
              if (showBackButton) ...[
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: primary,
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
              ],

              // Icône carrée (brand container)
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconGradient == null ? (iconColor ?? primary) : null,
                  gradient: iconColor == null
                      ? (iconGradient ?? AppColors.primaryGradient)
                      : null,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: AppSpacing.md),

              // Title & Subtitle block
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.outfit(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    if (subtitleWidget != null)
                      subtitleWidget!
                    else if (subtitle != null)
                      Text(
                        subtitle!,
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: secondaryText,
                        ),
                      ),
                  ],
                ),
              ),

              if (trailing != null) ...[
                const SizedBox(width: AppSpacing.md),
                trailing!,
              ],
            ],
          ),
        ),

        // 2. Baby Selector (Compact)
        if (childrenList.isNotEmpty && (childrenList.length > 1 || allowAll))
          Container(
            height: 42, // COMPACT HEIGHT (au lieu de 50 ou 64)
            margin: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPaddingH,
              vertical: 4,
            ),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: allowAll
                  ? childrenList.length + 1
                  : childrenList.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                // Bouton "Tous"
                if (allowAll && index == 0) {
                  return _buildPill(
                    context: context,
                    isSelected: selectedChildId == null,
                    label: 'Tous',
                    primary: primary,
                    textColor: textColor,
                    isDark: isDark,
                    onTap: () => onChildSelected(null),
                  );
                }

                // Bouton Enfant
                final childIndex = allowAll ? index - 1 : index;
                final child = childrenList[childIndex];
                final isSelected = selectedChildId == child.id;

                return _buildPill(
                  context: context,
                  isSelected: isSelected,
                  label: child.name,
                  primary: primary,
                  textColor: textColor,
                  isDark: isDark,
                  photoUrl: child.photoUrl,
                  onTap: () => onChildSelected(child.id),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildPill({
    required BuildContext context,
    required bool isSelected,
    required String label,
    required Color primary,
    required Color textColor,
    required bool isDark,
    String? photoUrl,
    required VoidCallback onTap,
  }) {
    final surface = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primary.withValues(alpha: 0.15) : surface,
          borderRadius: BorderRadius.circular(21),
          border: Border.all(
            color: isSelected ? primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Miniature optionnelle mais hyper compacte
            if (photoUrl != null && photoUrl.isNotEmpty) ...[
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: NetworkImage(photoUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 6),
            ] else if (label != 'Tous') ...[
              // Fallback initial
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? primary
                      : Colors.grey.withValues(alpha: 0.2),
                ),
                child: Center(
                  child: Text(
                    label.isNotEmpty ? label[0].toUpperCase() : '?',
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : textColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? primary : textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
