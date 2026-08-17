import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../subscription/providers/subscription_providers.dart';
import '../models/print_order.dart';
import '../providers/print_order_providers.dart';

/// Collects shipping details and finalizes a print order for a specific
/// album. VIP members see the perk applied automatically; others see a
/// note that pricing will be confirmed by the team.
class PrintOrderScreen extends ConsumerStatefulWidget {
  const PrintOrderScreen({
    super.key,
    required this.childId,
    required this.childName,
    required this.albumId,
    required this.albumType,
    required this.albumTitle,
    required this.pageCount,
  });

  final String childId;
  final String childName;
  final String albumId;
  final String albumType;
  final String albumTitle;
  final int pageCount;

  @override
  ConsumerState<PrintOrderScreen> createState() => _PrintOrderScreenState();
}

class _PrintOrderScreenState extends ConsumerState<PrintOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _wilayaCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
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

    final isVip = ref.watch(isVipProvider);
    final actionsState = ref.watch(printOrderActionsProvider);

    final lang = Localizations.localeOf(context).languageCode;

    if (_submitted) return _buildSubmittedView(context, textColor, lang);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          lang == 'ar'
              ? 'إتمام الطلب'
              : lang == 'en'
                  ? 'Finalize Order'
                  : 'Finaliser la commande',
          style: GoogleFonts.outfit(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (actionsState.isLoading) const LinearProgressIndicator(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Album summary card
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.menu_book_rounded,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.albumTitle,
                                    style: GoogleFonts.outfit(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    lang == 'ar'
                                        ? '${widget.pageCount} صفحات · ${widget.childName}'
                                        : lang == 'en'
                                            ? '${widget.pageCount} pages · ${widget.childName}'
                                            : '${widget.pageCount} pages · ${widget.childName}',
                                    style: GoogleFonts.outfit(
                                      fontSize: 12,
                                      color: Colors.white.withValues(
                                        alpha: 0.85,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Pricing note
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: (isVip ? AppColors.success : AppColors.info)
                              .withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isVip
                                  ? Icons.card_giftcard_rounded
                                  : Icons.info_outline_rounded,
                              color: isVip
                                  ? AppColors.success
                                  : AppColors.info,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                isVip
                                    ? (lang == 'ar'
                                        ? 'مجانًا مع اشتراك VIP الخاص بك 🎁'
                                        : lang == 'en'
                                            ? 'Free with your VIP subscription 🎁'
                                            : 'Offert avec votre abonnement VIP 🎁')
                                    : (lang == 'ar'
                                        ? 'سيتواصل معك فريقنا لتأكيد تكلفة الطباعة والتسليم.'
                                        : lang == 'en'
                                            ? 'Our team will contact you to confirm printing and shipping fees.'
                                            : 'Nos équipes vous contacteront pour confirmer le tarif d\'impression.'),
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
                      Text(
                        lang == 'ar'
                            ? 'معلومات التسليم'
                            : lang == 'en'
                                ? 'Shipping Information'
                                : 'Informations de livraison',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 12),

                      _buildFormField(
                        label: lang == 'ar'
                            ? 'الاسم الكامل'
                            : lang == 'en'
                                ? 'Full Name'
                                : 'Nom complet',
                        hint: lang == 'ar'
                            ? 'الاسم واللقب'
                            : lang == 'en'
                                ? 'Your full name'
                                : 'Votre nom et prénom',
                        controller: _nameCtrl,
                        icon: Icons.person_outline_rounded,
                        inputBg: inputBg,
                        textColor: textColor,
                        subTextColor: subTextColor,
                        validator: (v) => v == null || v.isEmpty
                            ? (lang == 'ar'
                                ? 'حقل مطلوب'
                                : lang == 'en'
                                    ? 'Field required'
                                    : 'Champ requis')
                            : null,
                      ),
                      const SizedBox(height: 12),

                      _buildFormField(
                        label: lang == 'ar'
                            ? 'رقم الهاتف'
                            : lang == 'en'
                                ? 'Phone Number'
                                : 'Téléphone',
                        hint: '0550 00 00 00',
                        controller: _phoneCtrl,
                        icon: Icons.phone_outlined,
                        inputBg: inputBg,
                        textColor: textColor,
                        subTextColor: subTextColor,
                        keyboardType: TextInputType.phone,
                        validator: (v) => v == null || v.isEmpty
                            ? (lang == 'ar'
                                ? 'حقل مطلوب'
                                : lang == 'en'
                                    ? 'Field required'
                                    : 'Champ requis')
                            : null,
                      ),
                      const SizedBox(height: 12),

                      _buildFormField(
                        label: lang == 'ar'
                            ? 'الولاية'
                            : lang == 'en'
                                ? 'Wilaya'
                                : 'Wilaya',
                        hint: lang == 'ar'
                            ? 'الولاية الخاصة بك'
                            : lang == 'en'
                                ? 'Your province'
                                : 'Votre wilaya',
                        controller: _wilayaCtrl,
                        icon: Icons.location_city_rounded,
                        inputBg: inputBg,
                        textColor: textColor,
                        subTextColor: subTextColor,
                        validator: (v) => v == null || v.isEmpty
                            ? (lang == 'ar'
                                ? 'حقل مطلوب'
                                : lang == 'en'
                                    ? 'Field required'
                                    : 'Champ requis')
                            : null,
                      ),
                      const SizedBox(height: 12),

                      _buildFormField(
                        label: lang == 'ar'
                            ? 'العنوان الكامل'
                            : lang == 'en'
                                ? 'Full Address'
                                : 'Adresse complète',
                        hint: lang == 'ar'
                            ? 'الشارع، رقم الباب، الحي...'
                            : lang == 'en'
                                ? 'Street, number, neighborhood...'
                                : 'Rue, numéro, quartier...',
                        controller: _addressCtrl,
                        icon: Icons.home_outlined,
                        inputBg: inputBg,
                        textColor: textColor,
                        subTextColor: subTextColor,
                        maxLines: 2,
                        validator: (v) => v == null || v.isEmpty
                            ? (lang == 'ar'
                                ? 'حقل مطلوب'
                                : lang == 'en'
                                    ? 'Field required'
                                    : 'Champ requis')
                            : null,
                      ),

                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ElevatedButton.icon(
                            onPressed: actionsState.isLoading
                                ? null
                                : _onSubmit,
                            icon: const Icon(
                              Icons.check_circle_rounded,
                              color: Colors.white,
                            ),
                            label: Text(
                              lang == 'ar'
                                  ? 'تأكيد الطلب'
                                  : lang == 'en'
                                      ? 'Confirm Order'
                                      : 'Confirmer la commande',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
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

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final lang = Localizations.localeOf(context).languageCode;
    final isVip = ref.read(isVipProvider);

    final order = PrintOrder(
      id: '',
      userId: uid,
      childId: widget.childId,
      childName: widget.childName,
      albumId: widget.albumId,
      albumType: widget.albumType,
      albumTitle: widget.albumTitle,
      pageCount: widget.pageCount,
      fullName: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      wilaya: _wilayaCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      isVipFree: isVip,
      createdAt: DateTime.now(),
    );

    final success = await ref
        .read(printOrderActionsProvider.notifier)
        .submitOrder(order);

    if (!mounted) return;

    if (success) {
      setState(() => _submitted = true);
    } else {
      final error = ref.read(printOrderActionsProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error ??
                (lang == 'ar'
                    ? 'حدث خطأ أثناء إرسال الطلب'
                    : lang == 'en'
                        ? 'An error occurred while placing the order'
                        : 'Erreur lors de la commande'),
          ),
          backgroundColor: AppColors.error,
        ),
      );
      ref.read(printOrderActionsProvider.notifier).clearMessages();
    }
  }

  Widget _buildSubmittedView(BuildContext context, Color textColor, String lang) {
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
                  lang == 'ar'
                      ? 'تم إرسال الطلب!'
                      : lang == 'en'
                          ? 'Order sent!'
                          : 'Commande envoyée !',
                  style: GoogleFonts.outfit(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  lang == 'ar'
                      ? 'سيتم طباعة ألبوم « ${widget.albumTitle} » وشحنه إلى العنوان المحدد. سنتصل بك هاتفياً للتأكيد.'
                      : lang == 'en'
                          ? '“${widget.albumTitle}” will be printed and shipped to the address provided. We will contact you by phone to confirm.'
                          : '« ${widget.albumTitle} » sera imprimé et expédié à l\'adresse indiquée. Nous vous contacterons par téléphone pour confirmer.',
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
                    color: AppColors.magentaPink.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_shipping_rounded,
                        color: AppColors.magentaPink,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        lang == 'ar'
                            ? 'الوقت المتوقع: 7-14 يوم'
                            : lang == 'en'
                                ? 'Estimated delay: 7-14 days'
                                : 'Délai estimé : 7-14 jours',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.magentaPink,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 36),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        // Pop this screen and the PDF preview, landing back
                        // on the album the order was placed for.
                        final navigator = Navigator.of(context);
                        navigator.pop();
                        navigator.pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        lang == 'ar'
                            ? 'العودة إلى الألبوم'
                            : lang == 'en'
                                ? 'Back to album'
                                : 'Retour à l\'album',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
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
