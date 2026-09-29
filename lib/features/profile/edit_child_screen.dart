import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../core/extensions/l10n_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/auth_logo_background.dart';
import '../../../shared/widgets/top_ambient_gradient.dart';
import 'models/profile_models.dart';
import 'providers/profile_providers.dart';

/// Available theme accent colors for child profile personalization.
const List<({String hex, String nameAr, String nameFr, Color color})> _kChildPalette = [
  (hex: '#00B0FF', nameAr: 'أزرق سماوي', nameFr: 'Bleu Ciel', color: Color(0xFF00B0FF)),
  (hex: '#FF5252', nameAr: 'وردي مرجاني', nameFr: 'Corail Rose', color: Color(0xFFFF5252)),
  (hex: '#00C853', nameAr: 'أخضر زمردي', nameFr: 'Vert Émeraude', color: Color(0xFF00C853)),
  (hex: '#7C4DFF', nameAr: 'بنفسجي ملكي', nameFr: 'Violet Royal', color: Color(0xFF7C4DFF)),
  (hex: '#FF9100', nameAr: 'ذهبي كهرماني', nameFr: 'Ambre Doré', color: Color(0xFFFF9100)),
  (hex: '#EC407A', nameAr: 'زهري دافئ', nameFr: 'Rose Framboise', color: Color(0xFFEC407A)),
];

const List<String> _kBloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

/// Full-Page Child Profile Editor & Personalization Screen for LuckyMam.
/// Replaces legacy cramped dialog with a comprehensive flagship Bento screen:
/// - Avatar photo management (Camera, Gallery, Remove)
/// - Basic details (Name, Gender with royal styling, Date of Birth & exact age)
/// - Theme color accent picker for personalizing the child's entire profile
/// - Medical vitals (Blood Type selector & Special health/allergy notes)
/// - Irreversible action danger zone (Permanent deletion with safe confirmation)
class EditChildScreen extends ConsumerStatefulWidget {
  const EditChildScreen({super.key, required this.child});

  final Child child;

  @override
  ConsumerState<EditChildScreen> createState() => _EditChildScreenState();
}

class _EditChildScreenState extends ConsumerState<EditChildScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _notesController;
  late DateTime _birthDate;
  late ChildGender _gender;
  String? _bloodType;
  late String _themeColorHex;
  File? _newImageFile;
  bool _removePhoto = false;
  bool _isSaving = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.child.name);
    _notesController = TextEditingController(text: widget.child.notes ?? '');
    _birthDate = widget.child.birthDate;
    _gender = widget.child.gender;
    _bloodType = widget.child.bloodType;
    _themeColorHex = widget.child.themeColorHex ??
        (widget.child.gender == ChildGender.boy ? '#00B0FF' : '#FF5252');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Color get _currentAccentColor {
    final match = _kChildPalette.where((p) => p.hex == _themeColorHex).firstOrNull;
    if (match != null) return match.color;
    return _gender == ChildGender.boy ? const Color(0xFF00B0FF) : const Color(0xFFFF5252);
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        imageQuality: 75,
        maxWidth: 1000,
      );
      if (picked != null) {
        setState(() {
          _newImageFile = File(picked.path);
          _removePhoto = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ أثناء اختيار الصورة: $e')),
        );
      }
    }
  }

  Future<void> _selectBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate,
      firstDate: DateTime(2010),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  Future<void> _saveChild() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إدخال اسم الطفل'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final updatedChild = widget.child.copyWith(
        name: name,
        birthDate: _birthDate,
        gender: _gender,
        photoUrl: _removePhoto ? '' : widget.child.photoUrl,
        bloodType: _bloodType,
        themeColorHex: _themeColorHex,
        notes: _notesController.text.trim(),
      );

      await ref.read(profileActionsProvider.notifier).updateChild(
            updatedChild,
            imageFile: _newImageFile,
          );

      if (mounted) {
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حفظ بيانات الطفل بنجاح'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Color(0xFF00C853),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تعذر الحفظ: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _confirmDelete() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = Localizations.localeOf(context).languageCode;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF261C24) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                lang == 'ar' ? 'حذف ملف الطفل نهائياً؟' : 'Supprimer le profil ?',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        content: Text(
          lang == 'ar'
              ? 'هل أنتِ متأكدة من حذف ملف ${widget.child.name}؟ هذا الإجراء لا يمكن التراجع عنه وسيحذف كافة القياسات والبيانات المسجلة.'
              : 'Êtes-vous sûre de vouloir supprimer le profil de ${widget.child.name} ? Cette action est irréversible.',
          style: TextStyle(
            fontSize: 13,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            height: 1.45,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              lang == 'ar' ? 'إلغاء' : 'Annuler',
              style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(lang == 'ar' ? 'نعم، حذف' : 'Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isDeleting = true);
      try {
        await ref.read(profileActionsProvider.notifier).deleteChild(widget.child.id);
        if (mounted) {
          // Pop out of edit screen and out of child profile screen back to home
          Navigator.of(context).pop(); // Edit screen
          Navigator.of(context).pop(); // Child profile screen
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('فشل الحذف: $e')),
          );
          setState(() => _isDeleting = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    final isRtl = context.isRtl;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final surfaceColor = isDark ? const Color(0xFF221A24) : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.onSurfaceLight;
    final secondaryText = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final accent = _currentAccentColor;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // ── 1. Top Atmospheric Ambient Glow ──
          const TopAmbientGradient(),

          // ── 2. Corner Watermark Logo ──
          const AuthLogoBackground(lightOpacity: 0.05, darkOpacity: 0.03),

          // ── 3. Main Screen Flow ──
          SafeArea(
            child: Column(
              children: [
                // Top Action Header Bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPaddingH,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      // Back Button
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.white.withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isDark ? Colors.white12 : const Color(0xFFE8E0E4),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            isRtl ? Icons.arrow_forward_ios_rounded : Icons.arrow_back_ios_new_rounded,
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
                              lang == 'ar' ? 'تعديل ملف الطفل' : 'Modifier le profil',
                              style: AppTypography.fromContext(
                                context,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.child.name,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Quick Save Top Action
                      GestureDetector(
                        onTap: _isSaving ? null : _saveChild,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8.5),
                          decoration: BoxDecoration(
                            color: accent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: accent.withValues(alpha: 0.35),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_isSaving)
                                const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              else
                                const Icon(Icons.check_rounded, size: 16, color: Colors.white),
                              const SizedBox(width: 6),
                              Text(
                                lang == 'ar' ? 'حفظ' : 'Enregistrer',
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 4),

                // Scrollable Form Body
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenPaddingH,
                      vertical: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── 1. Avatar Photo Picker Section ──
                        _buildAvatarSection(isDark, textColor, secondaryText, accent, lang),

                        const SizedBox(height: 18),

                        // ── 2. Basic Information Bento ──
                        _buildBasicInfoSection(isDark, surfaceColor, textColor, secondaryText, accent, lang),

                        const SizedBox(height: 18),

                        // ── 3. Theme & Personalization Bento ──
                        _buildPersonalizationSection(isDark, surfaceColor, textColor, secondaryText, accent, lang),

                        const SizedBox(height: 18),

                        // ── 4. Health & Medical Notes Bento ──
                        _buildHealthSection(isDark, surfaceColor, textColor, secondaryText, accent, lang),

                        const SizedBox(height: 24),

                        // ── 5. Danger Zone (Delete) ──
                        _buildDangerZoneSection(isDark, surfaceColor, lang),

                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPaddingH,
            6,
            AppSpacing.screenPaddingH,
            12,
          ),
          child: GestureDetector(
            onTap: _isSaving ? null : _saveChild,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [accent, accent.withValues(alpha: 0.88)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle_rounded, size: 18, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            lang == 'ar' ? 'حفظ بيانات الطفل' : 'Enregistrer les modifications',
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  // Section 1: Avatar Photo
  // ═════════════════════════════════════════════════════════════════════════

  Widget _buildAvatarSection(
    bool isDark,
    Color textColor,
    Color secondaryText,
    Color accent,
    String lang,
  ) {
    ImageProvider? imageProvider;
    if (_newImageFile != null) {
      imageProvider = FileImage(_newImageFile!);
    } else if (!_removePhoto && widget.child.photoUrl != null && widget.child.photoUrl!.isNotEmpty) {
      imageProvider = CachedNetworkImageProvider(widget.child.photoUrl!);
    }

    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 104,
                height: 104,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: accent, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: imageProvider != null
                      ? Image(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: accent.withValues(alpha: 0.12),
                          child: Center(
                            child: Icon(
                              Icons.child_care_rounded,
                              size: 48,
                              color: accent,
                            ),
                          ),
                        ),
                ),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? const Color(0xFF221A24) : Colors.white,
                      width: 2.5,
                    ),
                  ),
                  child: const Icon(Icons.camera_alt_rounded, size: 14, color: Colors.white),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Photo Action Chips
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _PhotoOptionChip(
                icon: Icons.photo_camera_rounded,
                label: lang == 'ar' ? 'كاميرا' : 'Caméra',
                textColor: textColor,
                isDark: isDark,
                onTap: () => _pickImage(ImageSource.camera),
              ),
              const SizedBox(width: 10),
              _PhotoOptionChip(
                icon: Icons.photo_library_rounded,
                label: lang == 'ar' ? 'المعرض' : 'Galerie',
                textColor: textColor,
                isDark: isDark,
                onTap: () => _pickImage(ImageSource.gallery),
              ),
              if (imageProvider != null) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _newImageFile = null;
                      _removePhoto = true;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.error,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  // Section 2: Basic Info
  // ═════════════════════════════════════════════════════════════════════════

  Widget _buildBasicInfoSection(
    bool isDark,
    Color surfaceColor,
    Color textColor,
    Color secondaryText,
    Color accent,
    String lang,
  ) {
    final ageText = _formatAge(_birthDate, lang);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surfaceColor,
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
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.badge_outlined, color: accent, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                lang == 'ar' ? 'البيانات الشخصية' : 'Informations personnelles',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Child Name Input
          Text(
            lang == 'ar' ? 'اسم الطفل *' : 'Nom de l\'enfant *',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: secondaryText),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _nameController,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: textColor),
            decoration: InputDecoration(
              hintText: lang == 'ar' ? 'مثال: آدم، مريم...' : 'Ex: Adam, Maryam...',
              prefixIcon: Icon(Icons.person_rounded, color: accent, size: 20),
              filled: true,
              fillColor: isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFFBF8FA),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: isDark ? Colors.white12 : const Color(0xFFE8DFE5)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: isDark ? Colors.white12 : const Color(0xFFE8DFE5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: accent, width: 1.5),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Gender Selection (Prince / Princess)
          Text(
            lang == 'ar' ? 'الجنس *' : 'Genre *',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: secondaryText),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _GenderOptionCard(
                  title: lang == 'ar' ? 'أمير (ولد)' : 'Garçon',
                  icon: Icons.male_rounded,
                  badgeText: '🌟',
                  isSelected: _gender == ChildGender.boy,
                  activeColor: const Color(0xFF00B0FF),
                  isDark: isDark,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _gender = ChildGender.boy);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _GenderOptionCard(
                  title: lang == 'ar' ? 'أميرة (بنت)' : 'Fille',
                  icon: Icons.female_rounded,
                  badgeText: '👑',
                  isSelected: _gender == ChildGender.girl,
                  activeColor: const Color(0xFFFF5252),
                  isDark: isDark,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _gender = ChildGender.girl);
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Date of Birth Selector
          Text(
            lang == 'ar' ? 'تاريخ الميلاد *' : 'Date de naissance *',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: secondaryText),
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: _selectBirthDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFFBF8FA),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFE8DFE5)),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_month_rounded, color: accent, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      DateFormat('d MMMM yyyy', lang == 'ar' ? 'ar' : 'fr_FR').format(_birthDate),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.edit_calendar_rounded,
                    size: 18,
                    color: secondaryText,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Dynamic Age Calculated Display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cake_rounded, size: 14, color: accent),
                const SizedBox(width: 6),
                Text(
                  '${lang == 'ar' ? 'العمر المحسوب:' : 'Âge actuel :'} $ageText',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: accent,
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
  // Section 3: Personalization & Theme Color
  // ═════════════════════════════════════════════════════════════════════════

  Widget _buildPersonalizationSection(
    bool isDark,
    Color surfaceColor,
    Color textColor,
    Color secondaryText,
    Color accent,
    String lang,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surfaceColor,
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
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.palette_outlined, color: accent, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lang == 'ar' ? 'لون الهوية المميز' : 'Couleur du profil',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                      ),
                    ),
                    Text(
                      lang == 'ar'
                          ? 'يُحدد لون الإضاءة المحيطية وشارات الطفل في التطبيق'
                          : 'Personnalise l\'ambiance visuelle du profil',
                      style: TextStyle(fontSize: 11, color: secondaryText),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Palette Row
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: _kChildPalette.map((p) {
              final isSelected = p.hex.toLowerCase() == _themeColorHex.toLowerCase();
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _themeColorHex = p.hex);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? p.color.withValues(alpha: 0.16) : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? p.color : (isDark ? Colors.white12 : const Color(0xFFE8DFE5)),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: p.color,
                          shape: BoxShape.circle,
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, size: 12, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        lang == 'ar' ? p.nameAr : p.nameFr,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected ? p.color : textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  // Section 4: Health & Medical Notes
  // ═════════════════════════════════════════════════════════════════════════

  Widget _buildHealthSection(
    bool isDark,
    Color surfaceColor,
    Color textColor,
    Color secondaryText,
    Color accent,
    String lang,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surfaceColor,
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
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFF00C853).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.favorite_border_rounded, color: Color(0xFF00C853), size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                lang == 'ar' ? 'السجل الصحي والملاحظات' : 'Santé & Notes médicales',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Blood Type Selector
          Text(
            lang == 'ar' ? 'فصيلة الدم' : 'Groupe sanguin',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: secondaryText),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: _kBloodTypes.map((bt) {
                final isSelected = _bloodType == bt;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _bloodType = isSelected ? null : bt);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF00C853)
                            : (isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF7F5F7)),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF00C853)
                              : (isDark ? Colors.white12 : const Color(0xFFE8DFE5)),
                        ),
                      ),
                      child: Text(
                        bt,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: isSelected ? Colors.white : textColor,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          // Notes / Allergies Input
          Text(
            lang == 'ar'
                ? 'ملاحظات طبية خاصة أو حساسية (اختياري)'
                : 'Allergies ou remarques médicales (facultatif)',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: secondaryText),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _notesController,
            maxLines: 3,
            style: TextStyle(fontSize: 13.5, color: textColor),
            decoration: InputDecoration(
              hintText: lang == 'ar'
                  ? 'مثال: حساسية من حليب البقر، ربو خفيف، تطعيمات خاصة...'
                  : 'Ex: Allergie au lactose, asthme léger...',
              filled: true,
              fillColor: isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFFBF8FA),
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: isDark ? Colors.white12 : const Color(0xFFE8DFE5)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: isDark ? Colors.white12 : const Color(0xFFE8DFE5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: accent, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  // Section 5: Danger Zone
  // ═════════════════════════════════════════════════════════════════════════

  Widget _buildDangerZoneSection(bool isDark, Color surfaceColor, String lang) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.delete_forever_rounded, color: AppColors.error, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                lang == 'ar' ? 'حذف ملف الطفل' : 'Supprimer le profil',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            lang == 'ar'
                ? 'سيتم حذف ملف الطفل نهائياً مع كافة السجلات والقياسات والذكريات المرتبطة به.'
                : 'La suppression effacera définitivement toutes les données associées.',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: _isDeleting ? null : _confirmDelete,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.error),
              ),
              child: Center(
                child: _isDeleting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.error),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.error),
                          const SizedBox(width: 8),
                          Text(
                            lang == 'ar' ? 'حذف ملف الطفل نهائياً' : 'Supprimer définitivement',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatAge(DateTime date, String lang) {
    final now = DateTime.now();
    int years = now.year - date.year;
    int months = now.month - date.month;
    if (now.day < date.day) months--;
    if (months < 0) {
      years--;
      months += 12;
    }
    if (years > 0) {
      return lang == 'ar'
          ? '$years سنة و $months شهر'
          : '$years an${years > 1 ? 's' : ''} et $months mois';
    }
    return lang == 'ar' ? '$months شهر' : '$months mois';
  }
}

class _GenderOptionCard extends StatelessWidget {
  const _GenderOptionCard({
    required this.title,
    required this.icon,
    required this.badgeText,
    required this.isSelected,
    required this.activeColor,
    required this.isDark,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final String badgeText;
  final bool isSelected;
  final Color activeColor;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.12)
              : (isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFFBF8FA)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? activeColor : (isDark ? Colors.white12 : const Color(0xFFE8DFE5)),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? activeColor : (isDark ? Colors.white70 : Colors.black54),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? activeColor : (isDark ? Colors.white : Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoOptionChip extends StatelessWidget {
  const _PhotoOptionChip({
    required this.icon,
    required this.label,
    required this.textColor,
    required this.isDark,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color textColor;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.white12 : const Color(0xFFE8E0E4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: textColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
