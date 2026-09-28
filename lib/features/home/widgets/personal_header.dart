import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/extensions/l10n_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../notifications/notifications_screen.dart';
import '../../profile/models/profile_models.dart';
import '../../profile/profile_screen.dart';
import '../../profile/providers/profile_providers.dart';
import '../providers/home_providers.dart';

/// Redesigned airy modern top header bar for the Home Dashboard.
/// Directly mirrors the clean, non-boxed, agency-grade header style
/// from flagship mobile inspirations (Avatar with ring + Greeting + Notification Bell).
class PersonalHeader extends ConsumerWidget {
  const PersonalHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF161618);
    final secondaryColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final primary = isDark ? AppColors.primaryDark : AppColors.primaryLight;

    final profileAsync = ref.watch(profileProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: profileAsync.when(
        loading: () => _buildSkeleton(isDark),
        error: (_, _) => _buildBar(context, ref, textColor, secondaryColor, primary, null),
        data: (profile) => _buildBar(context, ref, textColor, secondaryColor, primary, profile),
      ),
    );
  }

  Widget _buildSkeleton(bool isDark) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08),
          ),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 130,
              height: 18,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: 90,
              height: 13,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBar(
    BuildContext context,
    WidgetRef ref,
    Color textColor,
    Color secondaryColor,
    Color primary,
    UserProfile? profile,
  ) {
    final l10n = context.l10n;
    final greeting = getTimeBasedGreeting(l10n);
    final name = profile?.displayName ?? l10n.defaultMotherName;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final locale = Localizations.localeOf(context).toString();
    final todayFormatted = DateFormat('d MMM', locale).format(DateTime.now());

    final statusLabel = _statusLabel(l10n, profile);

    return Row(
      children: [
        // ─── Circular User Avatar ────────────────────────────────────
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
          },
          child: Stack(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: primary.withValues(alpha: 0.35),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primary.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: profile?.photoUrl != null
                      ? Image.network(
                          profile!.photoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => _fallbackAvatar(name, primary),
                        )
                      : _fallbackAvatar(name, primary),
                ),
              ),
              // Active status dot
              Positioned(
                bottom: 1,
                right: 1,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2ECC71),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? const Color(0xFF161618) : Colors.white,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 14),

        // ─── Greeting & Date Subtitle ────────────────────────────────
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$greeting, $name 👋',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 3),
              Row(
                children: [
                  Text(
                    'Aujourd\'hui, $todayFormatted',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: secondaryColor,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 3,
                    height: 3,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: secondaryColor.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      statusLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(width: 10),

        // ─── Circular Notification Button ────────────────────────────
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            );
          },
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.white.withValues(alpha: 0.85),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.06),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.notifications_none_rounded,
                  color: isDark ? Colors.white : const Color(0xFF161618),
                  size: 21,
                ),
                // Glowing orange/coral unread indicator dot
                Positioned(
                  top: 9,
                  right: 10,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF5252),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _fallbackAvatar(String name, Color primary) {
    return Container(
      color: primary,
      alignment: Alignment.center,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'M',
        style: const TextStyle(
          fontWeight: FontWeight.w800,
          color: Colors.white,
          fontSize: 18,
        ),
      ),
    );
  }

  String _statusLabel(AppLocalizations l10n, UserProfile? profile) {
    if (profile == null) return l10n.statusWelcome;
    switch (profile.status) {
      case UserStatus.pregnant:
        return l10n.statusPregnant;
      case UserStatus.hope:
        return l10n.statusHope;
      case UserStatus.mom:
        return l10n.statusMom;
    }
  }
}
