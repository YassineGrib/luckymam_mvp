import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../core/extensions/l10n_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../profile/models/profile_models.dart';
import '../../profile/providers/profile_providers.dart';
import '../models/capsule.dart';
import '../models/emotion.dart';
import '../providers/capsule_providers.dart';
import '../widgets/audio_recorder.dart';
import '../widgets/emotion_picker.dart';
import '../widgets/image_crop_screen.dart';
import '../../../shared/widgets/top_ambient_gradient.dart';

/// Screen for creating a new capsule with a refined, tactile card-based UI.
class CreateCapsuleScreen extends ConsumerStatefulWidget {
  final String? milestoneId;
  final String? vaccineGroupId;
  final String? albumId;
  final String? albumSlotId;
  final String? albumType;
  final String? preselectedChildId;

  const CreateCapsuleScreen({
    super.key,
    this.milestoneId,
    this.vaccineGroupId,
    this.albumId,
    this.albumSlotId,
    this.albumType,
    this.preselectedChildId,
  });

  @override
  ConsumerState<CreateCapsuleScreen> createState() =>
      _CreateCapsuleScreenState();
}

class _CreateCapsuleScreenState extends ConsumerState<CreateCapsuleScreen> {
  final ImagePicker _picker = ImagePicker();

  File? _selectedPhoto;
  File? _recordedAudio;
  int? _audioDuration;
  Emotion? _selectedEmotion;
  Child? _selectedChild;
  final List<String> _tags = [];
  final TextEditingController _tagController = TextEditingController();
  DateTime? _capturedAt;
  CapsuleCategory? _selectedCategory;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.vaccineGroupId != null) {
      _selectedCategory = CapsuleCategory.enfance;
    }
  }

  @override
  void dispose() {
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lang = Localizations.localeOf(context).languageCode;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;
    final textColor = isDark ? Colors.white : AppColors.onSurfaceLight;
    final secondaryText = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final primary = isDark ? AppColors.primaryDark : AppColors.primaryLight;

    final childrenAsync = ref.watch(childrenProvider);
    ref.watch(capsuleActionsProvider);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          const TopAmbientGradient(height: 420),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPaddingH,
                14,
                AppSpacing.screenPaddingH,
                32,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Integrated Top Header ───────────────────
                  _buildHeader(
                    context,
                    isDark,
                    primary,
                    textColor,
                    secondaryText,
                  ),
                  const SizedBox(height: 18),

                  // 📸 Section 1: Photo Hero Card
                  _buildPhotoSection(context, isDark, primary, textColor, secondaryText),
                  const SizedBox(height: AppSpacing.md),

                  // 📂 Section 2: Essential Info (Category & Capture Date)
                  _buildSectionCard(
                    context: context,
                    isDark: isDark,
                    watermarkIcon: Icons.auto_stories_rounded,
                    backgroundColor: isDark
                        ? const Color(0xFF261D24)
                        : const Color(0xFFFFF9FA),
                    borderColor: isDark
                        ? AppColors.primaryLight.withValues(alpha: 0.25)
                        : AppColors.primaryLight.withValues(alpha: 0.16),
                    children: [
                      _buildCategorySection(
                        context,
                        lang,
                        isDark,
                        primary,
                        textColor,
                        secondaryText,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Divider(
                          height: 1,
                          color: isDark ? Colors.white10 : const Color(0xFFF0EBF4),
                        ),
                      ),
                      _buildDateSection(
                        context,
                        lang,
                        isDark,
                        primary,
                        textColor,
                        secondaryText,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // 👶 Section 3: Child & Emotion
                  _buildSectionCard(
                    context: context,
                    isDark: isDark,
                    watermarkIcon: Icons.mood_rounded,
                    backgroundColor: isDark
                        ? const Color(0xFF221E2C)
                        : const Color(0xFFFAF7FF),
                    borderColor: isDark
                        ? const Color(0xFF8B5CF6).withValues(alpha: 0.25)
                        : const Color(0xFF8B5CF6).withValues(alpha: 0.16),
                    children: [
                      childrenAsync.when(
                        loading: () => const SizedBox.shrink(),
                        error: (_, _) => const SizedBox.shrink(),
                        data: (children) => _buildChildSelector(
                          context,
                          children,
                          isDark,
                          primary,
                          textColor,
                          secondaryText,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Divider(
                          height: 1,
                          color: isDark ? Colors.white10 : const Color(0xFFEFEAF6),
                        ),
                      ),
                      EmotionPicker(
                        selectedEmotion: _selectedEmotion,
                        onEmotionSelected: (emotion) {
                          setState(() => _selectedEmotion = emotion);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // 🎙️ Section 4: Voice Note & Tags (Optional)
                  _buildSectionCard(
                    context: context,
                    isDark: isDark,
                    watermarkIcon: Icons.graphic_eq_rounded,
                    backgroundColor: isDark
                        ? const Color(0xFF1D2326)
                        : const Color(0xFFF7FBFA),
                    borderColor: isDark
                        ? const Color(0xFF14B8A6).withValues(alpha: 0.25)
                        : const Color(0xFF14B8A6).withValues(alpha: 0.18),
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.mic_rounded, size: 16, color: primary),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.capsuleVoiceMessageOptional.replaceAll('🎤', '').trim(),
                            style: AppTypography.fromContext(
                              context,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      if (_recordedAudio == null)
                        AudioRecorderWidget(
                          onRecordingComplete: (file, duration) {
                            setState(() {
                              _recordedAudio = file;
                              _audioDuration = duration;
                            });
                          },
                        )
                      else
                        RecordedAudioPreview(
                          duration: _audioDuration!,
                          onDelete: () {
                            setState(() {
                              _recordedAudio = null;
                              _audioDuration = null;
                            });
                          },
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Divider(
                          height: 1,
                          color: isDark ? Colors.white10 : const Color(0xFFEBF2F0),
                        ),
                      ),
                      _buildTagsSection(
                        context,
                        isDark,
                        primary,
                        textColor,
                        secondaryText,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildStickyBottomBar(
        context,
        isDark,
        primary,
        textColor,
        secondaryText,
      ),
    );
  }

  bool get _canSave =>
      _selectedPhoto != null &&
      _selectedChild != null &&
      _selectedEmotion != null &&
      _selectedCategory != null &&
      !_isLoading;

  Widget _buildHeader(
    BuildContext context,
    bool isDark,
    Color primary,
    Color textColor,
    Color secondaryText,
  ) {
    final l10n = context.l10n;

    return Row(
      children: [
        // Close Button with Soft Squircle Backdrop
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark
                    ? Colors.white12
                    : Colors.black.withValues(alpha: 0.06),
                width: 1,
              ),
            ),
            child: Icon(Icons.close_rounded, size: 20, color: textColor),
          ),
        ),
        const SizedBox(width: 12),

        // Gradient Icon Squircle matching app signature
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryLight.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.camera_enhance_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),

        // Title & Localized Subtitle
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.capsuleNewTitle,
                style: AppTypography.fromContext(
                  context,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                l10n.milestone_capture_this_moment,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.fromContext(
                  context,
                  fontSize: 12,
                  color: secondaryText,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Card wrapper for visual grouping with Home Bento aesthetics and optional corner watermark
  Widget _buildSectionCard({
    required BuildContext context,
    required bool isDark,
    required List<Widget> children,
    Color? backgroundColor,
    Color? borderColor,
    IconData? watermarkIcon,
  }) {
    final bg = backgroundColor ??
        (isDark ? const Color(0xFF221F28) : Colors.white);
    final border = borderColor ??
        (isDark ? AppColors.dividerDark : const Color(0xFFECEBF0));

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: border, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.035),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          if (watermarkIcon != null)
            PositionedDirectional(
              bottom: -16,
              end: -12,
              child: IgnorePointer(
                child: Icon(
                  watermarkIcon,
                  size: 96,
                  color: AppColors.primaryLight.withValues(
                    alpha: isDark ? 0.07 : 0.04,
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSection(
    BuildContext context,
    bool isDark,
    Color primary,
    Color textColor,
    Color secondaryText,
  ) {
    final l10n = context.l10n;

    if (_selectedPhoto != null) {
      return Container(
        height: 280,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.file(
                _selectedPhoto!,
                fit: BoxFit.cover,
              ),
              // Top Action Overlay Pill Buttons
              PositionedDirectional(
                top: 10,
                start: 10,
                child: _buildFrostedActionButton(
                  icon: Icons.crop_rounded,
                  label: l10n.capsuleCropButton,
                  onTap: () => _openCropScreen(_selectedPhoto!),
                ),
              ),
              PositionedDirectional(
                top: 10,
                end: 10,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildFrostedActionButton(
                      icon: Icons.refresh_rounded,
                      label: l10n.capsuleChangePhoto,
                      onTap: _showPhotoSourceSheet,
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => setState(() => _selectedPhoto = null),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24),
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: Colors.white,
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

    return GestureDetector(
      onTap: _showPhotoSourceSheet,
      child: Container(
        width: double.infinity,
        height: 205,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF2B2028), const Color(0xFF201B24)]
                : [const Color(0xFFFFF4F7), const Color(0xFFFBF2FE)],
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: primary.withValues(alpha: 0.25),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: primary.withValues(alpha: isDark ? 0.12 : 0.05),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Corner watermark icon
            PositionedDirectional(
              bottom: -18,
              end: -10,
              child: IgnorePointer(
                child: Icon(
                  Icons.camera_alt_rounded,
                  size: 110,
                  color: primary.withValues(alpha: isDark ? 0.08 : 0.05),
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryLight.withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.add_a_photo_rounded,
                      size: 26,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.capsuleAddPhoto,
                  style: AppTypography.fromContext(
                    context,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.capsulePhotoSourceHint,
                  style: AppTypography.fromContext(
                    context,
                    fontSize: 12,
                    color: secondaryText,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrostedActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: Colors.white),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(CapsuleCategory cat) {
    switch (cat) {
      case CapsuleCategory.preGestation:
        return const Color(0xFF0D9488);
      case CapsuleCategory.gestation:
        return const Color(0xFFE11D48);
      case CapsuleCategory.postPartum:
        return const Color(0xFFF59E0B);
      case CapsuleCategory.enfance:
        return const Color(0xFF10B981);
      case CapsuleCategory.adulte:
        return const Color(0xFF8B5CF6);
    }
  }

  Widget _buildCategorySection(
    BuildContext context,
    String lang,
    bool isDark,
    Color primary,
    Color textColor,
    Color secondaryText,
  ) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.category_rounded, size: 16, color: textColor),
            const SizedBox(width: 6),
            Text(
              l10n.capsuleCategory,
              style: AppTypography.fromContext(
                context,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              l10n.capsuleRequired,
              style: AppTypography.fromContext(
                context,
                fontSize: 11,
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: CapsuleCategory.values.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.15,
          ),
          itemBuilder: (context, index) {
            final cat = CapsuleCategory.values[index];
            final isSelected = _selectedCategory == cat;
            final catColor = _getCategoryColor(cat);

            return GestureDetector(
              onTap: () => setState(() => _selectedCategory = cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? catColor.withValues(alpha: isDark ? 0.22 : 0.12)
                      : (isDark
                            ? const Color(0xFF221F28)
                            : const Color(0xFFF7F5FA)),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? catColor : (isDark ? Colors.white10 : const Color(0xFFECEAEF)),
                    width: isSelected ? 1.8 : 0.8,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: catColor.withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      cat.icon,
                      size: 22,
                      color: isSelected ? catColor : secondaryText,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      cat.getLabel(lang),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.fromContext(
                        context,
                        fontSize: 11.5,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isSelected ? catColor : textColor,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDateSection(
    BuildContext context,
    String lang,
    bool isDark,
    Color primary,
    Color textColor,
    Color secondaryText,
  ) {
    final l10n = context.l10n;
    final formattedDate = _capturedAt != null
        ? DateFormat('d MMMM yyyy', lang).format(_capturedAt!)
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.calendar_today_rounded, size: 16, color: textColor),
            const SizedBox(width: 6),
            Text(
              l10n.capsulePhotoDate,
              style: AppTypography.fromContext(
                context,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        GestureDetector(
          onTap: _pickCapturedDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.inputBackgroundDark
                  : AppColors.inputBackgroundLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _capturedAt != null
                    ? primary.withValues(alpha: 0.5)
                    : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.event_rounded,
                  size: 18,
                  color: _capturedAt != null ? primary : secondaryText,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    formattedDate ?? l10n.capsuleTodayDefault,
                    style: AppTypography.fromContext(
                      context,
                      fontSize: 13.5,
                      fontWeight: _capturedAt != null ? FontWeight.w600 : FontWeight.w400,
                      color: _capturedAt != null ? textColor : secondaryText,
                    ),
                  ),
                ),
                if (_capturedAt != null)
                  GestureDetector(
                    onTap: () => setState(() => _capturedAt = null),
                    child: Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: secondaryText,
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.capsulePhotoDateHint,
          style: AppTypography.fromContext(
            context,
            fontSize: 11,
            color: secondaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildChildSelector(
    BuildContext context,
    List<Child> children,
    bool isDark,
    Color primary,
    Color textColor,
    Color secondaryText,
  ) {
    final l10n = context.l10n;

    if (children.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline_rounded, color: AppColors.warning),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                l10n.capsuleAddChildPrompt,
                style: AppTypography.fromContext(
                  context,
                  fontSize: 13,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_selectedChild == null && children.isNotEmpty) {
      if (widget.preselectedChildId != null) {
        _selectedChild = children.firstWhere(
          (c) => c.id == widget.preselectedChildId,
          orElse: () => children.first,
        );
      } else {
        _selectedChild = children.first;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.face_rounded, size: 16, color: textColor),
            const SizedBox(width: 6),
            Text(
              l10n.capsuleWhichChild,
              style: AppTypography.fromContext(
                context,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              l10n.capsuleRequired,
              style: AppTypography.fromContext(
                context,
                fontSize: 11,
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: children.map((child) {
              final isSelected = _selectedChild?.id == child.id;
              final hasPhoto = child.photoUrl != null && child.photoUrl!.isNotEmpty;

              return Padding(
                padding: const EdgeInsetsDirectional.only(end: 10),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedChild = child),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsetsDirectional.fromSTEB(6, 5, 14, 5),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? primary.withValues(alpha: isDark ? 0.22 : 0.12)
                          : (isDark
                                ? const Color(0xFF262230)
                                : const Color(0xFFF6F3F9)),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isSelected
                            ? primary
                            : (isDark ? Colors.white12 : const Color(0xFFE6E2EC)),
                        width: isSelected ? 1.8 : 1.0,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: primary.withValues(alpha: 0.22),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Enlarged Child Photo Avatar (36x36)
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? primary : Colors.white,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: hasPhoto
                                ? Image.network(
                                    child.photoUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => _buildChildInitials(
                                      child,
                                      isSelected,
                                      primary,
                                      secondaryText,
                                    ),
                                  )
                                : _buildChildInitials(
                                    child,
                                    isSelected,
                                    primary,
                                    secondaryText,
                                  ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          child.name,
                          style: AppTypography.fromContext(
                            context,
                            fontSize: 13.5,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w600,
                            color: isSelected ? primary : textColor,
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 6),
                          Icon(
                            Icons.check_circle_rounded,
                            size: 16,
                            color: primary,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildChildInitials(
    Child child,
    bool isSelected,
    Color primary,
    Color secondaryText,
  ) {
    return Container(
      color: isSelected ? primary : secondaryText.withValues(alpha: 0.25),
      child: Center(
        child: Text(
          child.name.isNotEmpty ? child.name[0].toUpperCase() : '?',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildTagsSection(
    BuildContext context,
    bool isDark,
    Color primary,
    Color textColor,
    Color secondaryText,
  ) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.local_offer_rounded, size: 16, color: textColor),
            const SizedBox(width: 6),
            Text(
              l10n.capsuleTagsOptional,
              style: AppTypography.fromContext(
                context,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: _tagController,
          style: AppTypography.fromContext(context, fontSize: 13.5, color: textColor),
          decoration: InputDecoration(
            hintText: l10n.capsuleAddTagHint,
            hintStyle: TextStyle(color: secondaryText, fontSize: 13),
            filled: true,
            fillColor: isDark
                ? AppColors.inputBackgroundDark
                : AppColors.inputBackgroundLight,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            prefixIcon: Icon(Icons.tag_rounded, size: 18, color: secondaryText),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            suffixIcon: IconButton(
              onPressed: _addTag,
              icon: Icon(Icons.add_circle_rounded, color: primary, size: 22),
            ),
          ),
          onSubmitted: (_) => _addTag(),
        ),
        if (_tags.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: _tags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.surfaceContainerDark
                      : AppColors.surfaceContainerLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '#$tag',
                      style: AppTypography.fromContext(
                        context,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => setState(() => _tags.remove(tag)),
                      child: Icon(
                        Icons.close_rounded,
                        size: 14,
                        color: secondaryText,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildStickyBottomBar(
    BuildContext context,
    bool isDark,
    Color primary,
    Color textColor,
    Color secondaryText,
  ) {
    final l10n = context.l10n;

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SizedBox(
        height: 52,
        child: ElevatedButton(
          onPressed: _canSave ? _saveCapsule : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: _canSave ? primary : (isDark ? Colors.white12 : Colors.black12),
            foregroundColor: Colors.white,
            elevation: _canSave ? 4 : 0,
            shadowColor: primary.withValues(alpha: 0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      size: 18,
                      color: _canSave ? Colors.white : secondaryText,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.capsuleCreateCTA,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _canSave ? Colors.white : secondaryText,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Future<void> _pickCapturedDate() async {
    final l10n = context.l10n;
    final picked = await showDatePicker(
      context: context,
      initialDate: _capturedAt ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      helpText: l10n.capsulePhotoDatePickerHelp,
      confirmText: l10n.confirm,
      cancelText: l10n.albumCancel,
      builder: (context, child) {
        final primary = Theme.of(context).brightness == Brightness.dark
            ? AppColors.primaryDark
            : AppColors.primaryLight;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: primary, onPrimary: Colors.white),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _capturedAt = picked);
    }
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _showPhotoSourceSheet() {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final textColor = isDark ? Colors.white : AppColors.onSurfaceLight;
    final primary = isDark ? AppColors.primaryDark : AppColors.primaryLight;

    showModalBottomSheet(
      context: context,
      backgroundColor: surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.capsuleChooseSource,
              style: AppTypography.fromContext(
                context,
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSourceOption(
                  icon: Icons.camera_alt_rounded,
                  label: l10n.capsuleCamera,
                  color: primary,
                  onTap: () {
                    Navigator.pop(context);
                    _pickPhoto(ImageSource.camera);
                  },
                ),
                _buildSourceOption(
                  icon: Icons.photo_library_rounded,
                  label: l10n.capsuleGallery,
                  color: AppColors.smaltBlue,
                  onTap: () {
                    Navigator.pop(context);
                    _pickPhoto(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.onSurfaceLight;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.2)),
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: AppTypography.fromContext(
              context,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openCropScreen(File file) async {
    final cropped = await Navigator.of(context).push<File>(
      MaterialPageRoute(
        builder: (_) => ImageCropScreen(imageFile: file),
      ),
    );
    if (cropped != null && mounted) {
      setState(() {
        _selectedPhoto = cropped;
      });
    }
  }

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 90,
      );

      if (image != null && mounted) {
        final originalFile = File(image.path);
        setState(() {
          _selectedPhoto = originalFile;
        });
        _openCropScreen(originalFile);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.milestone_error(e.toString())),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _saveCapsule() async {
    if (!_canSave) return;

    setState(() => _isLoading = true);

    final result = await ref
        .read(capsuleActionsProvider.notifier)
        .createCapsule(
          childId: _selectedChild!.id,
          photoFile: _selectedPhoto!,
          audioFile: _recordedAudio,
          audioDuration: _audioDuration,
          emotion: _selectedEmotion!,
          milestoneId: widget.milestoneId,
          vaccineGroupId: widget.vaccineGroupId,
          albumId: widget.albumId,
          albumSlotId: widget.albumSlotId,
          albumType: widget.albumType,
          tags: _tags,
          capturedAt: _capturedAt,
          category: _selectedCategory,
        );

    setState(() => _isLoading = false);

    if (result != null && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.capsuleCreatedSuccess),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }
}
