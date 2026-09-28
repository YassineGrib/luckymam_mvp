import 'package:flutter/material.dart';
import '../../../core/extensions/l10n_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// Palette configuration for boutique profile section cards
class _SectionPalette {
  final LinearGradient gradient;
  final Color border;
  final Color shadow;
  final Color accent;
  final Color watermark;
  final Color badgeBg;
  final Color badgeBorder;

  const _SectionPalette({
    required this.gradient,
    required this.border,
    required this.shadow,
    required this.accent,
    required this.watermark,
    required this.badgeBg,
    required this.badgeBorder,
  });
}

_SectionPalette _resolveSectionPalette({
  required Color baseColor,
  required bool isDark,
}) {
  if (isDark) {
    // Dark mode: Deep atmospheric midnight surface tinted by baseColor
    return _SectionPalette(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.lerp(const Color(0xFF221C2C), baseColor, 0.14)!,
          Color.lerp(const Color(0xFF171320), baseColor, 0.07)!,
        ],
      ),
      border: Colors.white.withValues(alpha: 0.10),
      shadow: Colors.black.withValues(alpha: 0.35),
      accent: baseColor,
      watermark: Colors.white.withValues(alpha: 0.04),
      badgeBg: baseColor.withValues(alpha: 0.20),
      badgeBorder: baseColor.withValues(alpha: 0.35),
    );
  }

  final value = baseColor.toARGB32();

  // Blue / Sky (Personal Information)
  if (baseColor == Colors.blue ||
      value == Colors.blue.toARGB32() ||
      baseColor == Colors.lightBlue) {
    return _SectionPalette(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFF1F7FF), Color(0xFFE5F1FE)],
      ),
      border: const Color(0xFFD6E8FD),
      shadow: const Color(0xFF90BBEA).withValues(alpha: 0.22),
      accent: const Color(0xFF0284C7),
      watermark: const Color(0xFF0284C7).withValues(alpha: 0.09),
      badgeBg: Colors.white,
      badgeBorder: const Color(0xFFBAE6FD),
    );
  }

  // Pink / Rose (Status / Grossesse / Hope)
  if (baseColor == Colors.pink ||
      value == Colors.pink.toARGB32() ||
      baseColor == AppColors.magentaPink) {
    return _SectionPalette(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFF0F5), Color(0xFFFFE6EF)],
      ),
      border: const Color(0xFFFFD4E2),
      shadow: const Color(0xFFE898AF).withValues(alpha: 0.22),
      accent: const Color(0xFFE11D48),
      watermark: const Color(0xFFE11D48).withValues(alpha: 0.09),
      badgeBg: Colors.white,
      badgeBorder: const Color(0xFFFECDD3),
    );
  }

  // Orange / Amber (Children / Mes Enfants)
  if (baseColor == Colors.orange ||
      value == Colors.orange.toARGB32() ||
      baseColor == Colors.deepOrange) {
    return _SectionPalette(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFF7ED), Color(0xFFFFEDD5)],
      ),
      border: const Color(0xFFFFDFB5),
      shadow: const Color(0xFFE8B878).withValues(alpha: 0.22),
      accent: const Color(0xFFEA580C),
      watermark: const Color(0xFFEA580C).withValues(alpha: 0.09),
      badgeBg: Colors.white,
      badgeBorder: const Color(0xFFFED7AA),
    );
  }

  // Purple / Violet (Cycle / Grossesse / Subscription)
  if (baseColor == Colors.purple ||
      value == Colors.purple.toARGB32() ||
      baseColor == Colors.deepPurple) {
    return _SectionPalette(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFF7F1FD), Color(0xFFEDE4FA)],
      ),
      border: const Color(0xFFE2D2F7),
      shadow: const Color(0xFFB997E3).withValues(alpha: 0.22),
      accent: const Color(0xFF8B5CF6),
      watermark: const Color(0xFF8B5CF6).withValues(alpha: 0.09),
      badgeBg: Colors.white,
      badgeBorder: const Color(0xFFDDD6FE),
    );
  }

  // Red / Coral (Medical Info)
  if (baseColor == Colors.red || value == Colors.red.toARGB32()) {
    return _SectionPalette(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFF1F2), Color(0xFFFFE4E6)],
      ),
      border: const Color(0xFFFECDD3),
      shadow: const Color(0xFFE5989F).withValues(alpha: 0.22),
      accent: const Color(0xFFDC2626),
      watermark: const Color(0xFFDC2626).withValues(alpha: 0.09),
      badgeBg: Colors.white,
      badgeBorder: const Color(0xFFFECDD3),
    );
  }

  // Grey / Slate (Settings)
  if (baseColor == Colors.grey || value == Colors.grey.toARGB32()) {
    return _SectionPalette(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFF8FAFC), Color(0xFFEFF3F8)],
      ),
      border: const Color(0xFFE2E8F0),
      shadow: const Color(0xFF94A3B8).withValues(alpha: 0.16),
      accent: const Color(0xFF64748B),
      watermark: const Color(0xFF64748B).withValues(alpha: 0.08),
      badgeBg: Colors.white,
      badgeBorder: const Color(0xFFCBD5E1),
    );
  }

  // Generic / Custom Interpolated Fallback
  return _SectionPalette(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color.lerp(Colors.white, baseColor, 0.08)!,
        Color.lerp(Colors.white, baseColor, 0.16)!,
      ],
    ),
    border: Color.lerp(Colors.white, baseColor, 0.28)!,
    shadow: baseColor.withValues(alpha: 0.18),
    accent: baseColor,
    watermark: baseColor.withValues(alpha: 0.09),
    badgeBg: Colors.white,
    badgeBorder: Color.lerp(Colors.white, baseColor, 0.25)!,
  );
}

/// Expandable boutique profile section card with animated expansion,
/// soft pastel gradient surface, and floating corner watermark icon.
class ProfileSectionCard extends StatefulWidget {
  const ProfileSectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
    this.iconColor,
    this.initiallyExpanded = false,
    this.trailing,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;
  final Color? iconColor;
  final bool initiallyExpanded;
  final Widget? trailing;

  @override
  State<ProfileSectionCard> createState() => _ProfileSectionCardState();
}

class _ProfileSectionCardState extends State<ProfileSectionCard>
    with SingleTickerProviderStateMixin {
  late bool _isExpanded;
  late AnimationController _controller;
  late Animation<double> _iconRotation;
  late Animation<double> _heightFactor;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _iconRotation = Tween<double>(
      begin: 0,
      end: 0.5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _heightFactor = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    if (_isExpanded) _controller.value = 1.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark
        ? AppColors.primaryDark
        : AppColors.primaryLight;
    final textColor = isDark ? Colors.white : AppColors.onSurfaceLight;

    final palette = _resolveSectionPalette(
      baseColor: widget.iconColor ?? primaryColor,
      isDark: isDark,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        gradient: palette.gradient,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: palette.border,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: palette.shadow,
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Floating Bleeding Watermark Icon on the other side (start side)
            PositionedDirectional(
              bottom: -22,
              start: -18,
              child: IgnorePointer(
                child: Icon(
                  widget.icon,
                  size: 104,
                  color: palette.watermark,
                ),
              ),
            ),

            // Card Content: Header + Expandable Children
            Column(
              children: [
                // Header (Old small boxed icon removed, spacious title)
                InkWell(
                  onTap: _toggleExpansion,
                  borderRadius: BorderRadius.circular(24),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: textColor,
                                  letterSpacing: -0.2,
                                ),
                          ),
                        ),
                        if (widget.trailing != null) ...[
                          widget.trailing!,
                          const SizedBox(width: 8),
                        ],
                        // Circular subtle toggle chevron button
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.white.withValues(alpha: 0.70),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.10)
                                  : palette.border.withValues(alpha: 0.8),
                              width: 0.8,
                            ),
                          ),
                          child: Center(
                            child: RotationTransition(
                              turns: _iconRotation,
                              child: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: palette.accent.withValues(alpha: 0.85),
                                size: 19,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Expandable content
                ClipRect(
                  child: AnimatedBuilder(
                    animation: _heightFactor,
                    builder: (context, child) {
                      return Align(
                        alignment: Alignment.topCenter,
                        heightFactor: _heightFactor.value,
                        child: Opacity(
                          opacity: _heightFactor.value,
                          child: child,
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        16,
                        0,
                        16,
                        16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Divider(
                            color: palette.accent.withValues(
                              alpha: isDark ? 0.16 : 0.14,
                            ),
                            thickness: 1,
                            height: 1,
                          ),
                          const SizedBox(height: 12),
                          ...widget.children,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Single info row inside a profile section.
class ProfileInfoRow extends StatelessWidget {
  const ProfileInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.onEdit,
    this.valueColor,
  });

  final String label;
  final String value;
  final IconData? icon;
  final VoidCallback? onEdit;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.onSurfaceLight;
    final secondaryColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.white.withValues(alpha: 0.75),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.04),
                  width: 0.8,
                ),
              ),
              child: Center(
                child: Icon(icon, size: 16, color: secondaryColor),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: secondaryColor,
                        fontSize: 11.5,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTypography.fromContext(
                    context,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? textColor,
                  ),
                ),
              ],
            ),
          ),
          if (onEdit != null)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onEdit,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.white.withValues(alpha: 0.60),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.edit_rounded,
                      size: 15,
                      color: secondaryColor,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Child card for displaying children info.
class ChildCard extends StatelessWidget {
  const ChildCard({
    super.key,
    required this.name,
    required this.birthDate,
    required this.gender,
    this.photoUrl,
    this.onTap,
  });

  final String name;
  final String birthDate;
  final String gender;
  final String? photoUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.onSurfaceLight;
    final secondaryColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    final isGirl = gender.toLowerCase() == 'fille';
    final genderColor =
        isGirl ? const Color(0xFFEC4899) : const Color(0xFF0284C7);
    final cardBg =
        isDark ? const Color(0xFF221C2B) : Colors.white.withValues(alpha: 0.85);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : genderColor.withValues(alpha: 0.20),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: genderColor.withValues(alpha: isDark ? 0.12 : 0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: genderColor.withValues(alpha: 0.2),
              backgroundImage: photoUrl != null
                  ? NetworkImage(photoUrl!)
                  : null,
              child: photoUrl == null
                  ? Icon(
                      isGirl ? Icons.face_3_rounded : Icons.face_rounded,
                      color: genderColor,
                    )
                  : null,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTypography.fromContext(context, fontSize: 15, fontWeight: FontWeight.w600, color: textColor),
                  ),
                  Text(
                    birthDate,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: secondaryColor),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: genderColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                gender,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600, color: genderColor),
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded, color: secondaryColor, size: 20),
          ],
        ),
      ),
    );
  }
}

/// Cycle day indicator for menstrual tracking.
class CycleDayIndicator extends StatelessWidget {
  const CycleDayIndicator({
    super.key,
    required this.currentDay,
    required this.cycleLength,
    required this.phase,
    required this.phaseColor,
  });

  final int currentDay;
  final int cycleLength;
  final String phase;
  final Color phaseColor;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.onSurfaceLight;
    final progress = currentDay / cycleLength;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    phaseColor.withValues(alpha: 0.3),
                    phaseColor.withValues(alpha: 0.1),
                  ],
                ),
                border: Border.all(color: phaseColor, width: 3),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.cycleDayLabel,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(color: textColor.withValues(alpha: 0.7)),
                    ),
                    Text(
                      '$currentDay',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: phaseColor),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: phaseColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      phase,
                      style: AppTypography.fromContext(context, fontSize: 13, fontWeight: FontWeight.w600, color: phaseColor),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: phaseColor.withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation(phaseColor),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.profileCycleDays(cycleLength),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: textColor.withValues(alpha: 0.6)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
