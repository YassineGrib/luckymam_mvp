import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions/l10n_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/top_ambient_gradient.dart';
import '../../profile/providers/profile_providers.dart';
import '../../profile/widgets/edit_dialogs.dart';
import '../providers/order_providers.dart';
import 'my_orders_screen.dart';

/// Checkout — order summary, delivery details, and cash on delivery confirmation.
/// Redesigned with the modern Luxury Squircle Bento design system.
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  String? _selectedWilaya;
  String? _confirmedOrderId;
  bool _profileLoaded = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  void _prefillProfile(WidgetRef ref) {
    if (_profileLoaded) return;
    final profileAsync = ref.read(profileProvider);
    profileAsync.whenData((profile) {
      if (profile != null && !_profileLoaded) {
        if (_nameCtrl.text.isEmpty && profile.displayName != null) {
          _nameCtrl.text = profile.displayName!;
        }
        if (_phoneCtrl.text.isEmpty && profile.phone != null) {
          _phoneCtrl.text = profile.phone!;
        }
        if (_selectedWilaya == null && profile.wilaya != null) {
          _selectedWilaya = profile.wilaya;
        }
        _profileLoaded = true;
      }
    });
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
    final inputBg = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : AppColors.backgroundLight;

    _prefillProfile(ref);

    final cart = ref.watch(cartProvider);
    final subtotal = ref.watch(cartTotalProvider);
    final grandTotal = ref.watch(cartGrandTotalProvider);
    final actionsState = ref.watch(orderActionsProvider);

    if (_confirmedOrderId != null) {
      return _buildConfirmedView(
        context,
        _confirmedOrderId!,
        textColor,
        secondaryText,
        isDark,
        lang,
      );
    }

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          const TopAmbientGradient(height: 380),
          SafeArea(
            child: Column(
              children: [
                // ── Integrated Luxury Header ────────────────────────
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                    AppSpacing.screenPaddingH,
                    12,
                    AppSpacing.screenPaddingH,
                    8,
                  ),
                  child: Row(
                    children: [
                      // Back Button
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.pop(context);
                        },
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
                          child: Icon(
                            Icons.arrow_back_rounded,
                            size: 20,
                            color: textColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Checkout Icon Squircle
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
                          Icons.receipt_long_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Title & Subtitle
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.checkoutTitle,
                              style: AppTypography.fromContext(
                                context,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: textColor,
                                letterSpacing: -0.3,
                              ),
                            ),
                            Text(
                              lang == 'ar'
                                  ? 'الدفع كاش عند الاستلام'
                                  : 'Paiement à la livraison',
                              style: AppTypography.fromContext(
                                context,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Trust Flag Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.success.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🇩🇿', style: TextStyle(fontSize: 13)),
                            const SizedBox(width: 4),
                            Text(
                              '58 Wilayas',
                              style: AppTypography.fromContext(
                                context,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                if (actionsState.isLoading)
                  LinearProgressIndicator(
                    minHeight: 2.5,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.coral),
                  ),

                // ── Checkout Form Body ──────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      AppSpacing.screenPaddingH,
                      8,
                      AppSpacing.screenPaddingH,
                      120,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Bento 1: Order Recap ─────────────────
                          _buildSectionTitle(
                            context,
                            lang == 'ar' ? 'ملخص الطلب' : 'Récapitulatif de commande',
                            Icons.shopping_bag_outlined,
                            textColor,
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E2128) : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white12
                                    : AppColors.onSurfaceLight.withValues(alpha: 0.07),
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(
                                    alpha: isDark ? 0.2 : 0.035,
                                  ),
                                  blurRadius: 14,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                ...cart.map((item) => Padding(
                                      padding: const EdgeInsets.only(bottom: 10),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 38,
                                            height: 38,
                                            decoration: BoxDecoration(
                                              color: item.product.category.color
                                                  .withValues(alpha: 0.12),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Icon(
                                              item.product.icon,
                                              size: 18,
                                              color: item.product.category.color,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  item.product.displayName(lang),
                                                  style: AppTypography.fromContext(
                                                    context,
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w700,
                                                    color: textColor,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                Text(
                                                  'Qté: ${item.quantity} × ${_formatDZD(item.product.priceDZD)}',
                                                  style: AppTypography.fromContext(
                                                    context,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w500,
                                                    color: secondaryText,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            _formatDZD(item.lineTotalDZD),
                                            style: AppTypography.fromContext(
                                              context,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w800,
                                              color: textColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                                const Divider(height: 20),
                                _buildPriceRow(
                                  context,
                                  l10n.checkoutSubtotal,
                                  _formatDZD(subtotal),
                                  secondaryText,
                                  textColor,
                                ),
                                const SizedBox(height: 8),
                                _buildPriceRow(
                                  context,
                                  l10n.checkoutShipping,
                                  _formatDZD(marketplaceShippingDZD),
                                  secondaryText,
                                  textColor,
                                  badge: lang == 'ar' ? 'توصيل لباب المنزل' : 'À domicile',
                                ),
                                const Divider(height: 20),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      l10n.labelTotal,
                                      style: AppTypography.fromContext(
                                        context,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: textColor,
                                      ),
                                    ),
                                    Text(
                                      _formatDZD(grandTotal),
                                      style: AppTypography.fromContext(
                                        context,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.coral,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 18),

                          // ── Bento 2: Cash on Delivery Trust Box ──
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(
                                alpha: isDark ? 0.12 : 0.08,
                              ),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: AppColors.success.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: AppColors.success.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(
                                    Icons.payments_rounded,
                                    color: AppColors.success,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        lang == 'ar'
                                            ? 'الدفع كاش عند الاستلام'
                                            : 'Paiement à la livraison',
                                        style: AppTypography.fromContext(
                                          context,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          color: isDark ? Colors.white : AppColors.onSurfaceLight,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        lang == 'ar'
                                            ? 'تدفع ثمن المنتجات نقداً لمندوب التوصيل بعد استلام طلبك والتأكد منه.'
                                            : l10n.checkoutPaymentNote,
                                        style: AppTypography.fromContext(
                                          context,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: secondaryText,
                                          height: 1.35,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 22),

                          // ── Bento 3: Delivery Information ────────
                          _buildSectionTitle(
                            context,
                            l10n.checkoutDeliveryInfo,
                            Icons.local_shipping_outlined,
                            textColor,
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E2128) : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white12
                                    : AppColors.onSurfaceLight.withValues(alpha: 0.07),
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(
                                    alpha: isDark ? 0.2 : 0.035,
                                  ),
                                  blurRadius: 14,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Full Name
                                _buildFormField(
                                  context: context,
                                  label: l10n.name,
                                  hint: l10n.checkoutFullNameHint,
                                  controller: _nameCtrl,
                                  icon: Icons.person_rounded,
                                  inputBg: inputBg,
                                  textColor: textColor,
                                  secondaryText: secondaryText,
                                  isDark: isDark,
                                  validator: (v) => v == null || v.trim().isEmpty
                                      ? l10n.errorRequired
                                      : null,
                                ),
                                const SizedBox(height: 14),

                                // Phone Number
                                _buildFormField(
                                  context: context,
                                  label: l10n.checkoutPhone,
                                  hint: '0550 00 00 00',
                                  controller: _phoneCtrl,
                                  icon: Icons.phone_rounded,
                                  inputBg: inputBg,
                                  textColor: textColor,
                                  secondaryText: secondaryText,
                                  isDark: isDark,
                                  keyboardType: TextInputType.phone,
                                  validator: (v) => _validatePhone(v, l10n),
                                ),
                                const SizedBox(height: 14),

                                // Wilaya Dropdown Picker
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.checkoutWilaya,
                                      style: AppTypography.fromContext(
                                        context,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: textColor,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    DropdownButtonFormField<String>(
                                      initialValue: _selectedWilaya,
                                      decoration: InputDecoration(
                                        hintText: l10n.checkoutWilayaHint,
                                        hintStyle: AppTypography.fromContext(
                                          context,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w400,
                                          color: secondaryText.withValues(alpha: 0.5),
                                        ),
                                        prefixIcon: Icon(
                                          Icons.location_city_rounded,
                                          size: 19,
                                          color: secondaryText,
                                        ),
                                        filled: true,
                                        fillColor: inputBg,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          borderSide: BorderSide(
                                            color: isDark
                                                ? Colors.white12
                                                : Colors.black12,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          borderSide: BorderSide(
                                            color: isDark
                                                ? Colors.white12
                                                : Colors.black12,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          borderSide: const BorderSide(
                                            color: AppColors.coral,
                                            width: 1.5,
                                          ),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 14,
                                        ),
                                      ),
                                      dropdownColor: isDark
                                          ? const Color(0xFF1E2128)
                                          : Colors.white,
                                      icon: const Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: AppColors.coral,
                                      ),
                                      items: algerianWilayas
                                          .map((w) => DropdownMenuItem(
                                                value: w,
                                                child: Text(
                                                  w,
                                                  style:
                                                      AppTypography.fromContext(
                                                    context,
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                    color: textColor,
                                                  ),
                                                ),
                                              ))
                                          .toList(),
                                      onChanged: (val) =>
                                          setState(() => _selectedWilaya = val),
                                      validator: (val) =>
                                          val == null || val.trim().isEmpty
                                              ? l10n.errorRequired
                                              : null,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),

                                // Delivery Address (Street / Commune)
                                _buildFormField(
                                  context: context,
                                  label: l10n.checkoutAddress,
                                  hint: l10n.checkoutAddressHint,
                                  controller: _addressCtrl,
                                  icon: Icons.home_rounded,
                                  inputBg: inputBg,
                                  textColor: textColor,
                                  secondaryText: secondaryText,
                                  isDark: isDark,
                                  maxLines: 2,
                                  validator: (v) => v == null || v.trim().isEmpty
                                      ? l10n.errorRequired
                                      : null,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Pre-shipment Phone Notice
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.04)
                                  : Colors.black.withValues(alpha: 0.025),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isDark ? Colors.white10 : Colors.black12,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.phone_in_talk_rounded,
                                  size: 18,
                                  color: AppColors.casablanca,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    lang == 'ar'
                                        ? 'سيتم الاتصال بك هاتفياً لتأكيد موعد التوصيل قبل إرسال الشحنة.'
                                        : 'Un appel de confirmation vous sera passé avant l\'expédition.',
                                    style: AppTypography.fromContext(
                                      context,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: secondaryText,
                                    ),
                                  ),
                                ),
                              ],
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
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsetsDirectional.fromSTEB(20, 14, 20, 14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E2128) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(
              top: BorderSide(
                color: isDark
                    ? Colors.white12
                    : AppColors.onSurfaceLight.withValues(alpha: 0.08),
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                blurRadius: 20,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: Container(
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryLight.withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: actionsState.isLoading ? null : _onConfirm,
                icon: actionsState.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(
                        Icons.check_circle_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                label: Text(
                  actionsState.isLoading
                      ? (lang == 'ar' ? 'جاري التأكيد...' : 'Confirmation...')
                      : l10n.checkoutConfirm,
                  style: AppTypography.fromContext(
                    context,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
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
        ),
      ),
    );
  }

  Widget _buildSectionTitle(
    BuildContext context,
    String title,
    IconData icon,
    Color textColor,
  ) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.coral),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTypography.fromContext(
            context,
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(
    BuildContext context,
    String label,
    String value,
    Color secondaryText,
    Color textColor, {
    String? badge,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTypography.fromContext(
                context,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: secondaryText,
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badge,
                  style: AppTypography.fromContext(
                    context,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.success,
                  ),
                ),
              ),
            ],
          ],
        ),
        Text(
          value,
          style: AppTypography.fromContext(
            context,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
      ],
    );
  }

  String? _validatePhone(String? value, AppLocalizations l10n) {
    if (value == null || value.trim().isEmpty) {
      return l10n.errorRequired;
    }
    final digits = value.replaceAll(RegExp(r'\s+'), '');
    if (!RegExp(r'^0\d{8,9}$').hasMatch(digits)) {
      return l10n.checkoutPhoneInvalid;
    }
    return null;
  }

  Future<void> _onConfirm() async {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.mediumImpact();

    final lang = Localizations.localeOf(context).languageCode;
    final l10n = context.l10n;

    final orderId = await ref
        .read(orderActionsProvider.notifier)
        .submitOrder(
          items: ref.read(cartProvider),
          fullName: _nameCtrl.text.trim(),
          phone: _phoneCtrl.text.trim(),
          wilaya: _selectedWilaya ?? '',
          address: _addressCtrl.text.trim(),
          locale: lang,
        );

    if (!mounted) return;

    if (orderId != null) {
      HapticFeedback.heavyImpact();
      ref.read(cartProvider.notifier).clear();
      setState(() => _confirmedOrderId = orderId);
    } else {
      final error = ref.read(orderActionsProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? l10n.checkoutErrorGeneric),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Widget _buildConfirmedView(
    BuildContext context,
    String orderId,
    Color textColor,
    Color secondaryText,
    bool isDark,
    String lang,
  ) {
    final l10n = context.l10n;
    final shortId = orderId.length > 8
        ? orderId.substring(orderId.length - 8).toUpperCase()
        : orderId.toUpperCase();

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: Stack(
        children: [
          const TopAmbientGradient(height: 440),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Celebration Checkmark Squircle
                    Container(
                      width: 104,
                      height: 104,
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: AppColors.success.withValues(alpha: 0.35),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.success.withValues(alpha: 0.2),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.check_circle_rounded,
                          size: 60,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Title
                    Text(
                      l10n.checkoutConfirmedTitle,
                      style: AppTypography.fromContext(
                        context,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: textColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),

                    // Subtitle
                    Text(
                      l10n.checkoutConfirmedSubtitle,
                      style: AppTypography.fromContext(
                        context,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: secondaryText,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // Order Reference Bento Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E2128) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark
                              ? Colors.white12
                              : AppColors.onSurfaceLight.withValues(alpha: 0.08),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: isDark ? 0.2 : 0.03,
                            ),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                lang == 'ar' ? 'رقم الطلب:' : 'N° Commande :',
                                style: AppTypography.fromContext(
                                  context,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: secondaryText,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.coral.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '#$shortId',
                                  style: AppTypography.fromContext(
                                    context,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.coral,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 20),
                          Row(
                            children: [
                              const Icon(
                                Icons.phone_callback_rounded,
                                size: 18,
                                color: AppColors.success,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  lang == 'ar'
                                      ? 'سيتواصل معك فريقنا للتأكيد ومتابعة الشحن.'
                                      : 'Notre équipe vous contactera pour valider l\'expédition.',
                                  style: AppTypography.fromContext(
                                    context,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white70 : AppColors.onSurfaceLight,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // View My Orders Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryLight.withValues(alpha: 0.35),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => const MyOrdersScreen(),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.receipt_long_rounded,
                            color: Colors.white,
                            size: 19,
                          ),
                          label: Text(
                            l10n.checkoutViewOrders,
                            style: AppTypography.fromContext(
                              context,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
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
                    const SizedBox(height: 12),

                    // Back Home / Back to Store Button
                    TextButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.of(context).popUntil((r) => r.isFirst);
                      },
                      child: Text(
                        l10n.checkoutBackHome,
                        style: AppTypography.fromContext(
                          context,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: secondaryText,
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
    );
  }

  Widget _buildFormField({
    required BuildContext context,
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    required Color inputBg,
    required Color textColor,
    required Color secondaryText,
    required bool isDark,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.fromContext(
            context,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          style: AppTypography.fromContext(
            context,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.fromContext(
              context,
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: secondaryText.withValues(alpha: 0.5),
            ),
            prefixIcon: Icon(icon, size: 19, color: secondaryText),
            filled: true,
            fillColor: inputBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: isDark ? Colors.white12 : Colors.black12,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: isDark ? Colors.white12 : Colors.black12,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: AppColors.coral,
                width: 1.5,
              ),
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
