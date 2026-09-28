import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/extensions/l10n_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../capsules/models/capsule.dart';
import '../../capsules/screens/capsule_detail_screen.dart';
import '../../capsules/screens/create_capsule_screen.dart';
import '../../profile/models/profile_models.dart';
import '../../profile/providers/profile_providers.dart';
import '../providers/home_providers.dart';

/// Redesigned horizontal gallery for recent capsules.
/// Uses boutique squircle cards, soft gradient scrims, emotion indicators,
/// and watermark icon accents consistent with the modern dashboard.
class RecentCapsules extends ConsumerWidget {
  const RecentCapsules({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.primaryDark : AppColors.primaryLight;

    final capsules = ref.watch(recentCapsulesProvider);
    final childrenAsync = ref.watch(childrenProvider);
    final children = childrenAsync.value ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 168,
          child: capsules.isEmpty
              ? _buildEmptyState(context, isDark, primary, l10n)
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: capsules.length + 1, // +1 for add button
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _buildAddButton(context, isDark, primary, l10n);
                    }
                    final capsule = capsules[index - 1];
                    final child = children.firstWhere(
                      (c) => c.id == capsule.childId,
                      orElse: () => children.isNotEmpty
                          ? children.first
                          : Child(
                              id: capsule.childId,
                              name: 'Bébé',
                              gender: ChildGender.boy,
                              birthDate: DateTime.now(),
                            ),
                    );
                    return _buildCapsuleCard(
                      context,
                      capsule,
                      child,
                      isDark,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    bool isDark,
    Color primary,
    AppLocalizations l10n,
  ) {
    final bg = isDark ? const Color(0xFF231D26) : const Color(0xFFFAF5FF);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFEEDEFF);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CreateCapsuleScreen()),
          );
        },
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderColor, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.25)
                    : const Color(0xFFECDDF8).withValues(alpha: 0.5),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                // Bleeding Watermark Icon
                Positioned(
                  bottom: -22,
                  right: -18,
                  child: IgnorePointer(
                    child: Icon(
                      Icons.photo_library_rounded,
                      size: 92,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.04)
                          : const Color(0xFF9C4146).withValues(alpha: 0.08),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: primary.withValues(alpha: 0.15),
                        ),
                        child: Icon(
                          Icons.add_a_photo_rounded,
                          size: 26,
                          color: primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.homeRecentCapsulesEmpty,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white : const Color(0xFF221A24),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.timeline_add,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: primary.withValues(alpha: 0.6),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCapsuleCard(
    BuildContext context,
    Capsule capsule,
    Child child,
    bool isDark,
  ) {
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.06);

    final formattedDate = capsule.capturedAt != null
        ? DateFormat('d MMM', Localizations.localeOf(context).languageCode).format(capsule.capturedAt!)
        : DateFormat('d MMM', Localizations.localeOf(context).languageCode).format(capsule.createdAt);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CapsuleDetailScreen(capsule: capsule),
          ),
        );
      },
      child: Container(
        width: 148,
        margin: const EdgeInsetsDirectional.only(end: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.08),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Photo or placeholder
              capsule.photoUrl.isNotEmpty
                  ? Image.network(
                      capsule.photoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _buildPlaceholder(isDark),
                    )
                  : _buildPlaceholder(isDark),

              // Gradient Scrim for contrast
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.4, 0.7, 1.0],
                    colors: [
                      Colors.black.withValues(alpha: 0.45),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.3),
                      Colors.black.withValues(alpha: 0.85),
                    ],
                  ),
                ),
              ),

              // Top Row: Child name + Emotion Badge
              Positioned(
                top: 10,
                left: 10,
                right: 10,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3.5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          child.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                          width: 0.8,
                        ),
                      ),
                      child: Icon(
                        capsule.emotion.icon,
                        size: 13,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom Overlay: Date & Audio Indicator
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          formattedDate,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: -0.1,
                          ),
                        ),
                      ),
                    ),
                    if (capsule.audioUrl != null)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.mic_rounded,
                          size: 11,
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(bool isDark) {
    return Container(
      color: isDark ? const Color(0xFF261D22) : const Color(0xFFF7EFF5),
      child: Center(
        child: Icon(
          Icons.photo_library_outlined,
          size: 32,
          color: isDark ? Colors.white24 : Colors.black26,
        ),
      ),
    );
  }

  Widget _buildAddButton(
    BuildContext context,
    bool isDark,
    Color primary,
    AppLocalizations l10n,
  ) {
    final bg = isDark ? const Color(0xFF231D26) : const Color(0xFFFAF5FF);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFEEDEFF);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const CreateCapsuleScreen()),
        );
      },
      child: Container(
        width: 135,
        margin: const EdgeInsetsDirectional.only(end: 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.25)
                  : const Color(0xFFECDDF8).withValues(alpha: 0.45),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Bleeding Camera Watermark
              Positioned(
                bottom: -22,
                right: -18,
                child: IgnorePointer(
                  child: Icon(
                    Icons.photo_camera_rounded,
                    size: 88,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.04)
                        : const Color(0xFF9C4146).withValues(alpha: 0.08),
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primary.withValues(alpha: 0.15),
                      ),
                      child: Icon(
                        Icons.add_rounded,
                        size: 26,
                        color: primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.timeline_add,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF221A24),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Souvenir',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white60 : Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

