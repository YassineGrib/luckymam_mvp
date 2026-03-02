import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../notifications/notifications_screen.dart';
import '../../profile/models/profile_models.dart';
import '../../profile/providers/profile_providers.dart';
import '../providers/home_providers.dart';
import '../../profile/profile_screen.dart';
import '../../../shared/widgets/app_logo.dart';

/// Personal greeting header with user context.
class PersonalHeader extends ConsumerWidget {
  const PersonalHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.onSurfaceLight;
    final secondaryColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    final profileAsync = ref.watch(profileProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: profileAsync.when(
        loading: () => _buildSkeleton(textColor),
        error: (_, __) =>
            _buildGreeting(context, ref, textColor, secondaryColor, null),
        data: (profile) =>
            _buildGreeting(context, ref, textColor, secondaryColor, profile),
      ),
    );
  }

  Widget _buildSkeleton(Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 180,
          height: 32,
          decoration: BoxDecoration(
            color: textColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 140,
          height: 20,
          decoration: BoxDecoration(
            color: textColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }

  Widget _buildGreeting(
    BuildContext context,
    WidgetRef ref,
    Color textColor,
    Color secondaryColor,
    UserProfile? profile,
  ) {
    final greeting = getTimeBasedGreeting();
    final name = profile?.displayName ?? 'Maman';
    final status = profile?.statusLabel ?? 'Bienvenue';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final cardColor = isDark ? AppColors.surfaceDark : Colors.white;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Background Pattern Overlay
            Positioned.fill(
              child: Opacity(
                opacity: isDark ? 0.15 : 0.25,
                child: Image.asset(
                  'assets/images/heroPatern.png',
                  fit: BoxFit.cover,
                  repeat: ImageRepeat.repeat,
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Left content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // LuckyMam logo + brand name
                        const LuckyMamLogo(size: 22, showText: true),
                        const SizedBox(height: 8),
                        // Greeting
                        Text(
                          '$greeting,',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            color: secondaryColor,
                          ),
                        ),
                        Text(
                          '$name! 👋',
                          style: GoogleFonts.outfit(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Profile Status
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ProfileScreen(),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (profile?.status == UserStatus.pregnant)
                                  const Icon(
                                    Icons.pregnant_woman_rounded,
                                    size: 14,
                                    color: Colors.pink,
                                  )
                                else
                                  const Icon(
                                    Icons.child_friendly_rounded,
                                    size: 14,
                                    color: Colors.green,
                                  ),
                                const SizedBox(width: 6),
                                Text(
                                  status,
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    color: textColor.withValues(alpha: 0.8),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  size: 14,
                                  color: secondaryColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Notification bell
                  _NotifBell(primary: primary),
                  const SizedBox(width: 8),

                  // Avatar circle
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ProfileScreen(),
                        ),
                      );
                    },
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: primary.withValues(alpha: 0.2),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: primary.withValues(alpha: 0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: profile?.photoUrl != null
                            ? Image.network(
                                profile!.photoUrl!,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                color: primary,
                                alignment: Alignment.center,
                                child: Text(
                                  name.isNotEmpty ? name[0].toUpperCase() : 'M',
                                  style: GoogleFonts.outfit(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Bell icon widget ─────────────────────────────────────────────────────────

class _NotifBell extends StatelessWidget {
  const _NotifBell({required this.primary});
  final Color primary;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const NotificationsScreen()));
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: primary.withValues(alpha: 0.1),
          border: Border.all(color: primary.withValues(alpha: 0.2), width: 1),
        ),
        child: Icon(Icons.notifications_outlined, color: primary, size: 22),
      ),
    );
  }
}
