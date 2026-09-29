import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../core/extensions/l10n_extension.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/auth_logo_background.dart';
import '../../../shared/widgets/top_ambient_gradient.dart';
import 'models/profile_models.dart';
import 'providers/profile_providers.dart';

/// Complete list of the 58 Algerian Wilayas with code, French, and Arabic names.
const List<({int code, String fr, String ar})> _kAlgerianWilayas = [
  (code: 1, fr: 'Adrar', ar: 'أدرار'),
  (code: 2, fr: 'Chlef', ar: 'الشلف'),
  (code: 3, fr: 'Laghouat', ar: 'الأغواط'),
  (code: 4, fr: 'Oum El Bouaghi', ar: 'أم البواقي'),
  (code: 5, fr: 'Batna', ar: 'باتنة'),
  (code: 6, fr: 'Béjaïa', ar: 'بجاية'),
  (code: 7, fr: 'Biskra', ar: 'بسكرة'),
  (code: 8, fr: 'Béchar', ar: 'بشار'),
  (code: 9, fr: 'Blida', ar: 'البليدة'),
  (code: 10, fr: 'Bouira', ar: 'البويرة'),
  (code: 11, fr: 'Tamanrasset', ar: 'تمنراست'),
  (code: 12, fr: 'Tébessa', ar: 'تبسة'),
  (code: 13, fr: 'Tlemcen', ar: 'تلمسان'),
  (code: 14, fr: 'Tiaret', ar: 'تيارت'),
  (code: 15, fr: 'Tizi Ouzou', ar: 'تيزي وزو'),
  (code: 16, fr: 'Alger', ar: 'الجزائر'),
  (code: 17, fr: 'Djelfa', ar: 'الجلفة'),
  (code: 18, fr: 'Jijel', ar: 'جيجل'),
  (code: 19, fr: 'Sétif', ar: 'سطيف'),
  (code: 20, fr: 'Saïda', ar: 'سعيدة'),
  (code: 21, fr: 'Skikda', ar: 'سكيكدة'),
  (code: 22, fr: 'Sidi Bel Abbès', ar: 'سيدي بلعباس'),
  (code: 23, fr: 'Annaba', ar: 'عنابة'),
  (code: 24, fr: 'Guelma', ar: 'قالمة'),
  (code: 25, fr: 'Constantine', ar: 'قسنطينة'),
  (code: 26, fr: 'Médéa', ar: 'المدية'),
  (code: 27, fr: 'Mostaganem', ar: 'مستغانم'),
  (code: 28, fr: 'M\'Sila', ar: 'المسيلة'),
  (code: 29, fr: 'Mascara', ar: 'معسكر'),
  (code: 30, fr: 'Ouargla', ar: 'ورقلة'),
  (code: 31, fr: 'Oran', ar: 'وهران'),
  (code: 32, fr: 'El Bayadh', ar: 'البيض'),
  (code: 33, fr: 'Illizi', ar: 'إليزي'),
  (code: 34, fr: 'Bordj Bou Arréridj', ar: 'برج بوعريريج'),
  (code: 35, fr: 'Boumerdès', ar: 'بومرداس'),
  (code: 36, fr: 'El Tarf', ar: 'الطارف'),
  (code: 37, fr: 'Tindouf', ar: 'تندوف'),
  (code: 38, fr: 'Tissemsilt', ar: 'تيسمسيلت'),
  (code: 39, fr: 'El Oued', ar: 'الوادي'),
  (code: 40, fr: 'Khenchela', ar: 'خنشلة'),
  (code: 41, fr: 'Souk Ahras', ar: 'سوق أهراس'),
  (code: 42, fr: 'Tipaza', ar: 'تيبازة'),
  (code: 43, fr: 'Mila', ar: 'ميلة'),
  (code: 44, fr: 'Aïn Defla', ar: 'عين الدفلى'),
  (code: 45, fr: 'Naâma', ar: 'النعامة'),
  (code: 46, fr: 'Aïn Témouchent', ar: 'عين تموشنت'),
  (code: 47, fr: 'Ghardaïa', ar: 'غرداية'),
  (code: 48, fr: 'Relizane', ar: 'غليزان'),
  (code: 49, fr: 'Timimoun', ar: 'تيميمون'),
  (code: 50, fr: 'Bordj Badji Mokhtar', ar: 'برج باجي مختار'),
  (code: 51, fr: 'Ouled Djellal', ar: 'أولاد جلال'),
  (code: 52, fr: 'Béni Abbès', ar: 'بني عباس'),
  (code: 53, fr: 'In Salah', ar: 'عين صالح'),
  (code: 54, fr: 'In Guezzam', ar: 'عين قزام'),
  (code: 55, fr: 'Touggourt', ar: 'تقرت'),
  (code: 56, fr: 'Djanet', ar: 'جانت'),
  (code: 57, fr: 'El M\'Ghair', ar: 'المغير'),
  (code: 58, fr: 'El Menia', ar: 'المنيعة'),
];

const List<String> _kBloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

const List<({String ar, String fr})> _kCommonAllergies = [
  (ar: 'البنسلين', fr: 'Pénicilline'),
  (ar: 'الغلوتين', fr: 'Gluten'),
  (ar: 'الفول السوداني', fr: 'Arachides'),
  (ar: 'الأسبرين', fr: 'Aspirine'),
  (ar: 'اللاكتوز', fr: 'Lactose'),
];

/// Flagship Full-Page Screen for editing the Mother's Profile.
/// Provides a comprehensive Bento layout replacing legacy cramped dialogs:
/// - Avatar photo management (Camera, Gallery, Remove)
/// - Personal information (Full name, Birth date & age, Phone, 58 Algerian Wilayas)
/// - Life stage & Maternal Status (Mom, Pregnant with week tracker, Hope/Planning)
/// - Medical vitals (Blood type, Allergies tag chips, Chronic conditions, Attending Doctor)
class EditMotherProfileScreen extends ConsumerStatefulWidget {
  const EditMotherProfileScreen({super.key, this.profile});

  final UserProfile? profile;

  @override
  ConsumerState<EditMotherProfileScreen> createState() => _EditMotherProfileScreenState();
}

class _EditMotherProfileScreenState extends ConsumerState<EditMotherProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _allergyInputController;
  late final TextEditingController _conditionsController;
  late final TextEditingController _doctorNameController;
  late final TextEditingController _doctorPhoneController;

  DateTime? _birthDate;
  String? _wilaya;
  late UserStatus _status;
  DateTime? _pregnancyDate;
  String? _bloodType;
  late List<String> _allergies;

  File? _newImageFile;
  bool _removePhoto = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    final fbUser = AuthService().currentUser;

    _nameController = TextEditingController(text: p?.displayName ?? fbUser?.displayName ?? '');
    _phoneController = TextEditingController(text: p?.phone ?? '');
    _allergyInputController = TextEditingController();
    _conditionsController = TextEditingController(text: p?.medicalInfo.conditions.join(', ') ?? '');
    _doctorNameController = TextEditingController(text: p?.medicalInfo.doctorName ?? '');
    _doctorPhoneController = TextEditingController(text: p?.medicalInfo.doctorPhone ?? '');

    _birthDate = p?.birthDate;
    _wilaya = p?.wilaya;
    _status = p?.status ?? UserStatus.mom;
    _pregnancyDate = p?.lastPregnancyDate;
    _bloodType = p?.medicalInfo.bloodType;
    _allergies = List<String>.from(p?.medicalInfo.allergies ?? []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _allergyInputController.dispose();
    _conditionsController.dispose();
    _doctorNameController.dispose();
    _doctorPhoneController.dispose();
    super.dispose();
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
          SnackBar(
            content: Text(context.l10n.errorWithMessage(e.toString())),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _addAllergy(String allergy) {
    final clean = allergy.trim();
    if (clean.isNotEmpty && !_allergies.contains(clean)) {
      setState(() {
        _allergies.add(clean);
        _allergyInputController.clear();
      });
    }
  }

  void _removeAllergy(String allergy) {
    setState(() {
      _allergies.remove(allergy);
    });
  }

  List<String> _parseConditions() {
    return _conditionsController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            Localizations.localeOf(context).languageCode == 'ar'
                ? 'يرجى إدخال اسمكِ الكريم'
                : 'Veuillez saisir votre nom',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    HapticFeedback.mediumImpact();

    try {
      final medicalInfo = MedicalInfo(
        bloodType: _bloodType,
        allergies: _allergies,
        conditions: _parseConditions(),
        doctorName: _doctorNameController.text.trim().isNotEmpty
            ? _doctorNameController.text.trim()
            : null,
        doctorPhone: _doctorPhoneController.text.trim().isNotEmpty
            ? _doctorPhoneController.text.trim()
            : null,
      );

      await ref.read(profileActionsProvider.notifier).updateFullProfile(
            displayName: name,
            phone: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
            birthDate: _birthDate,
            wilaya: _wilaya,
            newPhotoFile: _newImageFile,
            removePhoto: _removePhoto,
            status: _status,
            pregnancyDate: _pregnancyDate,
            medicalInfo: medicalInfo,
          );

      if (mounted) {
        HapticFeedback.lightImpact();
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              Localizations.localeOf(context).languageCode == 'ar'
                  ? 'تم حفظ وتحديث ملفكِ الشخصي بنجاح 💖'
                  : 'Votre profil a été mis à jour avec succès ✨',
            ),
            backgroundColor: const Color(0xFF00C853),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.errorWithMessage(e.toString())),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = Localizations.localeOf(context);
    final lang = locale.languageCode;
    final isRtl = lang == 'ar';

    final bgColor = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final surfaceColor = isDark ? const Color(0xFF221A24) : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.onSurfaceLight;
    final secondaryText = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final accent = isDark ? AppColors.primaryDark : AppColors.primaryLight;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // ── 1. Top Atmospheric Ambient Glow ──
          const TopAmbientGradient(height: 340),

          // ── 2. Subtle Watermark Logo ──
          const AuthLogoBackground(lightOpacity: 0.05, darkOpacity: 0.03),

          // ── 3. Main Screen Flow ──
          Positioned.fill(
            child: SafeArea(
              bottom: false,
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
                                lang == 'ar' ? 'الملف الشخصي للأم' : 'Profil de la Maman',
                                style: AppTypography.fromContext(
                                  context,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                lang == 'ar' ? 'المعلومات الشخصية والطبية' : 'Informations personnelles & médicales',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: secondaryText,
                                ),
                              ),
                            ],
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

                          // ── 2. Personal Information Bento ──
                          _buildPersonalInfoSection(isDark, surfaceColor, textColor, secondaryText, accent, lang),

                          const SizedBox(height: 18),

                          // ── 3. Life Stage & Maternal Status Bento ──
                          _buildStatusSection(isDark, surfaceColor, textColor, secondaryText, accent, lang),

                          const SizedBox(height: 18),

                          // ── 4. Medical & Health Vitals Bento ──
                          _buildMedicalSection(isDark, surfaceColor, textColor, secondaryText, accent, lang),

                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: bgColor,
        padding: EdgeInsets.fromLTRB(
          AppSpacing.screenPaddingH,
          8,
          AppSpacing.screenPaddingH,
          MediaQuery.of(context).padding.bottom + 12,
        ),
        child: SizedBox(
          height: 52,
          child: GestureDetector(
            onTap: _isSaving ? null : _saveProfile,
            child: Container(
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isSaving)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                    )
                  else ...[
                    const Icon(Icons.check_circle_rounded, size: 20, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      lang == 'ar' ? 'حفظ بيانات الملف الشخصي' : 'Enregistrer les modifications',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ],
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
    final fbUser = AuthService().currentUser;
    final currentPhotoUrl = widget.profile?.photoUrl ?? fbUser?.photoURL;

    ImageProvider? imageProvider;
    if (_newImageFile != null) {
      imageProvider = FileImage(_newImageFile!);
    } else if (!_removePhoto && currentPhotoUrl != null && currentPhotoUrl.isNotEmpty) {
      imageProvider = CachedNetworkImageProvider(currentPhotoUrl);
    }

    final hasPhoto = imageProvider != null;

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
                  child: hasPhoto
                      ? Image(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                accent.withValues(alpha: 0.18),
                                accent.withValues(alpha: 0.08),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.face_3_rounded,
                              size: 52,
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
              _MotherPhotoChip(
                icon: Icons.photo_camera_rounded,
                label: lang == 'ar' ? 'كاميرا' : 'Caméra',
                textColor: textColor,
                isDark: isDark,
                onTap: () => _pickImage(ImageSource.camera),
              ),
              const SizedBox(width: 10),
              _MotherPhotoChip(
                icon: Icons.photo_library_rounded,
                label: lang == 'ar' ? 'المعرض' : 'Galerie',
                textColor: textColor,
                isDark: isDark,
                onTap: () => _pickImage(ImageSource.gallery),
              ),
              if (hasPhoto) ...[
                const SizedBox(width: 10),
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
  // Section 2: Personal Information Bento
  // ═════════════════════════════════════════════════════════════════════════

  Widget _buildPersonalInfoSection(
    bool isDark,
    Color surfaceColor,
    Color textColor,
    Color secondaryText,
    Color accent,
    String lang,
  ) {
    String ageText = '';
    if (_birthDate != null) {
      final now = DateTime.now();
      int age = now.year - _birthDate!.year;
      if (now.month < _birthDate!.month || (now.month == _birthDate!.month && now.day < _birthDate!.day)) {
        age--;
      }
      ageText = lang == 'ar' ? '$age سنة' : '$age ans';
    }

    return _MotherBentoCard(
      surfaceColor: surfaceColor,
      isDark: isDark,
      title: lang == 'ar' ? 'المعلومات الشخصية' : 'Informations personnelles',
      icon: Icons.person_rounded,
      accentColor: accent,
      textColor: textColor,
      secondaryText: secondaryText,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name Field
          _buildInputField(
            controller: _nameController,
            label: lang == 'ar' ? 'الاسم الكامل' : 'Nom complet',
            hint: lang == 'ar' ? 'مثال: سارة بن علي' : 'Ex: Sarah Benali',
            icon: Icons.badge_outlined,
            isDark: isDark,
            textColor: textColor,
            secondaryText: secondaryText,
            accent: accent,
          ),

          const SizedBox(height: 14),

          // Date of Birth Field
          Text(
            lang == 'ar' ? 'تاريخ الميلاد' : 'Date de naissance',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: secondaryText,
            ),
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: _pickBirthDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF9F7F8),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? Colors.white12 : const Color(0xFFECE4E8),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.cake_outlined, size: 20, color: accent),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _birthDate != null
                          ? DateFormat('dd MMMM yyyy', lang == 'ar' ? 'ar' : 'fr').format(_birthDate!)
                          : (lang == 'ar' ? 'حددي تاريخ ميلادكِ' : 'Sélectionnez votre date de naissance'),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _birthDate != null ? textColor : secondaryText,
                      ),
                    ),
                  ),
                  if (ageText.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        ageText,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: accent,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Phone Field
          _buildInputField(
            controller: _phoneController,
            label: lang == 'ar' ? 'رقم الهاتف' : 'Numéro de téléphone',
            hint: lang == 'ar' ? '05 / 06 / 07 XX XX XX XX' : '05 / 06 / 07 XX XX XX XX',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            isDark: isDark,
            textColor: textColor,
            secondaryText: secondaryText,
            accent: accent,
          ),

          const SizedBox(height: 14),

          // Algerian Wilaya Dropdown
          Text(
            lang == 'ar' ? 'الولاية' : 'Wilaya',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: secondaryText,
            ),
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () => _showWilayaPicker(isDark, surfaceColor, textColor, secondaryText, accent, lang),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF9F7F8),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? Colors.white12 : const Color(0xFFECE4E8),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 20, color: accent),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _wilaya != null && _wilaya!.isNotEmpty
                          ? _wilaya!
                          : (lang == 'ar' ? 'اختاري ولايتكِ' : 'Sélectionnez votre wilaya'),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _wilaya != null && _wilaya!.isNotEmpty ? textColor : secondaryText,
                      ),
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: secondaryText),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  // Section 3: Life Stage & Maternal Status Bento
  // ═════════════════════════════════════════════════════════════════════════

  Widget _buildStatusSection(
    bool isDark,
    Color surfaceColor,
    Color textColor,
    Color secondaryText,
    Color accent,
    String lang,
  ) {
    return _MotherBentoCard(
      surfaceColor: surfaceColor,
      isDark: isDark,
      title: lang == 'ar' ? 'حالة الأم الحالية' : 'Votre statut actuel',
      icon: Icons.favorite_rounded,
      accentColor: const Color(0xFFE91E63),
      textColor: textColor,
      secondaryText: secondaryText,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildStatusOption(
                status: UserStatus.mom,
                label: lang == 'ar' ? 'أم' : 'Maman',
                icon: Icons.child_friendly_rounded,
                color: const Color(0xFF00C853),
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              _buildStatusOption(
                status: UserStatus.pregnant,
                label: lang == 'ar' ? 'حامل' : 'Enceinte',
                icon: Icons.pregnant_woman_rounded,
                color: const Color(0xFFE91E63),
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              _buildStatusOption(
                status: UserStatus.hope,
                label: lang == 'ar' ? 'تخطط للحمل' : 'En espoir',
                icon: Icons.favorite_border_rounded,
                color: const Color(0xFFFF9100),
                isDark: isDark,
              ),
            ],
          ),

          // If Pregnant, show LMP / Due Date Picker
          if (_status == UserStatus.pregnant) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE91E63).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFE91E63).withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.event_note_rounded, size: 18, color: Color(0xFFE91E63)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          lang == 'ar' ? 'تاريخ آخر دورة شهرية (DDR)' : 'Date des Dernières Règles (DDR)',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFE91E63),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _pickPregnancyDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFFE91E63).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _pregnancyDate != null
                                  ? DateFormat('dd MMMM yyyy', lang == 'ar' ? 'ar' : 'fr').format(_pregnancyDate!)
                                  : (lang == 'ar' ? 'اضغطي لتحديد التاريخ' : 'Sélectionner la date'),
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                          ),
                          const Icon(Icons.calendar_month_rounded, size: 18, color: Color(0xFFE91E63)),
                        ],
                      ),
                    ),
                  ),
                  if (_pregnancyDate != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _calculatePregnancyWeek(lang),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: secondaryText,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusOption({
    required UserStatus status,
    required String label,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    final isSelected = _status == status;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _status = status);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? color : (isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF9F7F8)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : (isDark ? Colors.white12 : const Color(0xFFECE4E8)),
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  // Section 4: Medical & Health Vitals Bento
  // ═════════════════════════════════════════════════════════════════════════

  Widget _buildMedicalSection(
    bool isDark,
    Color surfaceColor,
    Color textColor,
    Color secondaryText,
    Color accent,
    String lang,
  ) {
    return _MotherBentoCard(
      surfaceColor: surfaceColor,
      isDark: isDark,
      title: lang == 'ar' ? 'السجل الطبي والصحي' : 'Dossier médical & santé',
      icon: Icons.medical_services_rounded,
      accentColor: const Color(0xFF00B0FF),
      textColor: textColor,
      secondaryText: secondaryText,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Blood Type Header
          Text(
            lang == 'ar' ? 'فصيلة الدم' : 'Groupe sanguin',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: secondaryText,
            ),
          ),
          const SizedBox(height: 8),

          // Blood Type Pills
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _kBloodTypes.map((type) {
              final isSelected = _bloodType == type;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _bloodType = isSelected ? null : type;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF00B0FF)
                        : (isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF9F7F8)),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF00B0FF)
                          : (isDark ? Colors.white12 : const Color(0xFFECE4E8)),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Text(
                    type,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : textColor,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 18),

          // Allergies Section
          Text(
            lang == 'ar' ? 'الحساسية (Allergies)' : 'Allergies connues',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: secondaryText,
            ),
          ),
          const SizedBox(height: 6),

          // Allergy input row
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF9F7F8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? Colors.white12 : const Color(0xFFECE4E8),
                    ),
                  ),
                  child: TextField(
                    controller: _allergyInputController,
                    onSubmitted: _addAllergy,
                    style: TextStyle(fontSize: 13.5, color: textColor),
                    decoration: InputDecoration(
                      hintText: lang == 'ar' ? 'أضيفي حساسية (مثال: البنسلين)' : 'Ex: Pénicilline',
                      hintStyle: TextStyle(fontSize: 12.5, color: secondaryText.withValues(alpha: 0.7)),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _addAllergy(_allergyInputController.text),
                child: Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.add_rounded, size: 22, color: Colors.white),
                ),
              ),
            ],
          ),

          // Common suggestion chips
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _kCommonAllergies.map((item) {
              final label = lang == 'ar' ? item.ar : item.fr;
              final alreadyAdded = _allergies.contains(label);
              if (alreadyAdded) return const SizedBox.shrink();
              return GestureDetector(
                onTap: () => _addAllergy(label),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark ? Colors.white10 : Colors.black12,
                    ),
                  ),
                  child: Text(
                    '+ $label',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: secondaryText,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          // Active Allergy Chips
          if (_allergies.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _allergies.map((allergy) {
                return Chip(
                  backgroundColor: AppColors.error.withValues(alpha: 0.1),
                  side: BorderSide(color: AppColors.error.withValues(alpha: 0.3)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  label: Text(
                    allergy,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.error,
                    ),
                  ),
                  deleteIcon: const Icon(Icons.close_rounded, size: 14, color: AppColors.error),
                  onDeleted: () => _removeAllergy(allergy),
                );
              }).toList(),
            ),
          ],

          const SizedBox(height: 18),

          // Chronic conditions / notes
          _buildInputField(
            controller: _conditionsController,
            label: lang == 'ar' ? 'حالات صحية أو أمراض مزمنة' : 'Conditions médicales ou maladies chroniques',
            hint: lang == 'ar' ? 'مثال: السكري، ضغط الدم، فقر الدم' : 'Ex: Diabète, Asthme, Hypertension',
            icon: Icons.healing_outlined,
            isDark: isDark,
            textColor: textColor,
            secondaryText: secondaryText,
            accent: accent,
          ),

          const SizedBox(height: 18),

          // Attending Doctor Details
          Text(
            lang == 'ar' ? 'الطبيب المتابع' : 'Médecin traitant',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: secondaryText,
            ),
          ),
          const SizedBox(height: 8),

          _buildInputField(
            controller: _doctorNameController,
            label: lang == 'ar' ? 'اسم الطبيب' : 'Nom du médecin',
            hint: lang == 'ar' ? 'د. فلان بن فلان' : 'Dr. Martin',
            icon: Icons.person_search_outlined,
            isDark: isDark,
            textColor: textColor,
            secondaryText: secondaryText,
            accent: accent,
          ),
          const SizedBox(height: 10),
          _buildInputField(
            controller: _doctorPhoneController,
            label: lang == 'ar' ? 'هاتف الطبيب' : 'Téléphone du médecin',
            hint: lang == 'ar' ? '05 / 06 / 07 XX XX XX XX' : 'Numéro du médecin',
            icon: Icons.phone_forwarded_outlined,
            keyboardType: TextInputType.phone,
            isDark: isDark,
            textColor: textColor,
            secondaryText: secondaryText,
            accent: accent,
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  // Helper Modals & Pickers
  // ═════════════════════════════════════════════════════════════════════════

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 28, now.month, now.day),
      firstDate: DateTime(1950),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primaryLight,
              primary: AppColors.primaryLight,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  Future<void> _pickPregnancyDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _pregnancyDate ?? now.subtract(const Duration(days: 70)),
      firstDate: now.subtract(const Duration(days: 280)),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFE91E63),
              primary: const Color(0xFFE91E63),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _pregnancyDate = picked);
    }
  }

  String _calculatePregnancyWeek(String lang) {
    if (_pregnancyDate == null) return '';
    final days = DateTime.now().difference(_pregnancyDate!).inDays;
    final weeks = (days / 7).floor();
    final remainingDays = days % 7;
    if (lang == 'ar') {
      return 'أنتِ حالياً في الأسبوع $weeks و $remainingDays أيام من الحمل 🌸';
    } else {
      return 'Vous êtes actuellement à $weeks semaines et $remainingDays jours de grossesse 🌸';
    }
  }

  void _showWilayaPicker(
    bool isDark,
    Color surfaceColor,
    Color textColor,
    Color secondaryText,
    Color accent,
    String lang,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: surfaceColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return _WilayaSelectorSheet(
          isDark: isDark,
          textColor: textColor,
          secondaryText: secondaryText,
          accent: accent,
          lang: lang,
          selectedWilaya: _wilaya,
          onSelect: (selected) {
            setState(() => _wilaya = selected);
            Navigator.pop(context);
          },
        );
      },
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDark,
    required Color textColor,
    required Color secondaryText,
    required Color accent,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: secondaryText,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF9F7F8),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? Colors.white12 : const Color(0xFFECE4E8),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: accent),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: TextStyle(
                      fontSize: 13,
                      color: secondaryText.withValues(alpha: 0.7),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// Reusable Bento & Supporting Widgets
// ══════════════════════════════════════════════════════════════════════════

class _MotherBentoCard extends StatelessWidget {
  const _MotherBentoCard({
    required this.surfaceColor,
    required this.isDark,
    required this.title,
    required this.icon,
    required this.accentColor,
    required this.textColor,
    required this.secondaryText,
    required this.child,
  });

  final Color surfaceColor;
  final bool isDark;
  final String title;
  final IconData icon;
  final Color accentColor;
  final Color textColor;
  final Color secondaryText;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFECE4E8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: accentColor),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _MotherPhotoChip extends StatelessWidget {
  const _MotherPhotoChip({
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
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.white12 : const Color(0xFFE8E0E4),
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: textColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
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

class _WilayaSelectorSheet extends StatefulWidget {
  const _WilayaSelectorSheet({
    required this.isDark,
    required this.textColor,
    required this.secondaryText,
    required this.accent,
    required this.lang,
    required this.selectedWilaya,
    required this.onSelect,
  });

  final bool isDark;
  final Color textColor;
  final Color secondaryText;
  final Color accent;
  final String lang;
  final String? selectedWilaya;
  final ValueChanged<String> onSelect;

  @override
  State<_WilayaSelectorSheet> createState() => _WilayaSelectorSheetState();
}

class _WilayaSelectorSheetState extends State<_WilayaSelectorSheet> {
  final TextEditingController _searchCtrl = TextEditingController();
  List<({int code, String fr, String ar})> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = _kAlgerianWilayas;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    final q = query.trim().toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _filtered = _kAlgerianWilayas;
      } else {
        _filtered = _kAlgerianWilayas.where((w) {
          final codeStr = w.code.toString();
          return codeStr.contains(q) ||
              w.fr.toLowerCase().contains(q) ||
              w.ar.contains(q);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isAr = widget.lang == 'ar';

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: [
          // Drag handle
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: widget.isDark ? Colors.white24 : Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 14),

          // Header
          Row(
            children: [
              Icon(Icons.location_city_rounded, color: widget.accent, size: 22),
              const SizedBox(width: 8),
              Text(
                isAr ? 'اختيار الولاية (58 ولاية)' : 'Sélectionner la wilaya (58)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: widget.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Search Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: widget.isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFF4F0F2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.search_rounded, size: 18, color: widget.secondaryText),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: _onSearch,
                    style: TextStyle(fontSize: 13.5, color: widget.textColor),
                    decoration: InputDecoration(
                      hintText: isAr ? 'ابحث باسم الولاية أو رقمها...' : 'Rechercher par nom ou code...',
                      hintStyle: TextStyle(fontSize: 12.5, color: widget.secondaryText),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Wilayas List
          Expanded(
            child: ListView.separated(
              itemCount: _filtered.length,
              separatorBuilder: (_, _) => Divider(
                height: 1,
                color: widget.isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
              ),
              itemBuilder: (context, index) {
                final item = _filtered[index];
                final codeFormatted = item.code.toString().padLeft(2, '0');
                final displayText = isAr ? '$codeFormatted - ${item.ar} (${item.fr})' : '$codeFormatted - ${item.fr} (${item.ar})';
                final isSelected = widget.selectedWilaya == displayText || widget.selectedWilaya == item.fr || widget.selectedWilaya == item.ar;

                return ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  leading: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isSelected ? widget.accent : (widget.isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.04)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        codeFormatted,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? Colors.white : widget.textColor,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    isAr ? item.ar : item.fr,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected ? widget.accent : widget.textColor,
                    ),
                  ),
                  subtitle: Text(
                    isAr ? item.fr : item.ar,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: widget.secondaryText,
                    ),
                  ),
                  trailing: isSelected ? Icon(Icons.check_circle_rounded, color: widget.accent, size: 20) : null,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    widget.onSelect(isAr ? '${item.ar} ($codeFormatted)' : '${item.fr} ($codeFormatted)');
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
