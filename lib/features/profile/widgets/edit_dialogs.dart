import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../models/profile_models.dart';

/// Wilayas d'Algérie pour le dropdown.
const List<String> algerianWilayas = [
  'Adrar',
  'Chlef',
  'Laghouat',
  'Oum El Bouaghi',
  'Batna',
  'Béjaïa',
  'Biskra',
  'Béchar',
  'Blida',
  'Bouira',
  'Tamanrasset',
  'Tébessa',
  'Tlemcen',
  'Tiaret',
  'Tizi Ouzou',
  'Alger',
  'Djelfa',
  'Jijel',
  'Sétif',
  'Saïda',
  'Skikda',
  'Sidi Bel Abbès',
  'Annaba',
  'Guelma',
  'Constantine',
  'Médéa',
  'Mostaganem',
  'M\'Sila',
  'Mascara',
  'Ouargla',
  'Oran',
  'El Bayadh',
  'Illizi',
  'Bordj Bou Arréridj',
  'Boumerdès',
  'El Tarf',
  'Tindouf',
  'Tissemsilt',
  'El Oued',
  'Khenchela',
  'Souk Ahras',
  'Tipaza',
  'Mila',
  'Aïn Defla',
  'Naâma',
  'Aïn Témouchent',
  'Ghardaïa',
  'Relizane',
];

/// Blood types for dropdown.
const List<String> bloodTypes = [
  'A+',
  'A-',
  'B+',
  'B-',
  'AB+',
  'AB-',
  'O+',
  'O-',
];

/// Dialog to edit personal information.
class EditPersonalInfoDialog extends StatefulWidget {
  const EditPersonalInfoDialog({
    super.key,
    required this.profile,
    required this.onSave,
  });

  final UserProfile? profile;
  final Future<void> Function({
    String? displayName,
    String? phone,
    DateTime? birthDate,
    String? wilaya,
  })
  onSave;

  @override
  State<EditPersonalInfoDialog> createState() => _EditPersonalInfoDialogState();
}

class _EditPersonalInfoDialogState extends State<EditPersonalInfoDialog> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  DateTime? _birthDate;
  String? _selectedWilaya;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.profile?.displayName ?? '',
    );
    _phoneController = TextEditingController(text: widget.profile?.phone ?? '');
    _birthDate = widget.profile?.birthDate;
    _selectedWilaya = widget.profile?.wilaya;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(1990),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    try {
      await widget.onSave(
        displayName: _nameController.text.isNotEmpty
            ? _nameController.text
            : null,
        phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
        birthDate: _birthDate,
        wilaya: _selectedWilaya,
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark
        ? AppColors.primaryDark
        : AppColors.primaryLight;
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Modifier mes informations',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Name
              _buildTextField(
                controller: _nameController,
                label: 'Nom complet',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: AppSpacing.md),

              // Phone
              _buildTextField(
                controller: _phoneController,
                label: 'Téléphone',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: AppSpacing.md),

              // Birth date
              GestureDetector(
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.cake_outlined, color: Colors.grey.shade600),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _birthDate != null
                              ? dateFormat.format(_birthDate!)
                              : 'Date de naissance',
                          style: GoogleFonts.outfit(
                            color: _birthDate != null
                                ? null
                                : Colors.grey.shade600,
                          ),
                        ),
                      ),
                      Icon(Icons.calendar_today, size: 18, color: primaryColor),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Wilaya dropdown
              DropdownButtonFormField<String>(
                value: _selectedWilaya,
                decoration: InputDecoration(
                  labelText: 'Wilaya',
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: algerianWilayas
                    .map((w) => DropdownMenuItem(value: w, child: Text(w)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedWilaya = value),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.pop(context),
                      child: const Text('Annuler'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Enregistrer'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

/// Dialog to edit medical information.
class EditMedicalInfoDialog extends StatefulWidget {
  const EditMedicalInfoDialog({
    super.key,
    required this.medicalInfo,
    required this.onSave,
  });

  final MedicalInfo medicalInfo;
  final Future<void> Function(MedicalInfo) onSave;

  @override
  State<EditMedicalInfoDialog> createState() => _EditMedicalInfoDialogState();
}

class _EditMedicalInfoDialogState extends State<EditMedicalInfoDialog> {
  late String? _bloodType;
  late TextEditingController _allergiesController;
  late TextEditingController _conditionsController;
  late TextEditingController _doctorNameController;
  late TextEditingController _doctorPhoneController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _bloodType = widget.medicalInfo.bloodType;
    _allergiesController = TextEditingController(
      text: widget.medicalInfo.allergies.join(', '),
    );
    _conditionsController = TextEditingController(
      text: widget.medicalInfo.conditions.join(', '),
    );
    _doctorNameController = TextEditingController(
      text: widget.medicalInfo.doctorName ?? '',
    );
    _doctorPhoneController = TextEditingController(
      text: widget.medicalInfo.doctorPhone ?? '',
    );
  }

  @override
  void dispose() {
    _allergiesController.dispose();
    _conditionsController.dispose();
    _doctorNameController.dispose();
    _doctorPhoneController.dispose();
    super.dispose();
  }

  List<String> _parseList(String text) {
    return text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    try {
      final info = MedicalInfo(
        bloodType: _bloodType,
        allergies: _parseList(_allergiesController.text),
        conditions: _parseList(_conditionsController.text),
        doctorName: _doctorNameController.text.isNotEmpty
            ? _doctorNameController.text
            : null,
        doctorPhone: _doctorPhoneController.text.isNotEmpty
            ? _doctorPhoneController.text
            : null,
      );
      await widget.onSave(info);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark
        ? AppColors.primaryDark
        : AppColors.primaryLight;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Informations médicales',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Blood type
              DropdownButtonFormField<String>(
                value: _bloodType,
                decoration: InputDecoration(
                  labelText: 'Groupe sanguin',
                  prefixIcon: const Icon(Icons.water_drop_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: bloodTypes
                    .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                    .toList(),
                onChanged: (value) => setState(() => _bloodType = value),
              ),
              const SizedBox(height: AppSpacing.md),

              // Allergies
              TextField(
                controller: _allergiesController,
                decoration: InputDecoration(
                  labelText: 'Allergies (séparées par virgule)',
                  prefixIcon: const Icon(Icons.warning_amber_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Conditions
              TextField(
                controller: _conditionsController,
                decoration: InputDecoration(
                  labelText: 'Conditions médicales (séparées par virgule)',
                  prefixIcon: const Icon(Icons.health_and_safety_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Doctor name
              TextField(
                controller: _doctorNameController,
                decoration: InputDecoration(
                  labelText: 'Nom du médecin',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Doctor phone
              TextField(
                controller: _doctorPhoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Téléphone du médecin',
                  prefixIcon: const Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.pop(context),
                      child: const Text('Annuler'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Enregistrer'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dialog to add or edit a child.
class AddEditChildDialog extends StatefulWidget {
  const AddEditChildDialog({
    super.key,
    this.child,
    required this.onSave,
    this.onDelete,
  });

  final Child? child;
  final Future<void> Function(Child, {File? imageFile}) onSave;
  final Future<void> Function()? onDelete;

  @override
  State<AddEditChildDialog> createState() => _AddEditChildDialogState();
}

class _AddEditChildDialogState extends State<AddEditChildDialog> {
  late TextEditingController _nameController;
  DateTime? _birthDate;
  ChildGender _gender = ChildGender.girl;
  File? _imageFile;
  bool _isLoading = false;

  bool get isEditing => widget.child != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.child?.name ?? '');
    _birthDate = widget.child?.birthDate;
    _gender = widget.child?.gender ?? ChildGender.girl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 800,
    );

    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime.now(),
      firstDate: DateTime(2010),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  Future<void> _save() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Le nom est obligatoire')));
      return;
    }
    if (_birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La date de naissance est obligatoire')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final child = Child(
        id: widget.child?.id ?? '',
        name: _nameController.text,
        birthDate: _birthDate!,
        gender: _gender,
        photoUrl: widget.child?.photoUrl,
      );
      await widget.onSave(child, imageFile: _imageFile);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer cet enfant ?'),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true && widget.onDelete != null) {
      setState(() => _isLoading = true);
      try {
        await widget.onDelete!();
        if (mounted) Navigator.of(context).pop(true);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark
        ? AppColors.primaryDark
        : AppColors.primaryLight;
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditing ? 'Modifier enfant' : 'Ajouter un enfant',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Photo selection
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: primaryColor.withValues(alpha: 0.2),
                            width: 2,
                          ),
                          image: _imageFile != null
                              ? DecorationImage(
                                  image: FileImage(_imageFile!),
                                  fit: BoxFit.cover,
                                )
                              : (widget.child?.photoUrl != null
                                    ? DecorationImage(
                                        image: NetworkImage(
                                          widget.child!.photoUrl!,
                                        ),
                                        fit: BoxFit.cover,
                                      )
                                    : null),
                        ),
                        child:
                            _imageFile == null && widget.child?.photoUrl == null
                            ? Icon(
                                Icons.add_a_photo_outlined,
                                color: primaryColor,
                                size: 32,
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.edit_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Name
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Prénom',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Gender selector
              Row(
                children: [
                  Expanded(
                    child: _GenderOption(
                      gender: ChildGender.girl,
                      label: 'Fille',
                      icon: Icons.face_3_rounded,
                      color: Colors.pink,
                      isSelected: _gender == ChildGender.girl,
                      onTap: () => setState(() => _gender = ChildGender.girl),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _GenderOption(
                      gender: ChildGender.boy,
                      label: 'Garçon',
                      icon: Icons.face_rounded,
                      color: Colors.blue,
                      isSelected: _gender == ChildGender.boy,
                      onTap: () => setState(() => _gender = ChildGender.boy),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Birth date
              GestureDetector(
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.cake_outlined, color: Colors.grey.shade600),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _birthDate != null
                              ? dateFormat.format(_birthDate!)
                              : 'Date de naissance *',
                          style: GoogleFonts.outfit(
                            color: _birthDate != null
                                ? null
                                : Colors.grey.shade600,
                          ),
                        ),
                      ),
                      Icon(Icons.calendar_today, size: 18, color: primaryColor),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Buttons
              Row(
                children: [
                  if (isEditing && widget.onDelete != null)
                    IconButton(
                      onPressed: _isLoading ? null : _delete,
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                    ),
                  if (isEditing && widget.onDelete != null)
                    const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.pop(context),
                      child: const Text('Annuler'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(isEditing ? 'Modifier' : 'Ajouter'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GenderOption extends StatelessWidget {
  const _GenderOption({
    required this.gender,
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final ChildGender gender;
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.15)
              : Colors.transparent,
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade400,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? color : Colors.grey, size: 32),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? color : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dialog to edit cycle settings.
class EditCycleSettingsDialog extends StatefulWidget {
  const EditCycleSettingsDialog({
    super.key,
    required this.cycleInfo,
    required this.onSave,
  });

  final CycleInfo cycleInfo;
  final Future<void> Function(CycleInfo) onSave;

  @override
  State<EditCycleSettingsDialog> createState() =>
      _EditCycleSettingsDialogState();
}

class _EditCycleSettingsDialogState extends State<EditCycleSettingsDialog> {
  late int _cycleLength;
  late int _periodDuration;
  late bool _isTracking;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _cycleLength = widget.cycleInfo.cycleLength;
    _periodDuration = widget.cycleInfo.periodDuration;
    _isTracking = widget.cycleInfo.isTracking;
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    try {
      final info = widget.cycleInfo.copyWith(
        cycleLength: _cycleLength,
        periodDuration: _periodDuration,
        isTracking: _isTracking,
      );
      await widget.onSave(info);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark
        ? AppColors.primaryDark
        : AppColors.primaryLight;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Paramètres du cycle',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Tracking toggle
            SwitchListTile(
              title: const Text('Activer le suivi'),
              value: _isTracking,
              onChanged: (value) => setState(() => _isTracking = value),
              activeColor: primaryColor,
            ),
            const Divider(),

            // Cycle length
            ListTile(
              title: const Text('Durée du cycle'),
              subtitle: Text('$_cycleLength jours'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: _cycleLength > 20
                        ? () => setState(() => _cycleLength--)
                        : null,
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Text(
                    '$_cycleLength',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: _cycleLength < 40
                        ? () => setState(() => _cycleLength++)
                        : null,
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
            ),

            // Period duration
            ListTile(
              title: const Text('Durée des règles'),
              subtitle: Text('$_periodDuration jours'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: _periodDuration > 2
                        ? () => setState(() => _periodDuration--)
                        : null,
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Text(
                    '$_periodDuration',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: _periodDuration < 10
                        ? () => setState(() => _periodDuration++)
                        : null,
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    child: const Text('Annuler'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Enregistrer'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
