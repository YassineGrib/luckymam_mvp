import 'package:firebase_auth/firebase_auth.dart';
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
import '../../subscription/providers/subscription_providers.dart';
import '../models/print_order.dart';
import '../providers/print_order_providers.dart';

/// Redesigned flagship Print Order Screen for LuckyMam.
/// Matches the luxury Squircle Bento identity of the new checkout screen:
/// - Top ambient illumination and integrated boutique navigation
/// - Automatic profile pre-fill (name, phone, wilaya)
/// - 58 Algerian Wilayas Dropdown selector with input validation
/// - Luxury Order Recap Bento with VIP perk detection
/// - Cash-on-delivery & VIP packaging trust card
/// - Luxury form fields with matching radii and focus borders
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
  final _addressCtrl = TextEditingController();
  String? _selectedWilaya;
  bool _profileLoaded = false;
  bool _submitted = false;

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
    final isRtl = context.isRtl;
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

    final isVip = ref.watch(isVipProvider);
    final actionsState = ref.watch(printOrderActionsProvider);

    if (_submitted) {
      return _buildSubmittedView(context, textColor, secondaryText, isDark, lang);
    }

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // ── Ambient Lighting ──
          const TopAmbientGradient(height: 380),

          SafeArea(
            child: Column(
              children: [
                // ── Integrated Luxury Header ──
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPaddingH,
                    vertical: 8,
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
                                : Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white12
                                  : const Color(0xFFE8E0E4),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(
                                  alpha: isDark ? 0.25 : 0.04,
                                ),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            isRtl
                                ? Icons.arrow_forward_ios_rounded
                                : Icons.arrow_back_ios_new_rounded,
                            size: 16,
                            color: textColor,
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isRtl ? 'تأكيد طلب الطباعة' : 'Commande d\'impression',
                              style: AppTypography.fromContext(
                                context,
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isRtl
                                  ? 'توصيل مباشر لباب منزلكِ عبر 58 ولاية'
                                  : 'Livraison à domicile dans 58 wilayas',
                              style: AppTypography.fromContext(
                                context,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                color: secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 58 Wilayas Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
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
                            const Text('🇩🇿', style: TextStyle(fontSize: 12)),
                            const SizedBox(width: 4),
                            Text(
                              '58 Wilayas',
                              style: AppTypography.fromContext(
                                context,
                                fontSize: 10.5,
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

                // ── Form Body ──
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
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
                          // ── Bento 1: Print Order Recap ──
                          _buildSectionTitle(
                            context,
                            isRtl ? 'ملخص الألبوم الورقي' : 'Détails de l\'album',
                            Icons.auto_stories_rounded,
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
                                Row(
                                  children: [
                                    Container(
                                      width: 46,
                                      height: 46,
                                      decoration: BoxDecoration(
                                        gradient: AppColors.primaryGradient,
                                        borderRadius: BorderRadius.circular(14),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.primaryLight.withValues(alpha: 0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.auto_stories_rounded,
                                        size: 24,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            widget.albumTitle,
                                            style: AppTypography.fromContext(
                                              context,
                                              fontSize: 14.5,
                                              fontWeight: FontWeight.w800,
                                              color: textColor,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            l10n.printAlbumSummary(
                                              widget.pageCount,
                                              widget.childName,
                                            ),
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
                                  ],
                                ),
                                const Divider(height: 22),
                                // Quality specs
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.photo_filter_rounded,
                                      size: 15,
                                      color: Color(0xFFD97706),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      isRtl
                                          ? 'ورق حريري 250 جم • تجليد مقوى مقاوم للماء'
                                          : 'Papier Soie 250g • Couverture rigide étanche',
                                      style: AppTypography.fromContext(
                                        context,
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w600,
                                        color: secondaryText,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                // VIP Status / Price Row
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      isRtl ? 'تكلفة الطباعة والشحن:' : 'Frais d\'impression :',
                                      style: AppTypography.fromContext(
                                        context,
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                        color: textColor,
                                      ),
                                    ),
                                    if (isVip)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.success.withValues(alpha: 0.14),
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(
                                            color: AppColors.success.withValues(alpha: 0.35),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Text('👑', style: TextStyle(fontSize: 12)),
                                            const SizedBox(width: 4),
                                            Text(
                                              isRtl
                                                  ? 'مشمول مجاناً في باقة VIP'
                                                  : 'Inclus VIP (0 DZD)',
                                              style: AppTypography.fromContext(
                                                context,
                                                fontSize: 11.5,
                                                fontWeight: FontWeight.w800,
                                                color: AppColors.success,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    else
                                      Text(
                                        isRtl
                                          ? 'تأكيد السعر هاتفياً (الدفع عند الاستلام)'
                                          : 'Confirmation par téléphone',
                                        style: AppTypography.fromContext(
                                          context,
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.coral,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 18),

                          // ── Bento 2: Trust Card ──
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
                                  child: Icon(
                                    isVip
                                        ? Icons.card_giftcard_rounded
                                        : Icons.local_shipping_rounded,
                                    color: AppColors.success,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        isVip
                                            ? (isRtl ? 'هدية اشتراككِ الملكي VIP' : 'Avantage Membre VIP')
                                            : (isRtl ? 'توصيل لباب المنزل والدفع عند الاستلام' : 'Paiement à la livraison'),
                                        style: AppTypography.fromContext(
                                          context,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          color: isDark ? Colors.white : AppColors.onSurfaceLight,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        isVip ? l10n.printVipFreeNote : l10n.printPricingNote,
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

                          // ── Bento 3: Delivery Information ──
                          _buildSectionTitle(
                            context,
                            l10n.checkoutDeliveryInfo,
                            Icons.location_on_outlined,
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

                                // 58 Algerian Wilayas Dropdown
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
                                                  style: AppTypography.fromContext(
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

                          const SizedBox(height: 16),

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
                                    isRtl
                                        ? 'سيتم الاتصال بكِ هاتفياً لتأكيد تفاصيل العنوان قبل إرسال شحنة الألبوم.'
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

          // ── Fixed Bottom Confirm Bar ──
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A1620) : Colors.white,
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.06),
                    width: 1,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                    blurRadius: 18,
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
                    onPressed: actionsState.isLoading ? null : _onSubmit,
                    icon: actionsState.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(
                            Icons.check_circle_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                    label: Text(
                      actionsState.isLoading
                          ? (isRtl ? 'جاري تأكيد الطلب...' : 'Confirmation...')
                          : (isRtl ? 'تأكيد طلب طباعة الألبوم' : l10n.checkoutConfirm),
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
        ],
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

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    HapticFeedback.mediumImpact();
    final l10n = context.l10n;
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
      wilaya: _selectedWilaya ?? '',
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
          content: Text(error ?? l10n.checkoutErrorGeneric),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      ref.read(printOrderActionsProvider.notifier).clearMessages();
    }
  }

  Widget _buildSubmittedView(
    BuildContext context,
    Color textColor,
    Color secondaryText,
    bool isDark,
    String lang,
  ) {
    final l10n = context.l10n;

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
                      l10n.printOrderSentTitle,
                      style: AppTypography.fromContext(
                        context,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      l10n.printOrderSentMessage(widget.albumTitle),
                      style: AppTypography.fromContext(
                        context,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w500,
                        color: secondaryText,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    // Delivery Timeline Pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.magentaPink.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.magentaPink.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.local_shipping_rounded,
                            color: AppColors.magentaPink,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            l10n.printEstimatedDelay,
                            style: AppTypography.fromContext(
                              context,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.magentaPink,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Return Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryLight.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
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
                            l10n.printBackToAlbum,
                            style: AppTypography.fromContext(
                              context,
                              fontSize: 15.5,
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
        ],
      ),
    );
  }
}
