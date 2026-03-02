import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/app_logo.dart';
import '../capsules/providers/capsule_providers.dart';
import '../capsules/screens/capsule_detail_screen.dart';
import '../capsules/screens/create_capsule_screen.dart';
import 'models/profile_models.dart';
import '../timeline/screens/timeline_screen.dart';
import '../vaccines/providers/vaccine_providers.dart';

/// Rich profile page for an individual child.
class ChildProfileScreen extends ConsumerWidget {
  const ChildProfileScreen({super.key, required this.child});

  final Child child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;
    final surface = isDark ? AppColors.surfaceDark : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.onSurfaceLight;
    final secondaryText = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final primary = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final isBoy = child.gender == ChildGender.boy;
    final genderColor = isBoy ? AppColors.smaltBlue : primary;

    final capsulesAsync = ref.watch(capsulesByChildProvider(child.id));
    final vaccinesAsync = ref.watch(
      vaccineGroupsWithStatusProvider((
        childId: child.id,
        birthDate: child.birthDate,
      )),
    );

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Hero Header ──────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: genderColor,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: _HeroHeader(child: child, genderColor: genderColor),
            ),
            actions: [
              IconButton(
                onPressed: () => _createCapsule(context),
                icon: const Icon(
                  Icons.add_a_photo_rounded,
                  color: Colors.white,
                ),
                tooltip: 'Nouvelle capsule',
              ),
            ],
          ),

          // ── Quick Stats ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPaddingH,
                AppSpacing.md,
                AppSpacing.screenPaddingH,
                0,
              ),
              child: Row(
                children: [
                  _StatCard(
                    icon: Icons.photo_library_rounded,
                    color: primary,
                    label: 'Capsules',
                    value:
                        capsulesAsync.whenOrNull(
                          data: (list) => '${list.length}',
                        ) ??
                        '—',
                    surface: surface,
                    textColor: textColor,
                    secondaryText: secondaryText,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _StatCard(
                    icon: Icons.vaccines_rounded,
                    color: AppColors.success,
                    label: 'Vaccins faits',
                    value:
                        vaccinesAsync.whenOrNull(
                          data: (list) =>
                              '${list.where((v) => v.isCompleted).length}/${list.length}',
                        ) ??
                        '—',
                    surface: surface,
                    textColor: textColor,
                    secondaryText: secondaryText,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _StatCard(
                    icon: Icons.cake_rounded,
                    color: AppColors.goldenrod,
                    label: 'Âge',
                    value: child.ageString,
                    surface: surface,
                    textColor: textColor,
                    secondaryText: secondaryText,
                  ),
                ],
              ),
            ),
          ),

          // ── CTA Buttons ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPaddingH,
                AppSpacing.md,
                AppSpacing.screenPaddingH,
                0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _CtaButton(
                      icon: Icons.timeline_rounded,
                      label: 'Timeline',
                      color: genderColor,
                      onTap: () => _openTimeline(context),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _CtaButton(
                      icon: Icons.add_a_photo_rounded,
                      label: 'Capsule',
                      color: primary,
                      onTap: () => _createCapsule(context),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Capsules Section ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPaddingH,
                AppSpacing.lg,
                AppSpacing.screenPaddingH,
                AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Icon(Icons.photo_library_rounded, size: 18, color: primary),
                  const SizedBox(width: 8),
                  Text(
                    'Mes Souvenirs',
                    style: GoogleFonts.outfit(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
          ),

          capsulesAsync.when(
            loading: () => SliverToBoxAdapter(child: _shimmerGrid(isDark)),
            error: (_, __) =>
                const SliverToBoxAdapter(child: SizedBox.shrink()),
            data: (capsules) {
              if (capsules.isEmpty) {
                return SliverToBoxAdapter(
                  child: _EmptyState(
                    icon: Icons.photo_camera_rounded,
                    label: 'Aucune capsule pour ${child.name}',
                    sub: 'Capturez un premier souvenir !',
                    color: primary,
                    onAction: () => _createCapsule(context),
                    actionLabel: 'Capturer',
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPaddingH,
                ),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 1,
                  ),
                  delegate: SliverChildBuilderDelegate((ctx, i) {
                    final cap = capsules[i];
                    return GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CapsuleDetailScreen(capsule: cap),
                        ),
                      ),
                      child: Hero(
                        tag: 'capsule_${cap.id}',
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(cap.photoUrl, fit: BoxFit.cover),
                              if (cap.category != null)
                                Positioned(
                                  bottom: 4,
                                  left: 4,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      cap.category!.emoji,
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                  ),
                                ),
                              if (cap.hasAudio)
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.mic_rounded,
                                      size: 10,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }, childCount: capsules.length),
                ),
              );
            },
          ),

          // ── Vaccines Section ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPaddingH,
                AppSpacing.lg,
                AppSpacing.screenPaddingH,
                AppSpacing.sm,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.vaccines_rounded,
                    size: 18,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Vaccinations',
                    style: GoogleFonts.outfit(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
          ),

          vaccinesAsync.when(
            loading: () =>
                const SliverToBoxAdapter(child: SizedBox(height: 60)),
            error: (_, __) =>
                const SliverToBoxAdapter(child: SizedBox.shrink()),
            data: (vaccines) {
              final done = vaccines.where((v) => v.isCompleted).toList();
              final pending = vaccines.where((v) => !v.isCompleted).toList();
              return SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPaddingH,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((ctx, i) {
                    final v = i < done.length
                        ? done[i]
                        : pending[i - done.length];
                    final isCompleted = v.isCompleted;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isCompleted
                              ? AppColors.success.withValues(alpha: 0.3)
                              : isDark
                              ? AppColors.dividerDark
                              : AppColors.dividerLight,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: isCompleted
                                  ? AppColors.success.withValues(alpha: 0.12)
                                  : secondaryText.withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isCompleted
                                  ? Icons.check_circle_rounded
                                  : Icons.radio_button_unchecked_rounded,
                              size: 18,
                              color: isCompleted
                                  ? AppColors.success
                                  : secondaryText,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  v.group.vaccineCodesLabel,
                                  style: GoogleFonts.outfit(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                  ),
                                ),
                                Text(
                                  v.group.ageFr,
                                  style: GoogleFonts.outfit(
                                    fontSize: 11,
                                    color: secondaryText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isCompleted && v.status?.completedAt != null)
                            Text(
                              DateFormat(
                                'dd/MM/yy',
                              ).format(v.status!.completedAt!),
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                color: AppColors.success,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    );
                  }, childCount: done.length + pending.length),
                ),
              );
            },
          ),

          const SliverPadding(padding: EdgeInsets.only(bottom: 120)),
        ],
      ),
    );
  }

  void _openTimeline(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const TimelineScreen()));
  }

  void _createCapsule(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const CreateCapsuleScreen()));
  }

  Widget _shimmerGrid(bool isDark) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPaddingH,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.white10 : Colors.black12,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

// ─── Hero Header ─────────────────────────────────────────────────────────────

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.child, required this.genderColor});

  final Child child;
  final Color genderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [genderColor, genderColor.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: Opacity(
              opacity: 0.07,
              child: Image.asset(
                'assets/images/heroPatern.png',
                fit: BoxFit.cover,
                repeat: ImageRepeat.repeat,
              ),
            ),
          ),
          // LuckyMam watermark
          Positioned(
            top: 16,
            right: 16,
            child: Opacity(
              opacity: 0.25,
              child: const LuckyMamLogo(size: 24, color: Colors.white),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 80, 24, 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Avatar
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white38, width: 2),
                    color: Colors.white24,
                    image: child.photoUrl != null
                        ? DecorationImage(
                            image: NetworkImage(child.photoUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: child.photoUrl == null
                      ? Center(
                          child: Text(
                            child.name.isNotEmpty
                                ? child.name[0].toUpperCase()
                                : '?',
                            style: GoogleFonts.outfit(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                // Name & info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        child.name,
                        style: GoogleFonts.outfit(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${child.genderLabel} · ${child.ageString}',
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat(
                              'd MMM yyyy',
                              'fr_FR',
                            ).format(child.birthDate),
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Stat Card ────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.surface,
    required this.textColor,
    required this.secondaryText,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final Color surface;
  final Color textColor;
  final Color secondaryText;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.outfit(fontSize: 10, color: secondaryText),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── CTA Button ───────────────────────────────────────────────────────────────

class _CtaButton extends StatelessWidget {
  const _CtaButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withValues(alpha: 0.75)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.label,
    required this.sub,
    required this.color,
    required this.onAction,
    required this.actionLabel,
  });

  final IconData icon;
  final String label;
  final String sub;
  final Color color;
  final VoidCallback onAction;
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Icon(icon, size: 48, color: color.withValues(alpha: 0.4)),
          const SizedBox(height: AppSpacing.sm),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            sub,
            style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          GestureDetector(
            onTap: onAction,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                actionLabel,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
