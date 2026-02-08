import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../profile/models/profile_models.dart';
import '../../profile/providers/profile_providers.dart';
import '../providers/home_providers.dart';
import '../../profile/profile_screen.dart';

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

    return Row(
      children: [
        // Left content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              Text(
                '$greeting, $name! 👋',
                style: GoogleFonts.outfit(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 4),
              // Profile Status
              GestureDetector(
                onTap: () {
                  // Navigate to profile
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                },
                child: Row(
                  children: [
                    if (profile?.status == UserStatus.pregnant)
                      Icon(
                        Icons.pregnant_woman_rounded,
                        size: 16,
                        color: Colors.pink,
                      )
                    else
                      Icon(
                        Icons.child_friendly_rounded,
                        size: 16,
                        color: Colors.green,
                      ),
                    const SizedBox(width: 6),
                    Text(
                      status,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: secondaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: secondaryColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Avatar circle
        GestureDetector(
          onTap: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
          },
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [primary, primary.withValues(alpha: 0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: profile?.photoUrl != null
                ? ClipOval(
                    child: Image.network(profile!.photoUrl!, fit: BoxFit.cover),
                  )
                : Center(
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : 'M',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
