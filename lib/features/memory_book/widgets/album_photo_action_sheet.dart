import 'package:flutter/material.dart';

import '../../../core/extensions/l10n_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Modal bottom sheet allowing the mother to manage a photo on an album page or slot:
/// 1. Replace with an existing memory capsule.
/// 2. Pick a new photo from the phone gallery (with crop/zoom step).
/// 3. Take a fresh photo with the camera (with crop/zoom step).
/// 4. Crop, pan, zoom, or rotate the current photo without touching the original capsule.
/// 5. Clear the photo from the page/slot without deleting the original memory.
/// 6. Cancel modifications cleanly.
class AlbumPhotoActionSheet extends StatelessWidget {
  const AlbumPhotoActionSheet({
    super.key,
    required this.title,
    this.subtitle,
    required this.hasPhoto,
    required this.accentColor,
    required this.onPickFromMemories,
    required this.onPickFromGallery,
    required this.onTakePhoto,
    this.onCrop,
    this.onClear,
  });

  final String title;
  final String? subtitle;
  final bool hasPhoto;
  final Color accentColor;
  final VoidCallback onPickFromMemories;
  final VoidCallback onPickFromGallery;
  final VoidCallback onTakePhoto;
  final VoidCallback? onCrop;
  final VoidCallback? onClear;

  static Future<void> show({
    required BuildContext context,
    required String title,
    String? subtitle,
    required bool hasPhoto,
    required Color accentColor,
    required VoidCallback onPickFromMemories,
    required VoidCallback onPickFromGallery,
    required VoidCallback onTakePhoto,
    VoidCallback? onCrop,
    VoidCallback? onClear,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AlbumPhotoActionSheet(
        title: title,
        subtitle: subtitle,
        hasPhoto: hasPhoto,
        accentColor: accentColor,
        onPickFromMemories: onPickFromMemories,
        onPickFromGallery: onPickFromGallery,
        onTakePhoto: onTakePhoto,
        onCrop: onCrop,
        onClear: onClear,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = Localizations.localeOf(context).languageCode;
    final isAr = lang == 'ar';
    final isFr = lang == 'fr';

    final bgColor = isDark ? const Color(0xFF1E1A22) : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.onSurfaceLight;
    final secondaryColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.12),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Drag Handle
                Center(
                  child: Container(
                    width: 44,
                    height: 4.5,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black12,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Sheet Header
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        hasPhoto
                            ? Icons.photo_filter_rounded
                            : Icons.add_photo_alternate_rounded,
                        color: accentColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: AppTypography.fromContext(
                              context,
                              fontSize: 16.5,
                              fontWeight: FontWeight.w800,
                              color: textColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle ??
                                (hasPhoto
                                    ? (isAr
                                          ? 'استبدال، تعديل أو قص الصورة'
                                          : (isFr
                                                ? 'Remplacer, recadrer ou ajuster la photo'
                                                : 'Replace, crop or adjust photo'))
                                    : (isAr
                                          ? 'إضافة صورة لهذه الصفحة'
                                          : (isFr
                                                ? 'Ajouter une photo à cette page'
                                                : 'Add a photo to this page'))),
                            style: AppTypography.fromContext(
                              context,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: secondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        color: secondaryColor,
                        size: 20,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Divider(
                  height: 1,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.06),
                ),
                const SizedBox(height: 10),

                // Option 1: Pick from existing capsules
                _buildActionTile(
                  context: context,
                  icon: Icons.collections_bookmark_outlined,
                  iconColor: accentColor,
                  title: isAr
                      ? 'اختيار من ذكرياتي'
                      : (isFr
                            ? 'Choisir parmi mes souvenirs'
                            : 'Choose from my memories'),
                  subtitle: isAr
                      ? 'ربط كبسولة موجودة مسبقاً لهذا الطفل'
                      : (isFr
                            ? 'Sélectionner une capsule existante'
                            : 'Select an existing memory capsule'),
                  onTap: () {
                    Navigator.pop(context);
                    onPickFromMemories();
                  },
                  isDark: isDark,
                ),

                // Option 2: Take photo with camera
                _buildActionTile(
                  context: context,
                  icon: Icons.camera_alt_outlined,
                  iconColor: AppColors.success,
                  title: isAr
                      ? 'التقاط صورة جديدة'
                      : (isFr ? 'Prendre une photo' : 'Take a photo'),
                  subtitle: isAr
                      ? 'فتح الكاميرا والتقاط صورة فورية'
                      : (isFr
                            ? 'Ouvrir l\'appareil photo instantanément'
                            : 'Open camera and capture now'),
                  onTap: () {
                    Navigator.pop(context);
                    onTakePhoto();
                  },
                  isDark: isDark,
                ),

                // Option 3: Choose from gallery
                _buildActionTile(
                  context: context,
                  icon: Icons.photo_library_outlined,
                  iconColor: const Color(0xFFD97706), // warm amber, no purple
                  title: isAr
                      ? 'اختيار من معرض الصور'
                      : (isFr
                            ? 'Choisir depuis la galerie'
                            : 'Choose from gallery'),
                  subtitle: isAr
                      ? 'استيراد صورة من ذاكرة الهاتف'
                      : (isFr
                            ? 'Importer une photo de votre téléphone'
                            : 'Import a photo from phone storage'),
                  onTap: () {
                    Navigator.pop(context);
                    onPickFromGallery();
                  },
                  isDark: isDark,
                ),

                // Option 4: Crop & Adjust current photo (if has photo)
                if (hasPhoto && onCrop != null) ...[
                  _buildActionTile(
                    context: context,
                    icon: Icons.crop_rotate_rounded,
                    iconColor: accentColor,
                    title: isAr
                        ? 'قص وتعديل وضبط الصورة'
                        : (isFr ? 'Recadrer & Ajuster' : 'Crop & Adjust photo'),
                    subtitle: isAr
                        ? 'التقريب، التدوير، وضبط التمركز'
                        : (isFr
                              ? 'Zoomer, repositionner ou pivoter'
                              : 'Zoom, pan, reposition or rotate'),
                    onTap: () {
                      Navigator.pop(context);
                      onCrop!();
                    },
                    isDark: isDark,
                  ),
                ],

                // Option 5: Clear photo from page/slot (if has photo)
                if (hasPhoto && onClear != null) ...[
                  _buildActionTile(
                    context: context,
                    icon: Icons.delete_outline_rounded,
                    iconColor: AppColors.error,
                    title: isAr
                        ? 'إزالة من الألبوم'
                        : (isFr ? 'Retirer de la page' : 'Remove from page'),
                    subtitle: isAr
                        ? 'تفريغ الصفحة دون حذف الكبسولة الأصلية'
                        : (isFr
                              ? 'Garde la capsule intacte dans vos souvenirs'
                              : 'Keeps the original capsule in your timeline'),
                    onTap: () {
                      Navigator.pop(context);
                      onClear!();
                    },
                    isDestructive: true,
                    isDark: isDark,
                  ),
                ],

                const SizedBox(height: 12),

                // Cancel button
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    side: BorderSide(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.15)
                          : Colors.black.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Text(
                    l10n.albumCancel,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDark,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: isDestructive
            ? AppColors.error.withValues(alpha: isDark ? 0.12 : 0.06)
            : isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.black.withValues(alpha: 0.025),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDestructive
              ? AppColors.error.withValues(alpha: 0.25)
              : isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 2,
          ),
          leading: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: isDark ? 0.2 : 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          title: Text(
            title,
            style: AppTypography.fromContext(
              context,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isDestructive
                  ? AppColors.error
                  : (isDark ? Colors.white : AppColors.onSurfaceLight),
            ),
          ),
          subtitle: Text(
            subtitle,
            style: AppTypography.fromContext(
              context,
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: isDestructive
                  ? AppColors.error.withValues(alpha: 0.8)
                  : (isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight),
            ),
          ),
          trailing: Icon(
            Icons.chevron_right_rounded,
            size: 18,
            color: isDark ? Colors.white30 : Colors.black26,
          ),
        ),
      ),
    );
  }
}
