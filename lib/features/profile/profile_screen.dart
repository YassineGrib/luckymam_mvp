import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import 'models/profile_models.dart';
import 'privacy_screen.dart';
import 'help_screen.dart';
import 'providers/profile_providers.dart';
import 'widgets/edit_dialogs.dart';
import 'widgets/profile_widgets.dart';

/// Full profile screen with Firestore integration.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark
        ? AppColors.primaryDark
        : AppColors.primaryLight;
    final textColor = isDark ? Colors.white : AppColors.onSurfaceLight;
    final secondaryColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final authService = AuthService();
    final user = authService.currentUser;

    // Watch profile from Firestore
    final profileAsync = ref.watch(profileProvider);
    final childrenAsync = ref.watch(childrenProvider);
    final actionsState = ref.watch(profileActionsProvider);

    // Show snackbar on success/error
    ref.listen<ProfileActionsState>(profileActionsProvider, (previous, next) {
      if (next.successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage!),
            backgroundColor: Colors.green,
          ),
        );
        ref.read(profileActionsProvider.notifier).clearMessages();
      }
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!), backgroundColor: Colors.red),
        );
        ref.read(profileActionsProvider.notifier).clearMessages();
      }
    });

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Custom App Bar with profile header
          SliverToBoxAdapter(
            child: profileAsync.when(
              data: (profile) => _ProfileHeader(
                name:
                    profile?.displayName ?? user?.displayName ?? 'Utilisatrice',
                email: profile?.email ?? user?.email ?? '',
                photoUrl: profile?.photoUrl ?? user?.photoURL,
                status: profile?.status ?? UserStatus.mom,
                primaryColor: primaryColor,
                textColor: textColor,
                secondaryColor: secondaryColor,
                onCameraTap: () => _pickProfileImage(context, ref),
              ),
              loading: () => _ProfileHeader(
                name: user?.displayName ?? 'Chargement...',
                email: user?.email ?? '',
                photoUrl: user?.photoURL,
                status: UserStatus.mom,
                primaryColor: primaryColor,
                textColor: textColor,
                secondaryColor: secondaryColor,
              ),
              error: (_, __) => _ProfileHeader(
                name: user?.displayName ?? 'Erreur',
                email: user?.email ?? '',
                photoUrl: user?.photoURL,
                status: UserStatus.mom,
                primaryColor: primaryColor,
                textColor: textColor,
                secondaryColor: secondaryColor,
              ),
            ),
          ),

          // Loading indicator
          if (actionsState.isLoading)
            const SliverToBoxAdapter(child: LinearProgressIndicator()),

          // Profile sections
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPaddingH,
              AppSpacing.md,
              AppSpacing.screenPaddingH,
              100,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // 1. Personal Information
                profileAsync.when(
                  data: (profile) => _PersonalInfoSection(
                    profile: profile,
                    fallbackUser: user,
                    onEdit: () => _showEditPersonalInfo(context, ref, profile),
                  ),
                  loading: () => const _LoadingSectionCard(
                    title: 'Informations Personnelles',
                  ),
                  error: (_, __) => const _ErrorSectionCard(
                    title: 'Informations Personnelles',
                  ),
                ),

                // 2. Current Status
                profileAsync.when(
                  data: (profile) => _StatusSection(
                    profile: profile,
                    primaryColor: primaryColor,
                    onStatusChange: (status) {
                      ref
                          .read(profileActionsProvider.notifier)
                          .updateStatus(status);
                    },
                  ),
                  loading: () =>
                      const _LoadingSectionCard(title: 'Statut Actuel'),
                  error: (_, __) =>
                      const _ErrorSectionCard(title: 'Statut Actuel'),
                ),

                // 3. Children
                childrenAsync.when(
                  data: (children) => _ChildrenSection(
                    children: children,
                    primaryColor: primaryColor,
                    onAddChild: () => _showAddChildDialog(context, ref),
                    onEditChild: (child) =>
                        _showAddChildDialog(context, ref, child),
                  ),
                  loading: () =>
                      const _LoadingSectionCard(title: 'Mes Enfants'),
                  error: (_, __) => _EmptyChildrenSection(
                    primaryColor: primaryColor,
                    onAddChild: () => _showAddChildDialog(context, ref),
                  ),
                ),

                // 4. Medical Information
                profileAsync.when(
                  data: (profile) => _MedicalInfoSection(
                    medicalInfo: profile?.medicalInfo ?? const MedicalInfo(),
                    onEdit: () => _showEditMedicalInfo(
                      context,
                      ref,
                      profile?.medicalInfo,
                    ),
                  ),
                  loading: () => const _LoadingSectionCard(
                    title: 'Informations Médicales',
                  ),
                  error: (_, __) =>
                      const _ErrorSectionCard(title: 'Informations Médicales'),
                ),

                // 5. Menstrual Cycle
                profileAsync.when(
                  data: (profile) => _CycleSection(
                    cycleInfo: profile?.cycleInfo ?? const CycleInfo(),
                    onLogPeriod: () => _showLogPeriodDialog(context, ref),
                    onEditSettings: () => _showEditCycleSettings(
                      context,
                      ref,
                      profile?.cycleInfo ?? const CycleInfo(),
                    ),
                  ),
                  loading: () =>
                      const _LoadingSectionCard(title: 'Cycle Menstruel'),
                  error: (_, __) =>
                      const _ErrorSectionCard(title: 'Cycle Menstruel'),
                ),

                // 6. App Settings
                _SettingsSection(
                  isDark: isDark,
                  primaryColor: primaryColor,
                  onLogout: () async {
                    await authService.signOut();
                    if (context.mounted) {
                      context.go('/login');
                    }
                  },
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditPersonalInfo(
    BuildContext context,
    WidgetRef ref,
    UserProfile? profile,
  ) {
    showDialog(
      context: context,
      builder: (context) => EditPersonalInfoDialog(
        profile: profile,
        onSave: ({displayName, phone, birthDate, wilaya}) async {
          await ref
              .read(profileActionsProvider.notifier)
              .updatePersonalInfo(
                displayName: displayName,
                phone: phone,
                birthDate: birthDate,
                wilaya: wilaya,
              );
        },
      ),
    );
  }

  void _showEditMedicalInfo(
    BuildContext context,
    WidgetRef ref,
    MedicalInfo? info,
  ) {
    showDialog(
      context: context,
      builder: (context) => EditMedicalInfoDialog(
        medicalInfo: info ?? const MedicalInfo(),
        onSave: (updatedInfo) async {
          await ref
              .read(profileActionsProvider.notifier)
              .updateMedicalInfo(updatedInfo);
        },
      ),
    );
  }

  void _showAddChildDialog(
    BuildContext context,
    WidgetRef ref, [
    Child? existingChild,
  ]) {
    showDialog(
      context: context,
      builder: (context) => AddEditChildDialog(
        child: existingChild,
        onSave: (child, {imageFile}) async {
          if (existingChild != null) {
            await ref
                .read(profileActionsProvider.notifier)
                .updateChild(child, imageFile: imageFile);
          } else {
            await ref
                .read(profileActionsProvider.notifier)
                .addChild(child, imageFile: imageFile);
          }
        },
        onDelete: existingChild != null
            ? () async {
                await ref
                    .read(profileActionsProvider.notifier)
                    .deleteChild(existingChild.id);
              }
            : null,
      ),
    );
  }

  void _showEditCycleSettings(
    BuildContext context,
    WidgetRef ref,
    CycleInfo cycleInfo,
  ) {
    showDialog(
      context: context,
      builder: (context) => EditCycleSettingsDialog(
        cycleInfo: cycleInfo,
        onSave: (updatedInfo) async {
          await ref
              .read(profileActionsProvider.notifier)
              .updateCycleInfo(updatedInfo);
        },
      ),
    );
  }

  void _showLogPeriodDialog(BuildContext context, WidgetRef ref) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 60)),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      ref.read(profileActionsProvider.notifier).logPeriodStart(date);
    }
  }

  Future<void> _pickProfileImage(BuildContext context, WidgetRef ref) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 800,
    );

    if (pickedFile != null) {
      await ref
          .read(profileActionsProvider.notifier)
          .updateProfilePhoto(File(pickedFile.path));
    }
  }
}

// ============ SECTION WIDGETS ============

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.name,
    required this.email,
    required this.primaryColor,
    required this.textColor,
    required this.secondaryColor,
    required this.status,
    this.photoUrl,
    this.onCameraTap,
  });

  final String name;
  final String email;
  final String? photoUrl;
  final UserStatus status;
  final Color primaryColor;
  final Color textColor;
  final Color secondaryColor;
  final VoidCallback? onCameraTap;

  @override
  Widget build(BuildContext context) {
    final statusLabel = status == UserStatus.pregnant ? 'Enceinte' : 'Maman';
    final statusColor = status == UserStatus.pregnant
        ? Colors.pink
        : Colors.green;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenPaddingH,
        MediaQuery.of(context).padding.top + AppSpacing.lg,
        AppSpacing.screenPaddingH,
        AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [primaryColor.withValues(alpha: 0.2), Colors.transparent],
        ),
      ),
      child: Row(
        children: [
          // Avatar
          GestureDetector(
            onTap: onCameraTap,
            child: Stack(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        primaryColor,
                        primaryColor.withValues(alpha: 0.7),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: photoUrl != null
                      ? ClipOval(
                          child: Image.network(photoUrl!, fit: BoxFit.cover),
                        )
                      : Center(
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : 'U',
                            style: GoogleFonts.outfit(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      shape: BoxShape.circle,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // Name and email
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: secondaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        statusLabel,
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
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
    );
  }
}

class _PersonalInfoSection extends StatelessWidget {
  const _PersonalInfoSection({
    required this.profile,
    required this.fallbackUser,
    required this.onEdit,
  });

  final UserProfile? profile;
  final dynamic fallbackUser;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMMM yyyy', 'fr_FR');

    return ProfileSectionCard(
      title: 'Informations Personnelles',
      icon: Icons.person_rounded,
      iconColor: Colors.blue,
      initiallyExpanded: true,
      children: [
        ProfileInfoRow(
          label: 'Nom complet',
          value:
              profile?.displayName ??
              fallbackUser?.displayName ??
              'Non renseigné',
          icon: Icons.badge_outlined,
          onEdit: onEdit,
        ),
        ProfileInfoRow(
          label: 'E-mail',
          value: profile?.email ?? fallbackUser?.email ?? 'Non renseigné',
          icon: Icons.email_outlined,
        ),
        ProfileInfoRow(
          label: 'Téléphone',
          value: profile?.phone ?? 'Non renseigné',
          icon: Icons.phone_outlined,
          onEdit: onEdit,
        ),
        ProfileInfoRow(
          label: 'Date de naissance',
          value: profile?.birthDate != null
              ? dateFormat.format(profile!.birthDate!)
              : 'Non renseigné',
          icon: Icons.cake_outlined,
          onEdit: onEdit,
        ),
        ProfileInfoRow(
          label: 'Wilaya',
          value: profile?.wilaya ?? 'Non renseigné',
          icon: Icons.location_on_outlined,
          onEdit: onEdit,
        ),
      ],
    );
  }
}

class _StatusSection extends StatelessWidget {
  const _StatusSection({
    required this.profile,
    required this.primaryColor,
    required this.onStatusChange,
  });

  final UserProfile? profile;
  final Color primaryColor;
  final Function(UserStatus) onStatusChange;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMMM yyyy', 'fr_FR');

    return ProfileSectionCard(
      title: 'Statut Actuel',
      icon: Icons.favorite_rounded,
      iconColor: Colors.pink,
      children: [
        _StatusSelector(
          currentStatus: profile?.status ?? UserStatus.mom,
          primaryColor: primaryColor,
          onStatusChange: onStatusChange,
        ),
        const SizedBox(height: AppSpacing.sm),
        ProfileInfoRow(
          label: 'Phase actuelle',
          value: profile?.statusLabel ?? 'Maman',
          valueColor: primaryColor,
        ),
        if (profile?.lastPregnancyDate != null)
          ProfileInfoRow(
            label: 'Dernière grossesse',
            value: dateFormat.format(profile!.lastPregnancyDate!),
            icon: Icons.calendar_today_outlined,
          ),
      ],
    );
  }
}

class _StatusSelector extends StatelessWidget {
  const _StatusSelector({
    required this.currentStatus,
    required this.primaryColor,
    required this.onStatusChange,
  });

  final UserStatus currentStatus;
  final Color primaryColor;
  final Function(UserStatus) onStatusChange;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF252538) : Colors.grey.shade100;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildOption(
            context,
            UserStatus.pregnant,
            Icons.pregnant_woman_rounded,
            'Enceinte',
          ),
          _buildOption(
            context,
            UserStatus.mom,
            Icons.child_friendly_rounded,
            'Maman',
          ),
        ],
      ),
    );
  }

  Widget _buildOption(
    BuildContext context,
    UserStatus status,
    IconData icon,
    String label,
  ) {
    final isSelected = currentStatus == status;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: () => onStatusChange(status),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white60 : Colors.grey),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.white60 : Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChildrenSection extends StatelessWidget {
  const _ChildrenSection({
    required this.children,
    required this.primaryColor,
    required this.onAddChild,
    required this.onEditChild,
  });

  final List<Child> children;
  final Color primaryColor;
  final VoidCallback onAddChild;
  final Function(Child) onEditChild;

  @override
  Widget build(BuildContext context) {
    return ProfileSectionCard(
      title: 'Mes Enfants',
      icon: Icons.child_care_rounded,
      iconColor: Colors.orange,
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          '${children.length}',
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
      ),
      children: [
        ...children.map(
          (child) => GestureDetector(
            onTap: () => onEditChild(child),
            child: ChildCard(
              name: child.name,
              birthDate:
                  '${DateFormat('dd MMM yyyy', 'fr_FR').format(child.birthDate)} (${child.ageString})',
              gender: child.genderLabel,
              photoUrl: child.photoUrl,
            ),
          ),
        ),
        if (children.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Text(
              'Aucun enfant enregistré',
              style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey),
            ),
          ),
        const SizedBox(height: AppSpacing.xs),
        _AddChildButton(primaryColor: primaryColor, onTap: onAddChild),
      ],
    );
  }
}

class _AddChildButton extends StatelessWidget {
  const _AddChildButton({required this.primaryColor, required this.onTap});

  final Color primaryColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: primaryColor.withValues(alpha: 0.3),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded, color: primaryColor, size: 20),
            const SizedBox(width: 8),
            Text(
              'Ajouter un enfant',
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MedicalInfoSection extends StatelessWidget {
  const _MedicalInfoSection({required this.medicalInfo, required this.onEdit});

  final MedicalInfo medicalInfo;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return ProfileSectionCard(
      title: 'Informations Médicales',
      icon: Icons.medical_services_rounded,
      iconColor: Colors.red,
      children: [
        ProfileInfoRow(
          label: 'Groupe sanguin',
          value: medicalInfo.bloodType ?? 'Non renseigné',
          icon: Icons.water_drop_outlined,
          valueColor: medicalInfo.bloodType != null ? Colors.red : null,
          onEdit: onEdit,
        ),
        ProfileInfoRow(
          label: 'Allergies',
          value: medicalInfo.allergies.isNotEmpty
              ? medicalInfo.allergies.join(', ')
              : 'Aucune allergie connue',
          icon: Icons.warning_amber_outlined,
          onEdit: onEdit,
        ),
        ProfileInfoRow(
          label: 'Conditions médicales',
          value: medicalInfo.conditions.isNotEmpty
              ? medicalInfo.conditions.join(', ')
              : 'Aucune',
          icon: Icons.health_and_safety_outlined,
          onEdit: onEdit,
        ),
        ProfileInfoRow(
          label: 'Médecin traitant',
          value: medicalInfo.doctorName ?? 'Non renseigné',
          icon: Icons.person_outline_rounded,
          onEdit: onEdit,
        ),
      ],
    );
  }
}

class _CycleSection extends StatelessWidget {
  const _CycleSection({
    required this.cycleInfo,
    required this.onLogPeriod,
    required this.onEditSettings,
  });

  final CycleInfo cycleInfo;
  final VoidCallback onLogPeriod;
  final VoidCallback onEditSettings;

  Color _getPhaseColor(String phase) {
    switch (phase) {
      case 'Règles':
        return Colors.red;
      case 'Phase Folliculaire':
        return Colors.blue;
      case 'Phase Ovulatoire':
        return Colors.purple;
      case 'Phase Lutéale':
        return Colors.orange;
      default:
        return Colors.purple;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMMM yyyy', 'fr_FR');
    final phaseColor = _getPhaseColor(cycleInfo.currentPhase);

    return ProfileSectionCard(
      title: 'Cycle Menstruel',
      icon: Icons.loop_rounded,
      iconColor: Colors.purple,
      trailing: IconButton(
        icon: const Icon(Icons.settings_outlined, size: 20),
        onPressed: onEditSettings,
        color: Colors.grey,
      ),
      children: [
        if (cycleInfo.isTracking && cycleInfo.lastPeriodDate != null) ...[
          CycleDayIndicator(
            currentDay: cycleInfo.currentDay,
            cycleLength: cycleInfo.cycleLength,
            phase: cycleInfo.currentPhase,
            phaseColor: phaseColor,
          ),
          const SizedBox(height: AppSpacing.md),
          ProfileInfoRow(
            label: 'Dernières règles',
            value: dateFormat.format(cycleInfo.lastPeriodDate!),
            icon: Icons.event_outlined,
          ),
          if (cycleInfo.nextPeriodDate != null)
            ProfileInfoRow(
              label: 'Prochaines règles',
              value: dateFormat.format(cycleInfo.nextPeriodDate!),
              icon: Icons.event_available_outlined,
              valueColor: Colors.purple,
            ),
          ProfileInfoRow(
            label: 'Durée moyenne',
            value: '${cycleInfo.periodDuration} jours',
            icon: Icons.timelapse_outlined,
          ),
        ] else
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Text(
              'Suivi du cycle non activé',
              style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey),
            ),
          ),
        const SizedBox(height: AppSpacing.sm),
        ElevatedButton.icon(
          onPressed: onLogPeriod,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Enregistrer mes règles'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
            minimumSize: const Size(double.infinity, 0),
          ),
        ),
      ],
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.isDark,
    required this.primaryColor,
    required this.onLogout,
  });

  final bool isDark;
  final Color primaryColor;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final secondaryColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final textColor = isDark ? Colors.white : AppColors.onSurfaceLight;

    return ProfileSectionCard(
      title: 'Paramètres',
      icon: Icons.settings_rounded,
      iconColor: Colors.grey,
      children: [
        _SettingsTile(
          icon: Icons.dark_mode_outlined,
          textColor: textColor,
          secondaryColor: secondaryColor,
          title: 'Thème sombre',
          trailing: Switch(
            value: isDark,
            onChanged: (value) {
              // TODO: Implement theme toggle
            },
            activeColor: primaryColor,
          ),
        ),
        _SettingsTile(
          icon: Icons.language_outlined,
          textColor: textColor,
          secondaryColor: secondaryColor,
          title: 'Langue',
          subtitle: 'Français',
          onTap: () {},
        ),
        _SettingsTile(
          icon: Icons.notifications_outlined,
          textColor: textColor,
          secondaryColor: secondaryColor,
          title: 'Notifications',
          subtitle: 'Activées',
          onTap: () {},
        ),
        _SettingsTile(
          icon: Icons.lock_outline_rounded,
          textColor: textColor,
          secondaryColor: secondaryColor,
          title: 'Confidentialité',
          onTap: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const PrivacyScreen()));
          },
        ),
        _SettingsTile(
          icon: Icons.help_outline_rounded,
          textColor: textColor,
          secondaryColor: secondaryColor,
          title: 'Aide & Support',
          onTap: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const HelpScreen()));
          },
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onLogout,
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Déconnexion'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.textColor,
    required this.secondaryColor,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color textColor;
  final Color secondaryColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 22, color: secondaryColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: secondaryColor,
                      ),
                    ),
                ],
              ),
            ),
            if (trailing != null)
              trailing!
            else if (onTap != null)
              Icon(
                Icons.chevron_right_rounded,
                color: secondaryColor,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyChildrenSection extends StatelessWidget {
  const _EmptyChildrenSection({
    required this.primaryColor,
    required this.onAddChild,
  });

  final Color primaryColor;
  final VoidCallback onAddChild;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ProfileSectionCard(
      title: l10n.myChildren,
      icon: Icons.child_care_rounded,
      iconColor: Colors.orange,
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          '0',
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
      ),
      initiallyExpanded: true,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Text(
            l10n.noChildrenTitle,
            style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        _AddChildButton(primaryColor: primaryColor, onTap: onAddChild),
      ],
    );
  }
}

class _LoadingSectionCard extends StatelessWidget {
  const _LoadingSectionCard({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return ProfileSectionCard(
      title: title,
      icon: Icons.hourglass_empty_rounded,
      iconColor: Colors.grey,
      children: const [
        Center(child: CircularProgressIndicator()),
        SizedBox(height: AppSpacing.md),
      ],
    );
  }
}

class _ErrorSectionCard extends StatelessWidget {
  const _ErrorSectionCard({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return ProfileSectionCard(
      title: title,
      icon: Icons.error_outline_rounded,
      iconColor: Colors.red,
      children: [
        Text(
          'Erreur de chargement',
          style: GoogleFonts.outfit(color: Colors.red),
        ),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }
}
