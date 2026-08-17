import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../providers/order_providers.dart';
import 'my_orders_screen.dart';

/// Checkout — order summary, delivery details, confirmation.
/// V1 without integrated payment: the order is created "à confirmer"
/// and settled at delivery (per ticket note, PSP arrives with LM2-044).
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _wilayaCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  String? _confirmedOrderId;

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
    final lang = Localizations.localeOf(context).languageCode;
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

    final cart = ref.watch(cartProvider);
    final total = ref.watch(cartTotalProvider);
    final actionsState = ref.watch(orderActionsProvider);

    if (_confirmedOrderId != null) {
      return _buildConfirmedView(context, textColor, subTextColor, lang);
    }

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
                      // ── Order summary ────────────────────────────────
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark
                                ? AppColors.dividerDark
                                : AppColors.dividerLight,
                          ),
                        ),
                        child: Column(
                          children: [
                            ...cart.map(
                              (item) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    Icon(
                                      item.product.icon,
                                      size: 18,
                                      color: item.product.category.color,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        '${item.product.name} ×${item.quantity}',
                                        style: GoogleFonts.outfit(
                                          fontSize: 13,
                                          color: textColor,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      _formatDZD(item.lineTotalDZD),
                                      style: GoogleFonts.outfit(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: textColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Divider(height: 16),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  lang == 'ar'
                                      ? 'المجموع'
                                      : lang == 'en'
                                          ? 'Total'
                                          : 'Total',
                                  style: GoogleFonts.outfit(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                  ),
                                ),
                                Text(
                                  _formatDZD(total),
                                  style: GoogleFonts.outfit(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.magentaPink,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // ── Payment note (V1: on confirmation) ───────────
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.info.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.payments_outlined,
                              color: AppColors.info,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                lang == 'ar'
                                    ? 'الدفع عند التسليم. سيتصل بك الشريك لتأكيد الطلب.'
                                    : lang == 'en'
                                        ? 'Payment on delivery. The partner will call you to confirm the order.'
                                        : 'Paiement à la livraison. Le partenaire vous appellera pour confirmer la commande.',
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
                        validator: (v) => v == null || v.trim().isEmpty
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
                        validator: (v) => _validatePhone(v, lang),
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
                        validator: (v) => v == null || v.trim().isEmpty
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
                        validator: (v) => v == null || v.trim().isEmpty
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
                            onPressed:
                                actionsState.isLoading ? null : _onConfirm,
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

  /// Basic Algerian mobile/landline sanity check: digits (spaces allowed),
  /// starting with 0, 9-10 digits total.
  String? _validatePhone(String? value, String lang) {
    if (value == null || value.trim().isEmpty) {
      return lang == 'ar'
          ? 'حقل مطلوب'
          : lang == 'en'
              ? 'Field required'
              : 'Champ requis';
    }
    final digits = value.replaceAll(RegExp(r'\s+'), '');
    if (!RegExp(r'^0\d{8,9}$').hasMatch(digits)) {
      return lang == 'ar'
          ? 'رقم غير صحيح (مثال: 0550 00 00 00)'
          : lang == 'en'
              ? 'Invalid number (ex: 0550 00 00 00)'
              : 'Numéro invalide (ex : 0550 00 00 00)';
    }
    return null;
  }

  Future<void> _onConfirm() async {
    if (!_formKey.currentState!.validate()) return;

    final lang = Localizations.localeOf(context).languageCode;

    final orderId = await ref
        .read(orderActionsProvider.notifier)
        .submitOrder(
          items: ref.read(cartProvider),
          fullName: _nameCtrl.text.trim(),
          phone: _phoneCtrl.text.trim(),
          wilaya: _wilayaCtrl.text.trim(),
          address: _addressCtrl.text.trim(),
        );

    if (!mounted) return;

    if (orderId != null) {
      ref.read(cartProvider.notifier).clear();
      setState(() => _confirmedOrderId = orderId);
    } else {
      final error = ref.read(orderActionsProvider).error;
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
    }
  }

  Widget _buildConfirmedView(
    BuildContext context,
    Color textColor,
    Color subTextColor,
    String lang,
  ) {
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
                      ? 'تم تأكيد الطلب!'
                      : lang == 'en'
                          ? 'Order confirmed!'
                          : 'Commande confirmée !',
                  style: GoogleFonts.outfit(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  lang == 'ar'
                      ? 'سيتصل بك الشريك هاتفياً لتأكيد التسليم والدفع.'
                      : lang == 'en'
                          ? 'The partner will contact you by phone to confirm delivery and payment.'
                          : 'Le partenaire vous contactera par téléphone pour confirmer la livraison et le paiement.',
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    color: subTextColor,
                  ),
                  textAlign: TextAlign.center,
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
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => const MyOrdersScreen(),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.receipt_long_rounded,
                        color: Colors.white,
                      ),
                      label: Text(
                        lang == 'ar'
                            ? 'عرض طلباتي'
                            : lang == 'en'
                                ? 'View my orders'
                                : 'Voir mes commandes',
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
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).popUntil((r) => r.isFirst),
                  child: Text(
                    lang == 'ar'
                        ? 'العودة إلى الرئيسية'
                        : lang == 'en'
                            ? 'Back to home'
                            : 'Retour à l\'accueil',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: subTextColor,
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

  static String _formatDZD(int amount) {
    final digits = amount.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    return '$buffer DZD';
  }
}
