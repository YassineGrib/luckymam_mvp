import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions/l10n_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/top_ambient_gradient.dart';
import '../../profile/providers/profile_providers.dart';
import '../data/album_templates_data.dart';
import '../models/album_template.dart';
import '../models/predefined_album.dart';
import '../providers/predefined_album_providers.dart';
import 'predefined_album_detail_screen.dart';

/// Redesigned flagship template picker screen for LuckyMam Memory Books.
/// Presents album templates as tactile 3D children's book covers in a 2-column grid,
/// featuring realistic hardcover spines, foil badges, and a boutique milestone preview sheet.
class AlbumTemplatePickerScreen extends ConsumerStatefulWidget {
  const AlbumTemplatePickerScreen({
    super.key,
    required this.childId,
    required this.childName,
  });

  final String childId;
  final String childName;

  @override
  ConsumerState<AlbumTemplatePickerScreen> createState() =>
      _AlbumTemplatePickerScreenState();
}

class _AlbumTemplatePickerScreenState
    extends ConsumerState<AlbumTemplatePickerScreen> {
  late String _selectedChildId;
  late String _selectedChildName;

  @override
  void initState() {
    super.initState();
    _selectedChildId = widget.childId;
    _selectedChildName = widget.childName;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lang = Localizations.localeOf(context).languageCode;
    final isRtl = context.isRtl;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;
    final textColor = isDark ? Colors.white : AppColors.onSurfaceLight;
    final secondaryText = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    final childrenAsync = ref.watch(childrenProvider);
    final children = childrenAsync.valueOrNull ?? [];

    // Ensure valid child selection from available children
    if ((_selectedChildId.isEmpty || _selectedChildName.isEmpty) &&
        children.isNotEmpty) {
      _selectedChildId = children.first.id;
      _selectedChildName = children.first.name;
    }

    final predefinedAlbumsAsync = ref.watch(
      predefinedAlbumsForChildProvider(_selectedChildId),
    );
    final childAlbums = predefinedAlbumsAsync.valueOrNull ?? [];

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // ── Atmospheric Ambient Lighting ──
          const TopAmbientGradient(height: 340),

          SafeArea(
            bottom: false,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                // 1. Luxury Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenPaddingH,
                      vertical: 8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Back Button & Screen Title Pill
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
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
                                      : Colors.white.withValues(alpha: 0.9),
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

                            // Screen Mode Badge Pill
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : Colors.white.withValues(alpha: 0.92),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFFFF8F00).withValues(alpha: 0.35),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFF8F00).withValues(
                                      alpha: isDark ? 0.15 : 0.06,
                                    ),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.auto_stories_rounded,
                                    size: 14,
                                    color: Color(0xFFFF8F00),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    lang == 'ar'
                                        ? 'قوالب الألبومات'
                                        : (lang == 'fr'
                                            ? 'Modèles d\'albums'
                                            : 'Photobook Templates'),
                                    style: AppTypography.fromContext(
                                      context,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF24160E),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Title & Emotional Description for the chosen child
                        Text(
                          l10n.albumPredefinedTitle,
                          style: AppTypography.fromContext(
                            context,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.albumChooseTemplateFor(_selectedChildName),
                          style: AppTypography.fromContext(
                            context,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                            color: secondaryText,
                            height: 1.35,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ── Child Selector Strip with Profile Photos ──
                        if (children.isNotEmpty) ...[
                          Row(
                            children: [
                              const Icon(
                                Icons.face_rounded,
                                size: 15,
                                color: AppColors.coral,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                lang == 'ar'
                                    ? 'اختاري طفلكِ للألبوم:'
                                    : (lang == 'fr'
                                        ? 'Choisir l\'enfant :'
                                        : 'Select child for photobook:'),
                                style: AppTypography.fromContext(
                                  context,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: secondaryText,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 48,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              itemCount: children.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(width: 10),
                              itemBuilder: (context, index) {
                                final child = children[index];
                                final isSelected =
                                    child.id == _selectedChildId;
                                return GestureDetector(
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    setState(() {
                                      _selectedChildId = child.id;
                                      _selectedChildName = child.name;
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration:
                                        const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.coral.withValues(
                                              alpha: isDark ? 0.22 : 0.12,
                                            )
                                          : (isDark
                                              ? Colors.white.withValues(
                                                  alpha: 0.05,
                                                )
                                              : Colors.white),
                                      borderRadius:
                                          BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.coral
                                            : (isDark
                                                ? Colors.white12
                                                : const Color(0xFFE5E7EB)),
                                        width: isSelected ? 1.8 : 1.0,
                                      ),
                                      boxShadow: [
                                        if (isSelected)
                                          BoxShadow(
                                            color: AppColors.coral
                                                .withValues(alpha: 0.22),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (child.photoUrl != null &&
                                            child.photoUrl!.isNotEmpty)
                                          CircleAvatar(
                                            radius: 16,
                                            backgroundImage:
                                                NetworkImage(child.photoUrl!),
                                          )
                                        else
                                          Container(
                                            width: 32,
                                            height: 32,
                                            decoration: BoxDecoration(
                                              gradient:
                                                  AppColors.primaryGradient,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.child_care_rounded,
                                              size: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                        const SizedBox(width: 8),
                                        Text(
                                          child.name,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: isSelected
                                                ? FontWeight.w800
                                                : FontWeight.w600,
                                            color: isSelected
                                                ? (isDark
                                                    ? Colors.white
                                                    : AppColors.coral)
                                                : textColor,
                                          ),
                                        ),
                                        if (isSelected) ...[
                                          const SizedBox(width: 6),
                                          const Icon(
                                            Icons.check_circle_rounded,
                                            size: 15,
                                            color: AppColors.coral,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: 14),
                ),

                // 2. 2-Column 3D Children's Book Covers Grid
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenPaddingH,
                    0,
                    AppSpacing.screenPaddingH,
                    60,
                  ),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 20,
                      childAspectRatio: 0.65,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final template = albumTemplates[index];
                        final existingAlbum = childAlbums
                            .where((a) => a.templateId == template.id)
                            .firstOrNull;
                        return _BookCoverCard(
                          template: template,
                          existingAlbum: existingAlbum,
                          lang: lang,
                          isRtl: isRtl,
                          isDark: isDark,
                          onTap: () => _openTemplatePreview(
                            context,
                            ref,
                            template,
                            lang,
                            existingAlbum,
                          ),
                        );
                      },
                      childCount: albumTemplates.length,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Opens the boutique Squircle bottom sheet previewing the book's milestones.
  void _openTemplatePreview(
    BuildContext context,
    WidgetRef ref,
    AlbumTemplate template,
    String lang,
    PredefinedAlbum? existingAlbum,
  ) {
    HapticFeedback.mediumImpact();
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.onSurfaceLight;
    final secondaryText = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final primaryColor = template.gradientColors.first;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1A22) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 24,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            MediaQuery.of(ctx).padding.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 38,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Book Header Row
              Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: template.gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(template.icon, size: 28, color: Colors.white),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          template.getTitle(lang),
                          style: AppTypography.fromContext(
                            context,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          template.getSubtitle(lang),
                          style: AppTypography.fromContext(
                            context,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: primaryColor.withValues(alpha: 0.28),
                      ),
                    ),
                    child: Text(
                      existingAlbum != null
                          ? '${existingAlbum.filledCount}/${template.slotCount} ${lang == 'ar' ? 'صفحة مكتملة' : (lang == 'fr' ? 'pages complétées' : 'pages completed')}'
                          : l10n.albumTemplateEventCount(template.slotCount),
                      style: AppTypography.fromContext(
                        context,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),
              Divider(
                color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
                height: 1,
              ),
              const SizedBox(height: 14),

              // Included Milestones Title
              Text(
                lang == 'ar' ? 'المحطات المضمنة في هذا الكتاب:' : 'Étapes incluses dans cet album :',
                style: AppTypography.fromContext(
                  context,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: secondaryText,
                ),
              ),
              const SizedBox(height: 10),

              // Slots list (capped preview)
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 210),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: template.slots.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (ctx, i) {
                    final slot = template.slots[i];
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.04)
                            : const Color(0xFFF9F7FA),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? Colors.white10
                              : const Color(0xFFECE7EC),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.14),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              slot.icon,
                              size: 15,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              slot.getTitle(lang),
                              style: AppTypography.fromContext(
                                context,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                          ),
                          Text(
                            '#${slot.order}',
                            style: AppTypography.fromContext(
                              context,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: secondaryText.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Action Button
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: template.gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.38),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    if (existingAlbum != null) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PredefinedAlbumDetailScreen(
                            albumId: existingAlbum.id,
                            childId: _selectedChildId,
                          ),
                        ),
                      );
                    } else {
                      _createAlbum(context, ref, template);
                    }
                  },
                  icon: const Icon(Icons.auto_stories_rounded, color: Colors.white),
                  label: Text(
                    existingAlbum != null
                        ? (lang == 'ar'
                            ? 'متابعة كتاب الذكريات لـ $_selectedChildName'
                            : (lang == 'fr'
                                ? 'Continuer cet album pour $_selectedChildName'
                                : 'Continue photobook for $_selectedChildName'))
                        : (lang == 'ar'
                            ? 'إنشاء كتاب الذكريات لـ $_selectedChildName'
                            : (lang == 'fr'
                                ? 'Créer cet album pour $_selectedChildName'
                                : 'Create this photobook for $_selectedChildName')),
                    style: AppTypography.fromContext(
                      context,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _createAlbum(
    BuildContext context,
    WidgetRef ref,
    AlbumTemplate template,
  ) async {
    final l10n = context.l10n;
    final album = await ref
        .read(predefinedAlbumActionsProvider.notifier)
        .createAlbum(childId: _selectedChildId, templateId: template.id);

    if (!context.mounted) return;

    if (album == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.albumCreateError),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PredefinedAlbumDetailScreen(
          albumId: album.id,
          childId: _selectedChildId,
        ),
      ),
    );
  }
}

/// A tactile 3D Children's Book Cover card with spine binding and boutique styling.
class _BookCoverCard extends StatefulWidget {
  const _BookCoverCard({
    required this.template,
    this.existingAlbum,
    required this.lang,
    required this.isRtl,
    required this.isDark,
    required this.onTap,
  });

  final AlbumTemplate template;
  final PredefinedAlbum? existingAlbum;
  final String lang;
  final bool isRtl;
  final bool isDark;
  final VoidCallback onTap;

  @override
  State<_BookCoverCard> createState() => _BookCoverCardState();
}

class _BookCoverCardState extends State<_BookCoverCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final template = widget.template;
    final primaryColor = template.gradientColors.first;
    final endColor = template.gradientColors.last;

    // Hardcover curvature: rounder on outer opening edge, straighter on book spine
    final borderRadius = widget.isRtl
        ? const BorderRadius.only(
            topRight: Radius.circular(8),
            bottomRight: Radius.circular(8),
            topLeft: Radius.circular(22),
            bottomLeft: Radius.circular(22),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(8),
            bottomLeft: Radius.circular(8),
            topRight: Radius.circular(22),
            bottomRight: Radius.circular(22),
          );

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            boxShadow: [
              // Ambient soft glow matching book color
              BoxShadow(
                color: primaryColor.withValues(
                  alpha: widget.isDark ? 0.28 : 0.22,
                ),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
              // Directional depth shadow
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: widget.isDark ? 0.40 : 0.08,
                ),
                blurRadius: 8,
                offset: const Offset(2, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: borderRadius,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 1. Cheerful Rich Gradient Cover Surface
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryColor, endColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),

                // 2. Subtle Watermark Children's Story Motif
                Positioned(
                  right: widget.isRtl ? null : -18,
                  left: widget.isRtl ? -18 : null,
                  bottom: -15,
                  child: IgnorePointer(
                    child: Icon(
                      template.icon,
                      size: 110,
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                ),

                // 3. Top Sheen & Foil Glow
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 90,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.22),
                          Colors.transparent,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),

                // 4. Photobook Spine Effect (Left in LTR, Right in RTL)
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: widget.isRtl ? null : 0,
                  right: widget.isRtl ? 0 : null,
                  width: 14,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withValues(alpha: 0.25),
                          Colors.black.withValues(alpha: 0.05),
                          Colors.white.withValues(alpha: 0.35),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.4, 0.65, 1.0],
                        begin: widget.isRtl
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        end: widget.isRtl
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                      ),
                    ),
                  ),
                ),

                // 5. Paper Stack Page-Edges Effect (Opposite side of spine)
                Positioned(
                  top: 6,
                  bottom: 6,
                  right: widget.isRtl ? null : 0,
                  left: widget.isRtl ? 0 : null,
                  width: 3.5,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 2,
                          offset: widget.isRtl
                              ? const Offset(-1, 0)
                              : const Offset(1, 0),
                        ),
                      ],
                    ),
                  ),
                ),

                // 6. Cover Content & Typography
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Ribbon Bookmark Milestone Count Pill
                      Align(
                        alignment: AlignmentDirectional.topEnd,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3.5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                widget.existingAlbum != null
                                    ? Icons.check_circle_rounded
                                    : Icons.bookmark_rounded,
                                size: 11,
                                color: widget.existingAlbum != null
                                    ? const Color(0xFF69F0AE)
                                    : const Color(0xFFFFD54F),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                widget.existingAlbum != null
                                    ? '${widget.existingAlbum!.filledCount}/${template.slotCount}'
                                    : '${template.slotCount}',
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Foil-Embossed Icon Container
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.24),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.45),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          template.icon,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Title
                      Text(
                        template.getTitle(widget.lang),
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1.2,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 1.5),
                            ),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 3),

                      // Subtitle
                      Text(
                        template.getSubtitle(widget.lang),
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.88),
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
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
}
