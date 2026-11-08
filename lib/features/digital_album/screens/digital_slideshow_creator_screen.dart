import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions/l10n_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/top_ambient_gradient.dart';
import '../../capsules/models/capsule.dart';
import '../../capsules/providers/capsule_providers.dart';
import '../../memory_book/widgets/capsule_picker_sheet.dart';
import '../models/digital_slideshow_model.dart';
import 'digital_slideshow_player_screen.dart';

/// Digital Album Slideshow Creator & Reorder Screen (LM-DIG-001).
/// Allows the user to:
/// - Select photos from child's memories
/// - Reorder slides via drag-and-drop
/// - Enforce min 3 and max 12 photos
/// - Launch the fullscreen slideshow player
class DigitalSlideshowCreatorScreen extends ConsumerStatefulWidget {
  const DigitalSlideshowCreatorScreen({
    super.key,
    required this.childId,
    required this.childName,
    this.initialSlides,
  });

  final String childId;
  final String childName;
  final List<DigitalSlide>? initialSlides;

  @override
  ConsumerState<DigitalSlideshowCreatorScreen> createState() =>
      _DigitalSlideshowCreatorScreenState();
}

class _DigitalSlideshowCreatorScreenState
    extends ConsumerState<DigitalSlideshowCreatorScreen> {
  final List<DigitalSlide> _selectedSlides = [];
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialSlides != null && widget.initialSlides!.isNotEmpty) {
      _selectedSlides.addAll(widget.initialSlides!);
      _initialized = true;
    }
  }

  void _onReorder(int oldIndex, int newIndex) {
    HapticFeedback.selectionClick();
    setState(() {
      final item = _selectedSlides.removeAt(oldIndex);
      _selectedSlides.insert(newIndex, item);
    });
  }

  void _removeSlide(int index) {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedSlides.removeAt(index);
    });
  }

  Future<void> _choosePhoto() async {
    Capsule? selected;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => CapsulePickerSheet(
        childId: widget.childId,
        onSelected: (capsule) => selected = capsule,
      ),
    );
    if (mounted && selected != null) {
      _toggleCapsule(selected!, Localizations.localeOf(context).languageCode);
    }
  }

  void _toggleCapsule(Capsule capsule, String lang) {
    HapticFeedback.selectionClick();
    final existingIndex = _selectedSlides.indexWhere((s) => s.id == capsule.id);

    setState(() {
      if (existingIndex >= 0) {
        _selectedSlides.removeAt(existingIndex);
      } else {
        if (_selectedSlides.length >= DigitalSlideshow.maxPhotos) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.diaporamaMaxPhotosError),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 2),
            ),
          );
          return;
        }
        _selectedSlides.add(
          DigitalSlide(
            id: capsule.id,
            photoUrl: capsule.photoUrl,
            title: capsule.tags.isNotEmpty
                ? capsule.tags.first
                : capsule.emotion.getLabel(lang),
            date: capsule.capturedAt ?? capsule.createdAt,
            emotions: capsule.allEmotions,
            category: capsule.category,
            tags: capsule.tags,
            order: _selectedSlides.length + 1,
          ),
        );
      }
    });
  }

  void _launchSlideshow() {
    if (_selectedSlides.length < DigitalSlideshow.minPhotos) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.diaporamaMinPhotosError),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    HapticFeedback.mediumImpact();
    final slideshow = DigitalSlideshow(
      childId: widget.childId,
      childName: widget.childName,
      title: context.l10n.diaporamaTitle,
      slides: List.unmodifiable(_selectedSlides),
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DigitalSlideshowPlayerScreen(slideshow: slideshow),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isRtl = context.isRtl;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;
    final textColor = isDark ? Colors.white : AppColors.onSurfaceLight;
    final secondaryText = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final lang = Localizations.localeOf(context).languageCode;

    final capsulesAsync = ref.watch(capsulesByChildProvider(widget.childId));

    // Auto-populate from child's available capsules on first load if initial was empty
    if (!_initialized && capsulesAsync.hasValue) {
      final photoCapsules = capsulesAsync.value!
          .where((c) => c.photoUrl.isNotEmpty)
          .take(DigitalSlideshow.maxPhotos)
          .toList();
      for (int i = 0; i < photoCapsules.length; i++) {
        final c = photoCapsules[i];
        _selectedSlides.add(
          DigitalSlide(
            id: c.id,
            photoUrl: c.photoUrl,
            title: c.tags.isNotEmpty ? c.tags.first : c.emotion.getLabel(lang),
            date: c.capturedAt ?? c.createdAt,
            emotions: c.allEmotions,
            category: c.category,
            tags: c.tags,
            order: i + 1,
          ),
        );
      }
      _initialized = true;
    }

    final isValidCount =
        _selectedSlides.length >= DigitalSlideshow.minPhotos &&
        _selectedSlides.length <= DigitalSlideshow.maxPhotos;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          const TopAmbientGradient(height: 340),

          SafeArea(
            child: Column(
              children: [
                // ── 1. Top Header Bar ──
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPaddingH,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      // Back Button
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
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
                            ),
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
                      const SizedBox(width: 12),

                      // Header Title & Child
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.diaporamaTitle,
                              style: AppTypography.fromContext(
                                context,
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: textColor,
                              ),
                            ),
                            Text(
                              widget.childName,
                              style: AppTypography.fromContext(
                                context,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.coral,
                              ),
                            ),
                          ],
                        ),
                      ),

                      IconButton(
                        onPressed: _choosePhoto,
                        tooltip: l10n.albumExistingCapsule,
                        icon: const Icon(
                          Icons.add_photo_alternate_outlined,
                          color: AppColors.coral,
                        ),
                      ),
                      // Count Pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: isValidCount
                              ? const Color(0xFF2E7D32).withValues(alpha: 0.12)
                              : const Color(0xFFFF8F00).withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isValidCount
                                ? const Color(
                                    0xFF2E7D32,
                                  ).withValues(alpha: 0.35)
                                : const Color(
                                    0xFFFF8F00,
                                  ).withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isValidCount
                                  ? Icons.check_circle_rounded
                                  : Icons.photo_library_rounded,
                              size: 13,
                              color: isValidCount
                                  ? const Color(0xFF2E7D32)
                                  : const Color(0xFFFF8F00),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${_selectedSlides.length}/${DigitalSlideshow.maxPhotos}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: isValidCount
                                    ? const Color(0xFF2E7D32)
                                    : const Color(0xFFFF8F00),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── 2. Helper Guidance Banner ──
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPaddingH,
                    vertical: 4,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? Colors.white10
                            : const Color(0xFFEBE6EB),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.swap_vert_rounded,
                          size: 16,
                          color: AppColors.coral,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isValidCount
                                ? l10n.diaporamaReorderHint
                                : l10n.diaporamaMinPhotosError,
                            style: AppTypography.fromContext(
                              context,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: secondaryText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                // ── 3. Reorderable Slides List ──
                Expanded(
                  child: _selectedSlides.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.photo_library_outlined,
                                  size: 48,
                                  color: secondaryText.withValues(alpha: 0.5),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  l10n.diaporamaMinPhotosError,
                                  style: AppTypography.fromContext(
                                    context,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: secondaryText,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                      : ReorderableListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.screenPaddingH,
                            6,
                            AppSpacing.screenPaddingH,
                            16,
                          ),
                          itemCount: _selectedSlides.length,
                          onReorderItem: _onReorder,
                          itemBuilder: (context, index) {
                            final slide = _selectedSlides[index];
                            return _buildReorderableSlideItem(
                              key: ValueKey(slide.id),
                              index: index,
                              slide: slide,
                              isDark: isDark,
                              textColor: textColor,
                              secondaryText: secondaryText,
                            );
                          },
                        ),
                ),

                // ── 4. Bottom Launch CTA Button ──
                Container(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenPaddingH,
                    10,
                    AppSpacing.screenPaddingH,
                    14,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1822) : Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: isValidCount
                            ? const LinearGradient(
                                colors: [AppColors.coral, Color(0xFFFF8F00)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              )
                            : null,
                        color: isValidCount
                            ? null
                            : Colors.grey.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: isValidCount
                            ? [
                                BoxShadow(
                                  color: AppColors.coral.withValues(
                                    alpha: 0.35,
                                  ),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: ElevatedButton.icon(
                        onPressed: isValidCount ? _launchSlideshow : null,
                        icon: const Icon(
                          Icons.play_circle_filled_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                        label: Text(
                          l10n.diaporamaPlay,
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
                          disabledBackgroundColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
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
    );
  }

  Widget _buildReorderableSlideItem({
    required Key key,
    required int index,
    required DigitalSlide slide,
    required bool isDark,
    required Color textColor,
    required Color secondaryText,
  }) {
    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white10 : const Color(0xFFECE7EC),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Drag Handle
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              Icons.drag_indicator_rounded,
              size: 20,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 6),

          // Order Badge
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: AppColors.coral.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.coral,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Photo Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 52,
              height: 52,
              child: Image.network(
                slide.photoUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  color: Colors.grey.withValues(alpha: 0.2),
                  child: const Icon(Icons.broken_image_rounded, size: 20),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Slide Title & Date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  slide.title,
                  style: AppTypography.fromContext(
                    context,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (slide.date != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    '${slide.date!.day}/${slide.date!.month}/${slide.date!.year}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: secondaryText,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Remove Button
          IconButton(
            onPressed: () => _removeSlide(index),
            icon: const Icon(Icons.close_rounded, size: 18, color: Colors.grey),
            tooltip: 'Retirer',
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}
