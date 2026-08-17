import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/extensions/l10n_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../profile/models/profile_models.dart';
import '../../profile/providers/profile_providers.dart';
import '../models/capsule.dart';
import '../models/emotion.dart';
import '../providers/capsule_providers.dart';
import '../widgets/audio_recorder.dart';
import '../widgets/emotion_picker.dart';

/// Screen for creating a new capsule.
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
    // Watch actions state for error handling (if needed later)
    ref.watch(capsuleActionsProvider);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.close_rounded, color: textColor),
        ),
        title: Text(
          l10n.capsuleNewTitle,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _canSave ? _saveCapsule : null,
            child: _isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: primary,
                    ),
                  )
                : Text(
                    l10n.albumSave,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: _canSave ? primary : secondaryText,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo section
            _buildPhotoSection(
              context,
              isDark,
              primary,
              textColor,
              secondaryText,
            ),
            const SizedBox(height: AppSpacing.lg),

            // Category selector (mandatory)
            _buildCategorySection(
              context,
              lang,
              isDark,
              primary,
              textColor,
              secondaryText,
            ),
            const SizedBox(height: AppSpacing.lg),

            // Date of capture
            _buildDateSection(
              context,
              isDark,
              primary,
              textColor,
              secondaryText,
            ),
            const SizedBox(height: AppSpacing.lg),

            // Child selector
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
            const SizedBox(height: AppSpacing.lg),

            // Emotion picker
            EmotionPicker(
              selectedEmotion: _selectedEmotion,
              onEmotionSelected: (emotion) {
                setState(() => _selectedEmotion = emotion);
              },
            ),
            const SizedBox(height: AppSpacing.lg),

            // Audio recorder
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
            const SizedBox(height: AppSpacing.lg),

            // Tags
            _buildTagsSection(context, isDark, primary, textColor, secondaryText),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  bool get _canSave =>
      _selectedPhoto != null &&
      _selectedChild != null &&
      _selectedEmotion != null &&
      _selectedCategory != null &&
      !_isLoading;

  Widget _buildPhotoSection(
    BuildContext context,
    bool isDark,
    Color primary,
    Color textColor,
    Color secondaryText,
  ) {
    final l10n = context.l10n;
    if (_selectedPhoto != null) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(
              _selectedPhoto!,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
            ),
          ),
          PositionedDirectional(
            top: 8,
            end: 8,
            child: IconButton(
              onPressed: () => setState(() => _selectedPhoto = null),
              style: IconButton.styleFrom(backgroundColor: Colors.black54),
              icon: const Icon(Icons.close_rounded, color: Colors.white),
            ),
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: _showPhotoSourceSheet,
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.surfaceDark
              : AppColors.surfaceContainerLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
            width: 2,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add_a_photo_rounded, size: 28, color: primary),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.capsuleAddPhoto,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.capsulePhotoSourceHint,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontSize: 13, color: secondaryText),
            ),
          ],
        ),
      ),
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
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontSize: 13, color: textColor),
              ),
            ),
          ],
        ),
      );
    }

    // Auto-select first child if not selected
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
        Text(
          l10n.capsuleWhichChild,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: children.map((child) {
            final isSelected = _selectedChild?.id == child.id;
            return GestureDetector(
              onTap: () => setState(() => _selectedChild = child),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? primary.withValues(alpha: 0.15)
                      : (isDark
                            ? AppColors.surfaceContainerDark
                            : AppColors.surfaceContainerLight),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? primary : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: isSelected
                          ? primary
                          : secondaryText.withValues(alpha: 0.2),
                      child: Text(
                        child.name.isNotEmpty
                            ? child.name[0].toUpperCase()
                            : '?',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : secondaryText,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      child.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: isSelected ? primary : textColor,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
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
        Text(
          l10n.capsuleTagsOptional,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Tag input
        TextField(
          controller: _tagController,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: textColor),
          decoration: InputDecoration(
            hintText: l10n.capsuleAddTagHint,
            hintStyle: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: secondaryText),
            filled: true,
            fillColor: isDark
                ? AppColors.inputBackgroundDark
                : AppColors.inputBackgroundLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            suffixIcon: IconButton(
              onPressed: _addTag,
              icon: Icon(Icons.add_rounded, color: primary),
            ),
          ),
          onSubmitted: (_) => _addTag(),
        ),

        if (_tags.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: _tags
                .map(
                  (tag) => Chip(
                    label: Text(
                      '#$tag',
                      style: Theme.of(
                        context,
                      ).textTheme.labelSmall?.copyWith(color: textColor),
                    ),
                    deleteIcon: Icon(
                      Icons.close,
                      size: 16,
                      color: secondaryText,
                    ),
                    onDeleted: () => setState(() => _tags.remove(tag)),
                    backgroundColor: isDark
                        ? AppColors.surfaceContainerDark
                        : AppColors.surfaceContainerLight,
                    side: BorderSide.none,
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
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
            Text(
              l10n.capsuleCategory,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              l10n.capsuleRequired,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontSize: 12, color: AppColors.error),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: CapsuleCategory.values.map((cat) {
            final isSelected = _selectedCategory == cat;
            return GestureDetector(
              onTap: () => setState(() => _selectedCategory = cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? primary.withValues(alpha: 0.15)
                      : (isDark
                            ? AppColors.surfaceContainerDark
                            : AppColors.surfaceContainerLight),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? primary : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(cat.emoji, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(
                      cat.getLabel(lang),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: isSelected ? primary : textColor,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateSection(
    BuildContext context,
    bool isDark,
    Color primary,
    Color textColor,
    Color secondaryText,
  ) {
    final l10n = context.l10n;
    final formattedDate = _capturedAt != null
        ? '${_capturedAt!.day.toString().padLeft(2, '0')}/${_capturedAt!.month.toString().padLeft(2, '0')}/${_capturedAt!.year}'
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.capsulePhotoDate,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        GestureDetector(
          onTap: () => _pickCapturedDate(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.inputBackgroundDark
                  : AppColors.inputBackgroundLight,
              borderRadius: BorderRadius.circular(12),
              border: _capturedAt != null
                  ? Border.all(color: primary.withValues(alpha: 0.5))
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 18,
                  color: _capturedAt != null ? primary : secondaryText,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    formattedDate ?? l10n.capsuleTodayDefault,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
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
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: 11,
            color: secondaryText,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.capsuleChooseSource,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
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
            const SizedBox(height: AppSpacing.md),
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
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedPhoto = File(image.path);
        });
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
