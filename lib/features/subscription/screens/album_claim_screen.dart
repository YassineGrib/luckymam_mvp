import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';

import '../../profile/providers/profile_providers.dart';
import '../models/subscription_models.dart';
import '../providers/subscription_providers.dart';

/// VIP "Free Printed Album" claim form.
class AlbumClaimScreen extends ConsumerStatefulWidget {
  const AlbumClaimScreen({super.key});

  @override
  ConsumerState<AlbumClaimScreen> createState() => _AlbumClaimScreenState();
}

class _AlbumClaimScreenState extends ConsumerState<AlbumClaimScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _wilayaCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  String? _selectedChildId;
  String? _selectedChildName;
  bool _submitted = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _wilayaCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;
    final textColor = isDark ? Colors.white : AppColors.onSurfaceLight;
    final subTextColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final inputBg = isDark
        ? AppColors.inputBackgroundDark
        : AppColors.inputBackgroundLight;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

    final childrenAsync = ref.watch(childrenProvider);
    final actionsState = ref.watch(subscriptionActionsProvider);
    final albumClaimed = ref.watch(albumClaimedProvider).valueOrNull ?? false;

    ref.listen<SubscriptionActionsState>(subscriptionActionsProvider, (
      _,
      next,
    ) {
      if (next.successMessage != null) {
        setState(() => _submitted = true);
        ref.read(subscriptionActionsProvider.notifier).clearMessages();
      }
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!), backgroundColor: Colors.red),
        );
        ref.read(subscriptionActionsProvider.notifier).clearMessages();
      }
    });

    if (_submitted || albumClaimed)
      return _buildSubmittedView(context, textColor);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 16, 20, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF6F00), Color(0xFFFFAB00)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.card_giftcard_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Album Imprimé Gratuit',
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        Text(
                          'Votre cadeau VIP 🎁',
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            color: const Color(0xFFFF6F00),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            if (actionsState.isLoading) const LinearProgressIndicator(),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Info banner
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFFFF6F00,
                          ).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline_rounded,
                              color: Color(0xFFFF6F00),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'En tant que membre VIP, vous recevez un album photo imprimé de vos plus beaux souvenirs. Remplissez le formulaire ci-dessous.',
                                style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  color: textColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Child selection
                      Text(
                        'Pour quel enfant ?',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 10),

                      childrenAsync.when(
                        loading: () => const CircularProgressIndicator(),
                        error: (_, __) => Text(
                          'Erreur de chargement',
                          style: GoogleFonts.outfit(color: AppColors.error),
                        ),
                        data: (children) => Wrap(
                          spacing: 10,
                          children: children.map((child) {
                            final c = child;
                            final isSelected = _selectedChildId == c.id;
                            return GestureDetector(
                              onTap: () => setState(() {
                                _selectedChildId = c.id;
                                _selectedChildName = c.name;
                              }),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(
                                          0xFFFF6F00,
                                        ).withValues(alpha: 0.15)
                                      : surface,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFFFF6F00)
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: Text(
                                  c.name,
                                  style: GoogleFonts.outfit(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? const Color(0xFFFF6F00)
                                        : textColor,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Delivery details
                      Text(
                        'Informations de livraison',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 12),

                      _buildFormField(
                        label: 'Nom complet',
                        hint: 'Votre nom et prénom',
                        controller: _nameCtrl,
                        icon: Icons.person_outline_rounded,
                        inputBg: inputBg,
                        textColor: textColor,
                        subTextColor: subTextColor,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Champ requis' : null,
                      ),
                      const SizedBox(height: 12),

                      _buildFormField(
                        label: 'Téléphone',
                        hint: '0550 00 00 00',
                        controller: _phoneCtrl,
                        icon: Icons.phone_outlined,
                        inputBg: inputBg,
                        textColor: textColor,
                        subTextColor: subTextColor,
                        keyboardType: TextInputType.phone,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Champ requis' : null,
                      ),
                      const SizedBox(height: 12),

                      _buildFormField(
                        label: 'Wilaya',
                        hint: 'Votre wilaya',
                        controller: _wilayaCtrl,
                        icon: Icons.location_city_rounded,
                        inputBg: inputBg,
                        textColor: textColor,
                        subTextColor: subTextColor,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Champ requis' : null,
                      ),
                      const SizedBox(height: 12),

                      _buildFormField(
                        label: 'Adresse complète',
                        hint: 'Rue, numéro, quartier...',
                        controller: _addressCtrl,
                        icon: Icons.home_outlined,
                        inputBg: inputBg,
                        textColor: textColor,
                        subTextColor: subTextColor,
                        maxLines: 2,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Champ requis' : null,
                      ),

                      const SizedBox(height: 28),

                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton.icon(
                          onPressed: actionsState.isLoading ? null : _onSubmit,
                          icon: const Icon(Icons.send_rounded),
                          label: Text(
                            'Envoyer ma demande',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF6F00),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    required Color inputBg,
    required Color textColor,
    required Color subTextColor,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(fontSize: 12, color: subTextColor),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          style: GoogleFonts.outfit(fontSize: 15, color: textColor),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.outfit(
              fontSize: 15,
              color: subTextColor.withValues(alpha: 0.5),
            ),
            prefixIcon: Icon(icon, size: 20, color: subTextColor),
            filled: true,
            fillColor: inputBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedChildId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner un enfant'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final claim = AlbumClaim(
      id: '',
      userId: uid,
      fullName: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      wilaya: _wilayaCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      childId: _selectedChildId!,
      childName: _selectedChildName ?? '',
      dateRange: 'Tous les souvenirs',
      createdAt: DateTime.now(),
    );

    ref.read(subscriptionActionsProvider.notifier).submitAlbumClaim(claim);
  }

  Widget _buildSubmittedView(BuildContext context, Color textColor) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    size: 60,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'Demande envoyée !',
                  style: GoogleFonts.outfit(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Votre album imprimé sera préparé et expédié à l\'adresse indiquée. Nous vous contacterons par téléphone pour confirmer.',
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    color: textColor.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6F00).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_shipping_rounded,
                        color: Color(0xFFFF6F00),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Délai estimé : 7-14 jours',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFFF6F00),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 36),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6F00),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Retour',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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
}
