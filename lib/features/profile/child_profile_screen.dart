import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/extensions/l10n_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/auth_logo_background.dart';
import '../capsules/models/capsule.dart';
import '../capsules/providers/capsule_providers.dart';
import '../capsules/screens/capsule_detail_screen.dart';
import '../capsules/screens/create_capsule_screen.dart';
import '../health/models/growth_entry.dart';
import '../health/providers/health_providers.dart';
import '../health/screens/appointments_screen.dart';
import '../health/screens/growth_screen.dart';
import '../timeline/screens/timeline_screen.dart';
import '../vaccines/providers/vaccine_providers.dart';
import '../vaccines/screens/vaccine_detail_screen.dart';
import 'edit_child_screen.dart';
import 'models/profile_models.dart';

/// Available tabs inside the full-page Child Profile experience.
enum _ChildProfileTab {
  memories,
  health,
  growth,
}

/// Redesigned Flagship Full-Page Child Profile Screen for LuckyMam.
/// Replaces the legacy SliverAppBar layout with a boutique "Baby Digital Passport":
/// - Full-screen immersive Bento design with gender-tinted ambient lighting
/// - Interactive Hero Identity Card (Avatar, exact age in days, zodiac sign, gender pill)
/// - 4 Interactive Bento Quick Metrics (Memories, Vaccines progress, Growth vitals, Milestones)
/// - 3 Deep Full-Page Segmented Tabs (Memories Mosaic, Health & Vaccines Timeline, Growth & Milestones)
/// - Integrated Edit Child Screen and quick memory capture workflows.
class ChildProfileScreen extends ConsumerStatefulWidget {
  const ChildProfileScreen({super.key, required this.child});

  final Child child;

  @override
  ConsumerState<ChildProfileScreen> createState() => _ChildProfileScreenState();
}

class _ChildProfileScreenState extends ConsumerState<ChildProfileScreen> {
  _ChildProfileTab _selectedTab = _ChildProfileTab.memories;
  String _memoryFilter = 'all'; // 'all', 'favorites', 'audio'

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lang = Localizations.localeOf(context).languageCode;
    final isRtl = context.isRtl;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Watch live child data so edits reflect instantly
    final allChildren = ref.watch(childrenProvider).valueOrNull ?? [];
    final currentChild = allChildren.firstWhere(
      (c) => c.id == widget.child.id,
      orElse: () => widget.child,
    );

    final themeColor = currentChild.themeColor;
    final accentSecondary = themeColor.withValues(alpha: 0.85);

    final bgColor = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final surfaceColor = isDark ? const Color(0xFF221A24) : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.onSurfaceLight;
    final secondaryText = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    // Live streams for child features
    final capsulesAsync = ref.watch(capsulesByChildProvider(currentChild.id));
    final vaccinesAsync = ref.watch(
      vaccineGroupsWithStatusProvider((
        childId: currentChild.id,
        birthDate: currentChild.birthDate,
      )),
    );
    final growthAsync = ref.watch(growthEntriesProvider(currentChild.id));

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // ── 1. Corner Brand Watermark Logo ──
          const AuthLogoBackground(
            lightOpacity: 0.07,
            darkOpacity: 0.12,
          ),

          // ── 2. Atmospheric Top Ambient Illumination ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 380,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      themeColor.withValues(alpha: isDark ? 0.20 : 0.10),
                      accentSecondary.withValues(alpha: isDark ? 0.10 : 0.04),
                      Colors.transparent,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // ── 3. Flagship Top Interactive Header ──
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPaddingH,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      // Frosted Squircle Back Button
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.white.withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white12
                                  : const Color(0xFFE8E0E4),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(
                                  alpha: isDark ? 0.25 : 0.04,
                                ),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            isRtl
                                ? Icons.arrow_forward_ios_rounded
                                : Icons.arrow_back_ios_new_rounded,
                            size: 16,
                            color: textColor,
                          ),
                        ),
                      ),

                      const SizedBox(width: 14),

                      // Screen Title
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lang == 'ar'
                                  ? 'ملف الطفل'
                                  : (lang == 'fr'
                                      ? 'Profil de Bébé'
                                      : 'Baby\'s Profile'),
                              style: AppTypography.fromContext(
                                context,
                                fontSize: 18.5,
                                fontWeight: FontWeight.w900,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              lang == 'ar'
                                  ? 'السجل الرقمي للصحة والذكريات'
                                  : (lang == 'fr'
                                      ? 'Carnet de santé & souvenirs'
                                      : 'Digital Health & Memories'),
                              style: AppTypography.fromContext(
                                context,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Edit Baby Action Button
                      GestureDetector(
                        onTap: () => _openEditChildScreen(context, currentChild),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.white.withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white12
                                  : const Color(0xFFE8E0E4),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(
                                  alpha: isDark ? 0.25 : 0.04,
                                ),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.edit_note_rounded,
                            size: 22,
                            color: textColor,
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Fast Memory Capture Button
                      GestureDetector(
                        onTap: () => _openCreateCapsule(context, currentChild),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [themeColor, accentSecondary],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: themeColor.withValues(alpha: 0.35),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.add_a_photo_rounded,
                            size: 19,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 4),

                // ── 4. Main Scrollable Full-Page Body ──
                Expanded(
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      // ── Hero "Baby Digital Passport" Card ──
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.screenPaddingH,
                            vertical: 8,
                          ),
                          child: _BabyPassportHeroCard(
                            child: currentChild,
                            themeColor: themeColor,
                            accentSecondary: accentSecondary,
                            isDark: isDark,
                            isRtl: isRtl,
                            lang: lang,
                            l10n: l10n,
                            onEditAvatar: () =>
                                _openEditChildScreen(context, currentChild),
                          ),
                        ),
                      ),

                      const SliverToBoxAdapter(child: SizedBox(height: 10)),

                      // ── 4 Interactive Bento Quick Metrics ──
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.screenPaddingH,
                          ),
                          child: _BentoQuickMetricsGrid(
                            child: currentChild,
                            themeColor: themeColor,
                            surfaceColor: surfaceColor,
                            textColor: textColor,
                            secondaryText: secondaryText,
                            isDark: isDark,
                            lang: lang,
                            l10n: l10n,
                            capsulesAsync: capsulesAsync,
                            vaccinesAsync: vaccinesAsync,
                            growthAsync: growthAsync,
                            onTabSelected: (tab) {
                              HapticFeedback.selectionClick();
                              setState(() => _selectedTab = tab);
                            },
                            onOpenGrowth: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    GrowthScreen(child: currentChild),
                              ),
                            ),
                            onOpenTimeline: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const TimelineScreen(),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SliverToBoxAdapter(child: SizedBox(height: 16)),

                      // ── Segmented Tab Selector ──
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.screenPaddingH,
                          ),
                          child: _SegmentedTabSelector(
                            selectedTab: _selectedTab,
                            themeColor: themeColor,
                            isDark: isDark,
                            lang: lang,
                            onTabChanged: (tab) {
                              HapticFeedback.selectionClick();
                              setState(() => _selectedTab = tab);
                            },
                          ),
                        ),
                      ),

                      const SliverToBoxAdapter(child: SizedBox(height: 14)),

                      // ── Tab Views (Full Depth Content) ──
                      if (_selectedTab == _ChildProfileTab.memories)
                        ..._buildMemoriesTabSlivers(
                          context,
                          currentChild,
                          capsulesAsync,
                          themeColor,
                          surfaceColor,
                          textColor,
                          secondaryText,
                          isDark,
                          lang,
                          l10n,
                        )
                      else if (_selectedTab == _ChildProfileTab.health)
                        ..._buildHealthTabSlivers(
                          context,
                          currentChild,
                          vaccinesAsync,
                          themeColor,
                          surfaceColor,
                          textColor,
                          secondaryText,
                          isDark,
                          lang,
                          l10n,
                        )
                      else
                        ..._buildGrowthTabSlivers(
                          context,
                          currentChild,
                          growthAsync,
                          themeColor,
                          surfaceColor,
                          textColor,
                          secondaryText,
                          isDark,
                          lang,
                          l10n,
                        ),

                      const SliverPadding(padding: EdgeInsets.only(bottom: 60)),
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

  // ═════════════════════════════════════════════════════════════════════════
  // Tab 1: Memories & Capsules Mosaic
  // ═════════════════════════════════════════════════════════════════════════

  List<Widget> _buildMemoriesTabSlivers(
    BuildContext context,
    Child child,
    AsyncValue<List<Capsule>> capsulesAsync,
    Color themeColor,
    Color surfaceColor,
    Color textColor,
    Color secondaryText,
    bool isDark,
    String lang,
    dynamic l10n,
  ) {
    return [
      // Filter Pills + Quick Add Trigger
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPaddingH,
            vertical: 4,
          ),
          child: Row(
            children: [
              _FilterChip(
                icon: Icons.grid_view_rounded,
                label: lang == 'ar'
                    ? 'الكل'
                    : (lang == 'fr' ? 'Tous' : 'All'),
                isSelected: _memoryFilter == 'all',
                themeColor: themeColor,
                isDark: isDark,
                onTap: () => setState(() => _memoryFilter = 'all'),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                icon: Icons.star_rounded,
                label: lang == 'ar'
                    ? 'المفضلة'
                    : (lang == 'fr' ? 'Favoris' : 'Favorites'),
                isSelected: _memoryFilter == 'favorites',
                themeColor: themeColor,
                isDark: isDark,
                onTap: () => setState(() => _memoryFilter = 'favorites'),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                icon: Icons.mic_rounded,
                label: lang == 'ar'
                    ? 'تسجيلات صوتية'
                    : (lang == 'fr' ? 'Audios' : 'Audio Notes'),
                isSelected: _memoryFilter == 'audio',
                themeColor: themeColor,
                isDark: isDark,
                onTap: () => setState(() => _memoryFilter = 'audio'),
              ),
            ],
          ),
        ),
      ),

      const SliverToBoxAdapter(child: SizedBox(height: 10)),

      // Memories Content
      capsulesAsync.when(
        loading: () => SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPaddingH,
            ),
            child: _shimmerGrid(isDark),
          ),
        ),
        error: (err, _) => SliverToBoxAdapter(
          child: Center(
            child: Text(
              lang == 'ar'
                  ? 'حدث خطأ في تحميل الذكريات'
                  : 'Failed to load memories',
              style: TextStyle(color: secondaryText),
            ),
          ),
        ),
        data: (allCapsules) {
          final capsules = allCapsules.where((c) {
            if (_memoryFilter == 'favorites') return c.isFavorite;
            if (_memoryFilter == 'audio') return c.hasAudio;
            return true;
          }).toList();

          if (capsules.isEmpty) {
            return SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPaddingH,
                  vertical: 20,
                ),
                child: _EmptyStateCard(
                  icon: Icons.photo_library_outlined,
                  title: lang == 'ar'
                      ? 'لا توجد كبسولات مسجلة بعد'
                      : (lang == 'fr'
                          ? 'Aucun souvenir enregistré'
                          : 'No memory capsules yet'),
                  subtitle: lang == 'ar'
                      ? 'خلدي أول ابتسامة، كلمة، أو خطوة لطفلكِ في كبسولة ذكريات دافئة.'
                      : (lang == 'fr'
                          ? 'Immortalisez son premier sourire ou premier pas.'
                          : 'Preserve baby\'s first smile, words, or steps forever.'),
                  actionLabel: lang == 'ar' ? 'تسجيل ذكرى جديدة' : 'Add First Memory',
                  themeColor: themeColor,
                  isDark: isDark,
                  onAction: () => _openCreateCapsule(context, child),
                ),
              ),
            );
          }

          return SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPaddingH,
            ),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final cap = capsules[index];
                  return _CapsuleGridCard(
                    capsule: cap,
                    isDark: isDark,
                    themeColor: themeColor,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CapsuleDetailScreen(capsule: cap),
                      ),
                    ),
                  );
                },
                childCount: capsules.length,
              ),
            ),
          );
        },
      ),
    ];
  }

  // ═════════════════════════════════════════════════════════════════════════
  // Tab 2: Health & Vaccines Timeline
  // ═════════════════════════════════════════════════════════════════════════

  List<Widget> _buildHealthTabSlivers(
    BuildContext context,
    Child child,
    AsyncValue<List<VaccineGroupWithStatus>> vaccinesAsync,
    Color themeColor,
    Color surfaceColor,
    Color textColor,
    Color secondaryText,
    bool isDark,
    String lang,
    dynamic l10n,
  ) {
    return [
      vaccinesAsync.when(
        loading: () => const SliverToBoxAdapter(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          ),
        ),
        error: (err, _) => SliverToBoxAdapter(
          child: Center(
            child: Text(
              lang == 'ar'
                  ? 'حدث خطأ في تحميل جدول التطعيمات'
                  : 'Failed to load vaccine schedule',
              style: TextStyle(color: secondaryText),
            ),
          ),
        ),
        data: (groups) {
          // Find next pending vaccine
          final pending = groups.where((g) => !g.isCompleted).toList();
          final nextGroup = pending.isNotEmpty ? pending.first : null;

          return SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPaddingH,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // 1. Next Upcoming Vaccine Alert Card
                if (nextGroup != null)
                  _NextVaccineHighlightCard(
                    groupWithStatus: nextGroup,
                    child: child,
                    isDark: isDark,
                    lang: lang,
                    onTap: () {
                      if (nextGroup.group.vaccines.isNotEmpty) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => VaccineDetailScreen(
                              vaccine: nextGroup.group.vaccines.first,
                              childId: child.id,
                              vaccineGroupId: nextGroup.group.id,
                            ),
                          ),
                        );
                      }
                    },
                  ),

                const SizedBox(height: 14),

                // 2. Doctor Appointments Shortcut Banner
                _DoctorAppointmentsBanner(
                  child: child,
                  isDark: isDark,
                  lang: lang,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AppointmentsScreen(child: child),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // 3. Section Header
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00C853).withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.vaccines_rounded,
                        color: Color(0xFF00C853),
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      lang == 'ar'
                          ? 'الجدول الوطني المعتمد للتلقيحات'
                          : 'Calendrier Vaccinal Officiel',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // 4. Vaccine Timeline Groups
                ...groups.map((g) {
                  return _VaccineGroupBentoItem(
                    groupWithStatus: g,
                    child: child,
                    isDark: isDark,
                    lang: lang,
                    onTap: () {
                      if (g.group.vaccines.isNotEmpty) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => VaccineDetailScreen(
                              vaccine: g.group.vaccines.first,
                              childId: child.id,
                              vaccineGroupId: g.group.id,
                            ),
                          ),
                        );
                      }
                    },
                  );
                }),
              ]),
            ),
          );
        },
      ),
    ];
  }

  // ═════════════════════════════════════════════════════════════════════════
  // Tab 3: Growth & Milestones
  // ═════════════════════════════════════════════════════════════════════════

  List<Widget> _buildGrowthTabSlivers(
    BuildContext context,
    Child child,
    AsyncValue<List<GrowthEntry>> growthAsync,
    Color themeColor,
    Color surfaceColor,
    Color textColor,
    Color secondaryText,
    bool isDark,
    String lang,
    dynamic l10n,
  ) {
    return [
      SliverPadding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPaddingH,
        ),
        sliver: SliverList(
          delegate: SliverChildListDelegate([
            // 1. Growth Vitals Bento Card
            growthAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => const SizedBox.shrink(),
              data: (entries) {
                final latest = entries.isNotEmpty ? entries.first : null;
                return _GrowthSummaryCard(
                  latest: latest,
                  totalEntries: entries.length,
                  child: child,
                  isDark: isDark,
                  lang: lang,
                  onOpenGrowthScreen: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => GrowthScreen(child: child),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // 2. Developmental Milestones Banner
            _MilestoneDevelopmentBanner(
              child: child,
              isDark: isDark,
              lang: lang,
              onOpenTimeline: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const TimelineScreen(),
                ),
              ),
            ),
          ]),
        ),
      ),
    ];
  }

  // ═════════════════════════════════════════════════════════════════════════
  // Dialog Actions
  // ═════════════════════════════════════════════════════════════════════════

  void _openCreateCapsule(BuildContext context, Child child) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreateCapsuleScreen(
          preselectedChildId: child.id,
        ),
      ),
    );
  }

  void _openEditChildScreen(BuildContext context, Child child) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EditChildScreen(child: child),
      ),
    );
  }

  Widget _shimmerGrid(bool isDark) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.85,
      ),
      itemCount: 4,
      itemBuilder: (_, _) => Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.white10 : Colors.black12,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

// ─── Hero "Baby Digital Passport" Card ───────────────────────────────

class _BabyPassportHeroCard extends StatelessWidget {
  const _BabyPassportHeroCard({
    required this.child,
    required this.themeColor,
    required this.accentSecondary,
    required this.isDark,
    required this.isRtl,
    required this.lang,
    required this.l10n,
    required this.onEditAvatar,
  });

  final Child child;
  final Color themeColor;
  final Color accentSecondary;
  final bool isDark;
  final bool isRtl;
  final String lang;
  final dynamic l10n;
  final VoidCallback onEditAvatar;

  @override
  Widget build(BuildContext context) {
    final daysAlive = DateTime.now().difference(child.birthDate).inDays;
    final detailedAge = _getDetailedAge(child.birthDate, lang);
    final zodiac = _getZodiac(child.birthDate, lang);
    final isBoy = child.gender == ChildGender.boy;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF2B1F2A), const Color(0xFF211622)]
              : [const Color(0xFFFFF0F4), const Color(0xFFFFF7FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: isDark
              ? themeColor.withValues(alpha: 0.35)
              : themeColor.withValues(alpha: 0.20),
          width: 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color: themeColor.withValues(alpha: isDark ? 0.20 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Stack(
          children: [
            // Decorative Crown/Star Watermark in Corner
            Positioned(
              right: isRtl ? null : -15,
              left: isRtl ? -15 : null,
              bottom: -15,
              child: IgnorePointer(
                child: Icon(
                  isBoy ? Icons.stars_rounded : Icons.cruelty_free_rounded,
                  size: 130,
                  color: themeColor.withValues(alpha: isDark ? 0.07 : 0.05),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Large Baby Avatar with Camera Badge
                  GestureDetector(
                    onTap: onEditAvatar,
                    child: Stack(
                      children: [
                        Container(
                          width: 82,
                          height: 82,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: themeColor, width: 2.5),
                            boxShadow: [
                              BoxShadow(
                                color: themeColor.withValues(alpha: 0.3),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: child.photoUrl != null &&
                                    child.photoUrl!.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: child.photoUrl!,
                                    fit: BoxFit.cover,
                                    placeholder: (_, _) => Shimmer.fromColors(
                                      baseColor: Colors.grey[300]!,
                                      highlightColor: Colors.grey[100]!,
                                      child: Container(color: Colors.white),
                                    ),
                                    errorWidget: (_, _, _) => _defaultAvatar(),
                                  )
                                : _defaultAvatar(),
                          ),
                        ),
                        // Mini Edit Badge
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: themeColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF221A24)
                                    : Colors.white,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 16),

                  // 2. Identity Info & Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name & Gender Pill Row
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                child.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF22161E),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: themeColor.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: themeColor.withValues(alpha: 0.3),
                                  width: 0.8,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isBoy ? Icons.male_rounded : Icons.female_rounded,
                                    size: 13,
                                    color: themeColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isBoy
                                        ? (lang == 'ar' ? 'أمير' : 'Garçon')
                                        : (lang == 'ar' ? 'أميرة' : 'Fille'),
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w800,
                                      color: themeColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 5),

                        // Exact Calculated Age
                        Row(
                          children: [
                            Icon(
                              Icons.cake_rounded,
                              size: 14,
                              color: themeColor,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              detailedAge,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: themeColor,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 4),

                        // Birth date & Zodiac Sign Pill
                        Row(
                          children: [
                            Text(
                              DateFormat('d MMMM yyyy', lang == 'ar' ? 'ar' : 'fr_FR')
                                  .format(child.birthDate),
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : const Color(0xFF725C68),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.auto_awesome_rounded, size: 11, color: themeColor),
                                const SizedBox(width: 3),
                                Text(
                                  zodiac,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : const Color(0xFF725C68),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Days of Joy Pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.06)
                                : Colors.white.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white12
                                  : const Color(0xFFE8DFE5),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.favorite_rounded,
                                size: 12,
                                color: AppColors.coral,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                lang == 'ar'
                                    ? '$daysAlive يوماً من الحب والرعاية'
                                    : '$daysAlive jours de bonheur infini',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? Colors.white70
                                      : const Color(0xFF422E39),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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

  Widget _defaultAvatar() {
    return Container(
      color: themeColor.withValues(alpha: 0.15),
      child: Center(
        child: child.name.isNotEmpty
            ? Text(
                child.name[0].toUpperCase(),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: themeColor,
                ),
              )
            : Icon(
                Icons.child_care_rounded,
                size: 38,
                color: themeColor,
              ),
      ),
    );
  }
}

// ─── 4 Interactive Bento Quick Metrics Grid ──────────────────────────

class _BentoQuickMetricsGrid extends StatelessWidget {
  const _BentoQuickMetricsGrid({
    required this.child,
    required this.themeColor,
    required this.surfaceColor,
    required this.textColor,
    required this.secondaryText,
    required this.isDark,
    required this.lang,
    required this.l10n,
    required this.capsulesAsync,
    required this.vaccinesAsync,
    required this.growthAsync,
    required this.onTabSelected,
    required this.onOpenGrowth,
    required this.onOpenTimeline,
  });

  final Child child;
  final Color themeColor;
  final Color surfaceColor;
  final Color textColor;
  final Color secondaryText;
  final bool isDark;
  final String lang;
  final dynamic l10n;
  final AsyncValue<List<Capsule>> capsulesAsync;
  final AsyncValue<List<VaccineGroupWithStatus>> vaccinesAsync;
  final AsyncValue<List<GrowthEntry>> growthAsync;
  final ValueChanged<_ChildProfileTab> onTabSelected;
  final VoidCallback onOpenGrowth;
  final VoidCallback onOpenTimeline;

  @override
  Widget build(BuildContext context) {
    // 1. Capsules count
    final capsulesCount = capsulesAsync.valueOrNull?.length ?? 0;

    // 2. Vaccines ratio & progress
    final totalVaccines = vaccinesAsync.valueOrNull?.length ?? 11;
    final doneVaccines =
        vaccinesAsync.valueOrNull?.where((v) => v.isCompleted).length ?? 0;
    final vaccineProgress =
        totalVaccines > 0 ? (doneVaccines / totalVaccines) : 0.0;

    // 3. Growth latest
    final growthEntries = growthAsync.valueOrNull ?? [];
    final latestGrowth = growthEntries.isNotEmpty ? growthEntries.first : null;
    final weightStr = latestGrowth?.weightKg != null
        ? '${latestGrowth!.weightKg!.toStringAsFixed(1)} kg'
        : '—';
    final heightStr = latestGrowth?.heightCm != null
        ? '${latestGrowth!.heightCm!.toStringAsFixed(0)} cm'
        : '—';

    return Row(
      children: [
        // Metric 1: Memories (Capsules)
        Expanded(
          child: _MetricSquircleCard(
            title: lang == 'ar' ? 'الذكريات' : 'Souvenirs',
            value: '$capsulesCount',
            subtitle: lang == 'ar' ? 'لحظة مسجلة' : 'moments',
            icon: Icons.photo_library_rounded,
            iconColor: const Color(0xFFFF5252),
            surfaceColor: surfaceColor,
            textColor: textColor,
            secondaryText: secondaryText,
            isDark: isDark,
            onTap: () => onTabSelected(_ChildProfileTab.memories),
          ),
        ),

        const SizedBox(width: 8),

        // Metric 2: Vaccines Progress
        Expanded(
          child: _MetricSquircleCard(
            title: lang == 'ar' ? 'التطعيمات' : 'Vaccins',
            value: '$doneVaccines/$totalVaccines',
            subtitle: '${(vaccineProgress * 100).toInt()}% مكتمل',
            icon: Icons.vaccines_rounded,
            iconColor: const Color(0xFF00C853),
            surfaceColor: surfaceColor,
            textColor: textColor,
            secondaryText: secondaryText,
            isDark: isDark,
            onTap: () => onTabSelected(_ChildProfileTab.health),
          ),
        ),

        const SizedBox(width: 8),

        // Metric 3: Growth Tracker
        Expanded(
          child: _MetricSquircleCard(
            title: lang == 'ar' ? 'الميزان' : 'Poids & Taille',
            value: weightStr,
            subtitle: heightStr,
            icon: Icons.monitor_weight_rounded,
            iconColor: const Color(0xFF00B0FF),
            surfaceColor: surfaceColor,
            textColor: textColor,
            secondaryText: secondaryText,
            isDark: isDark,
            onTap: onOpenGrowth,
          ),
        ),

        const SizedBox(width: 8),

        // Metric 4: Milestones
        Expanded(
          child: _MetricSquircleCard(
            title: lang == 'ar' ? 'التطور' : 'Jalons',
            value: lang == 'ar' ? 'المراحل' : 'Étapes',
            subtitle: lang == 'ar' ? 'خط الحياة' : 'Timeline',
            icon: Icons.auto_awesome_rounded,
            iconColor: const Color(0xFFFF9100),
            surfaceColor: surfaceColor,
            textColor: textColor,
            secondaryText: secondaryText,
            isDark: isDark,
            onTap: onOpenTimeline,
          ),
        ),
      ],
    );
  }
}

class _MetricSquircleCard extends StatelessWidget {
  const _MetricSquircleCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.surfaceColor,
    required this.textColor,
    required this.secondaryText,
    required this.isDark,
    required this.onTap,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color surfaceColor;
  final Color textColor;
  final Color secondaryText;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : const Color(0xFFEDE5EB),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 16),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: textColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Segmented Tab Selector ──────────────────────────────────────────

class _SegmentedTabSelector extends StatelessWidget {
  const _SegmentedTabSelector({
    required this.selectedTab,
    required this.themeColor,
    required this.isDark,
    required this.lang,
    required this.onTabChanged,
  });

  final _ChildProfileTab selectedTab;
  final Color themeColor;
  final bool isDark;
  final String lang;
  final ValueChanged<_ChildProfileTab> onTabChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : const Color(0xFFE8E0E4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabPill(
              title: lang == 'ar' ? 'الذكريات' : 'Souvenirs',
              icon: Icons.photo_library_outlined,
              isSelected: selectedTab == _ChildProfileTab.memories,
              themeColor: themeColor,
              onTap: () => onTabChanged(_ChildProfileTab.memories),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _TabPill(
              title: lang == 'ar' ? 'التطعيمات' : 'Vaccins',
              icon: Icons.vaccines_outlined,
              isSelected: selectedTab == _ChildProfileTab.health,
              themeColor: themeColor,
              onTap: () => onTabChanged(_ChildProfileTab.health),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _TabPill(
              title: lang == 'ar' ? 'النمو والتطور' : 'Croissance',
              icon: Icons.show_chart_rounded,
              isSelected: selectedTab == _ChildProfileTab.growth,
              themeColor: themeColor,
              onTap: () => onTabChanged(_ChildProfileTab.growth),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabPill extends StatelessWidget {
  const _TabPill({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.themeColor,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final bool isSelected;
  final Color themeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? themeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: themeColor.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? Colors.white : const Color(0xFF8E7E88),
            ),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? Colors.white : const Color(0xFF8E7E88),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Filter Chip ─────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    this.icon,
    required this.label,
    required this.isSelected,
    required this.themeColor,
    required this.isDark,
    required this.onTap,
  });

  final IconData? icon;
  final String label;
  final bool isSelected;
  final Color themeColor;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6.5),
        decoration: BoxDecoration(
          color: isSelected
              ? themeColor
              : (isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.white.withValues(alpha: 0.85)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? themeColor
                : (isDark ? Colors.white10 : const Color(0xFFE8E0E4)),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 13,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white70 : const Color(0xFF332029)),
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white70 : const Color(0xFF332029)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Capsule Grid Card ───────────────────────────────────────────────

class _CapsuleGridCard extends StatelessWidget {
  const _CapsuleGridCard({
    required this.capsule,
    required this.isDark,
    required this.themeColor,
    required this.onTap,
  });

  final Capsule capsule;
  final bool isDark;
  final Color themeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    final captureDate = capsule.capturedAt ?? capsule.createdAt;
    final formattedDate = DateFormat('d MMM yyyy').format(captureDate);
    final displayTitle = capsule.tags.isNotEmpty
        ? capsule.tags.first
        : (capsule.category?.getLabel(lang) ?? formattedDate);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Photo Image
              CachedNetworkImage(
                imageUrl: capsule.photoUrl,
                fit: BoxFit.cover,
                placeholder: (_, _) => Shimmer.fromColors(
                  baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                  highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
                  child: Container(color: Colors.grey),
                ),
                errorWidget: (_, _, _) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image_rounded),
                ),
              ),

              // Gradient Shade at Bottom
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.75),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.55, 1.0],
                  ),
                ),
              ),

              // Top Badges (Emotion & Audio)
              Positioned(
                top: 8,
                left: 8,
                right: 8,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2.5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        capsule.emotion.emoji,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),

                    if (capsule.hasAudio)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2.5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.mic_rounded,
                          size: 13,
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
              ),

              // Bottom Caption & Date
              Positioned(
                bottom: 8,
                left: 10,
                right: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      displayTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formattedDate,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.8),
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

// ─── Next Vaccine Highlight Card ─────────────────────────────────────

class _NextVaccineHighlightCard extends StatelessWidget {
  const _NextVaccineHighlightCard({
    required this.groupWithStatus,
    required this.child,
    required this.isDark,
    required this.lang,
    required this.onTap,
  });

  final VaccineGroupWithStatus groupWithStatus;
  final Child child;
  final bool isDark;
  final String lang;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const amber = Color(0xFFFF9100);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF2C2216), const Color(0xFF201810)]
              : [const Color(0xFFFFF8E1), const Color(0xFFFFFAF0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: amber.withValues(alpha: isDark ? 0.35 : 0.25),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: amber.withValues(alpha: isDark ? 0.18 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3.5,
                  ),
                  decoration: BoxDecoration(
                    color: amber.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.access_time_filled_rounded,
                        size: 13,
                        color: amber,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        lang == 'ar'
                            ? 'اللقاح القادم المستحق'
                            : 'Prochain Vaccin Dû',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: amber,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  groupWithStatus.group.ageFr,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white70 : const Color(0xFF523B22),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              groupWithStatus.group.vaccineCodesLabel,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : const Color(0xFF24160E),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              lang == 'ar'
                  ? 'موعد مستحق قريباً، احرصي على متابعة صحة طفلكِ والزيارة الطبية.'
                  : 'Prévoyez la consultation chez votre pédiatre ou PMI.',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : const Color(0xFF755B46),
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: onTap,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: amber,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    lang == 'ar'
                        ? 'عرض البطاقة الطبية للقاح ›'
                        : 'Voir la fiche médicale ›',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Doctor Appointments Banner ──────────────────────────────────────

class _DoctorAppointmentsBanner extends StatelessWidget {
  const _DoctorAppointmentsBanner({
    required this.child,
    required this.isDark,
    required this.lang,
    required this.onTap,
  });

  final Child child;
  final bool isDark;
  final String lang;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const cyan = Color(0xFF00B0FF);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E28) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: cyan.withValues(alpha: 0.25),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: cyan.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.medical_services_outlined,
                color: cyan,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lang == 'ar' ? 'مواعيد وزيارات الطبيب' : 'Rendez-vous médicaux',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppColors.onSurfaceLight,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    lang == 'ar'
                        ? 'تسجيل المواعيد القادمة وحفظ الوصفات الطبية'
                        : 'Enregistrer vos visites et ordonnances',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: cyan,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Vaccine Group Bento Item ────────────────────────────────────────

class _VaccineGroupBentoItem extends StatelessWidget {
  const _VaccineGroupBentoItem({
    required this.groupWithStatus,
    required this.child,
    required this.isDark,
    required this.lang,
    required this.onTap,
  });

  final VaccineGroupWithStatus groupWithStatus;
  final Child child;
  final bool isDark;
  final String lang;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isCompleted = groupWithStatus.isCompleted;
    final statusColor =
        isCompleted ? const Color(0xFF00C853) : const Color(0xFF00B0FF);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF221A24) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isCompleted
                ? const Color(0xFF00C853).withValues(alpha: 0.3)
                : (isDark ? Colors.white10 : const Color(0xFFEDE5EB)),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Status Icon Container
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCompleted
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                size: 20,
                color: statusColor,
              ),
            ),

            const SizedBox(width: 12),

            // Vaccine Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    groupWithStatus.group.vaccineCodesLabel,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppColors.onSurfaceLight,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    groupWithStatus.group.ageFr,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),

            // Date / Action Tag
            if (isCompleted && groupWithStatus.status?.completedAt != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF00C853).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  DateFormat('dd/MM/yyyy')
                      .format(groupWithStatus.status!.completedAt!),
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF00C853),
                  ),
                ),
              )
            else
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 13,
                color: Colors.grey,
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Growth Summary Bento Card ───────────────────────────────────────

class _GrowthSummaryCard extends StatelessWidget {
  const _GrowthSummaryCard({
    required this.latest,
    required this.totalEntries,
    required this.child,
    required this.isDark,
    required this.lang,
    required this.onOpenGrowthScreen,
  });

  final GrowthEntry? latest;
  final int totalEntries;
  final Child child;
  final bool isDark;
  final String lang;
  final VoidCallback onOpenGrowthScreen;

  @override
  Widget build(BuildContext context) {
    const cyan = Color(0xFF00B0FF);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF221A24) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? Colors.white10 : const Color(0xFFEDE5EB),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: cyan.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.straighten_rounded,
                  color: cyan,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lang == 'ar'
                          ? 'آخر القياسات المسجلة'
                          : 'Dernières mesures de croissance',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : AppColors.onSurfaceLight,
                      ),
                    ),
                    Text(
                      lang == 'ar'
                          ? '$totalEntries قياسات مسجلة في السجل'
                          : '$totalEntries mesures enregistrées',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Two Vitals Blocks
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : const Color(0xFFF7F5F7),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      Text(
                        lang == 'ar' ? 'الوزن' : 'Poids',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        latest?.weightKg != null
                            ? '${latest!.weightKg!.toStringAsFixed(1)} kg'
                            : '—',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: cyan,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : const Color(0xFFF7F5F7),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      Text(
                        lang == 'ar' ? 'الطول' : 'Taille',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        latest?.heightCm != null
                            ? '${latest!.heightCm!.toStringAsFixed(0)} cm'
                            : '—',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF7C4DFF),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // CTA to Growth Screen
          GestureDetector(
            onTap: onOpenGrowthScreen,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: cyan,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  lang == 'ar'
                      ? 'فتح منحنيات النمو التفاعلية (WHO) ›'
                      : 'Ouvrir les courbes OMS interactives ›',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
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

// ─── Developmental Milestones Banner ─────────────────────────────────

class _MilestoneDevelopmentBanner extends StatelessWidget {
  const _MilestoneDevelopmentBanner({
    required this.child,
    required this.isDark,
    required this.lang,
    required this.onOpenTimeline,
  });

  final Child child;
  final bool isDark;
  final String lang;
  final VoidCallback onOpenTimeline;

  @override
  Widget build(BuildContext context) {
    const violet = Color(0xFF7C4DFF);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF221A24) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? Colors.white10 : const Color(0xFFEDE5EB),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: violet.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.stars_rounded,
                  color: violet,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  lang == 'ar'
                      ? 'محطات النمو والتطور الحركي'
                      : 'Jalons de développement psychomoteur',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppColors.onSurfaceLight,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            lang == 'ar'
                ? 'تابعي تطور المهارات الحركية، اللغوية، والاجتماعية لطفلكِ شهر بشهر عبر خط الحياة التفاعلي.'
                : 'Suivez l\'éveil sensoriel, le langage et la motricité pas à pas dans le Livre de Vie.',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onOpenTimeline,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: violet,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  lang == 'ar'
                      ? 'استعراض خط التطور الكامل ›'
                      : 'Explorer le Livre de Vie ›',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
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

// ─── Empty State Card ────────────────────────────────────────────────

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.themeColor,
    required this.isDark,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final Color themeColor;
  final bool isDark;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF221A24) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? Colors.white10 : const Color(0xFFEDE5EB),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: themeColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 28, color: themeColor),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : AppColors.onSurfaceLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onAction,
            icon: const Icon(Icons.add_a_photo_rounded, size: 16),
            label: Text(actionLabel),
            style: ElevatedButton.styleFrom(
              backgroundColor: themeColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Helpers: Zodiac & Exact Age ─────────────────────────────────────

String _getZodiac(DateTime date, String lang) {
  final month = date.month;
  final day = date.day;

  if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) {
    return lang == 'ar' ? 'الحمل' : 'Bélier';
  } else if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) {
    return lang == 'ar' ? 'الثور' : 'Taureau';
  } else if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) {
    return lang == 'ar' ? 'الجوزاء' : 'Gémeaux';
  } else if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) {
    return lang == 'ar' ? 'السرطان' : 'Cancer';
  } else if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) {
    return lang == 'ar' ? 'الأسد' : 'Lion';
  } else if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) {
    return lang == 'ar' ? 'العذراء' : 'Vierge';
  } else if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) {
    return lang == 'ar' ? 'الميزان' : 'Balance';
  } else if ((month == 10 && day >= 23) || (month == 11 && day <= 21)) {
    return lang == 'ar' ? 'العقرب' : 'Scorpion';
  } else if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) {
    return lang == 'ar' ? 'القوس' : 'Sagittaire';
  } else if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) {
    return lang == 'ar' ? 'الجدي' : 'Capricorne';
  } else if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) {
    return lang == 'ar' ? 'الدلو' : 'Verseau';
  } else {
    return lang == 'ar' ? 'الحوت' : 'Poissons';
  }
}

String _getDetailedAge(DateTime birthDate, String lang) {
  final now = DateTime.now();
  int years = now.year - birthDate.year;
  int months = now.month - birthDate.month;
  int days = now.day - birthDate.day;

  if (days < 0) {
    months--;
    final prevMonth = DateTime(now.year, now.month, 0);
    days += prevMonth.day;
  }
  if (months < 0) {
    years--;
    months += 12;
  }

  if (years > 0) {
    if (months > 0) {
      return lang == 'ar'
          ? '$years سنة و $months أشهر'
          : (lang == 'fr'
              ? '$years an${years > 1 ? "s" : ""} et $months mois'
              : '$years yr${years > 1 ? "s" : ""} and $months mo');
    }
    return lang == 'ar'
        ? '$years سنة'
        : (lang == 'fr'
            ? '$years an${years > 1 ? "s" : ""}'
            : '$years yr${years > 1 ? "s" : ""}');
  }

  if (months > 0) {
    if (days > 0) {
      return lang == 'ar'
          ? '$months أشهر و $days يوماً'
          : (lang == 'fr'
              ? '$months mois et $days jours'
              : '$months mo and $days days');
    }
    return lang == 'ar'
        ? '$months أشهر'
        : (lang == 'fr' ? '$months mois' : '$months months');
  }

  return lang == 'ar'
      ? '$days يوماً'
      : (lang == 'fr' ? '$days jours' : '$days days');
}
