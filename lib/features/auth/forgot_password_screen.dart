import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/l10n_extension.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../shared/widgets/inputs/app_text_field.dart';
import '../../shared/widgets/auth_logo_background.dart';
import '../../shared/widgets/top_ambient_gradient.dart';

/// Flagship screen for recovering a forgotten password.
/// Features a warm, reassuring aesthetic with live countdown resend mechanics.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key, this.initialEmail});

  final String? initialEmail;

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;

  bool _isLoading = false;
  bool _emailSent = false;
  int _cooldownSeconds = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail ?? '');
  }

  @override
  void dispose() {
    _timer?.cancel();
    _emailController.dispose();
    super.dispose();
  }

  void _startCooldown([int seconds = 60]) {
    setState(() {
      _cooldownSeconds = seconds;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_cooldownSeconds > 1) {
        setState(() => _cooldownSeconds--);
      } else {
        timer.cancel();
        setState(() => _cooldownSeconds = 0);
      }
    });
  }

  Future<void> _handleSendResetLink() async {
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.heavyImpact();
      return;
    }

    final email = _emailController.text.trim();
    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    try {
      final authService = ref.read(authServiceProvider);
      final result = await authService.sendPasswordResetEmail(email);

      if (mounted) {
        if (result.isSuccess) {
          HapticFeedback.lightImpact();
          setState(() {
            _emailSent = true;
          });
          _startCooldown(60);
        } else {
          HapticFeedback.heavyImpact();
          final lang = Localizations.localeOf(context).languageCode;
          String msg = result.errorMessage ?? 'Erreur';
          if (lang == 'ar') {
            if (msg.contains('Aucun compte trouvé') || msg.contains('user-not-found')) {
              msg = 'لم نجد أي حساب مسجل بهذا البريد الإلكتروني';
            } else if (msg.contains('E-mail invalide') || msg.contains('invalid-email')) {
              msg = 'صيغة البريد الإلكتروني غير صحيحة';
            } else if (msg.contains('Trop de tentatives') || msg.contains('too-many-requests')) {
              msg = 'محاولات كثيرة جداً، يرجى الانتظار قليلاً';
            } else if (msg.contains('connexion réseau') || msg.contains('network')) {
              msg = 'تعذر الاتصال بالإنترنت، تفقدِ اتصالكِ';
            }
          } else if (lang == 'en') {
            if (msg.contains('Aucun compte trouvé') || msg.contains('user-not-found')) {
              msg = 'No account found with this email address';
            } else if (msg.contains('E-mail invalide') || msg.contains('invalid-email')) {
              msg = 'Invalid email address format';
            } else if (msg.contains('Trop de tentatives') || msg.contains('too-many-requests')) {
              msg = 'Too many attempts. Please try again later';
            } else if (msg.contains('connexion réseau') || msg.contains('network')) {
              msg = 'Network error. Please check your connection';
            }
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(msg),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
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
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = Localizations.localeOf(context);
    final lang = locale.languageCode;
    final isAr = lang == 'ar';
    final isEn = lang == 'en';
    final isRtl = isAr;

    final bgColor = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final surfaceColor = isDark ? const Color(0xFF221A24) : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.onSurfaceLight;
    final secondaryText = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final accent = isDark ? AppColors.primaryDark : AppColors.primaryLight;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // ── 1. Atmospheric Ambient Glow ──
          const TopAmbientGradient(height: 380),

          // ── 2. Subtle Watermark Logo ──
          const AuthLogoBackground(lightOpacity: 0.05, darkOpacity: 0.03),

          // ── 3. Main Screen Flow ──
          Positioned.fill(
            child: SafeArea(
              child: Column(
                children: [
                  // Top Back Action Header Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenPaddingH,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go('/login');
                            }
                          },
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
                        Text(
                          isAr ? 'العودة' : (isEn ? 'Back' : 'Retour'),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Scrollable Body
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.screenPaddingH,
                        vertical: 16,
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 350),
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.05),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: _emailSent
                            ? _buildSuccessView(
                                isDark: isDark,
                                surfaceColor: surfaceColor,
                                textColor: textColor,
                                secondaryText: secondaryText,
                                accent: accent,
                                isAr: isAr,
                                isEn: isEn,
                              )
                            : _buildFormView(
                                isDark: isDark,
                                surfaceColor: surfaceColor,
                                textColor: textColor,
                                secondaryText: secondaryText,
                                accent: accent,
                                isAr: isAr,
                                isEn: isEn,
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  // Form State: Enter Email & Submit
  // ═════════════════════════════════════════════════════════════════════════

  Widget _buildFormView({
    required bool isDark,
    required Color surfaceColor,
    required Color textColor,
    required Color secondaryText,
    required Color accent,
    required bool isAr,
    required bool isEn,
  }) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),

          // Glowing Lock Icon Badge
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  accent.withValues(alpha: 0.18),
                  accent.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: accent.withValues(alpha: 0.35), width: 2),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                Icons.lock_reset_rounded,
                size: 40,
                color: accent,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Title
          Text(
            isAr
                ? 'نسيتِ كلمة المرور؟'
                : (isEn ? 'Forgot Password?' : 'Mot de passe oublié ?'),
            textAlign: TextAlign.center,
            style: AppTypography.fromContext(
              context,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: textColor,
            ),
          ),

          const SizedBox(height: 10),

          // Subtitle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              isAr
                  ? 'لا تقلقي! أدخلي بريدكِ الإلكتروني وسنرسل لكِ رابطاً آمناً لإعادة تعيين كلمة مرور جديدة لحسابكِ.'
                  : (isEn
                      ? 'Don\'t worry! Enter your account email to receive a secure link to reset your password.'
                      : 'Ne vous inquiétez pas ! Entrez l\'adresse e-mail de votre compte pour recevoir un lien sécurisé.'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                height: 1.5,
                color: secondaryText,
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Email Input Card
          Container(
            padding: const EdgeInsets.all(20),
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
                Text(
                  isAr
                      ? 'البريد الإلكتروني'
                      : (isEn ? 'Email address' : 'Adresse e-mail'),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: secondaryText,
                  ),
                ),
                const SizedBox(height: 8),
                AppTextField(
                  controller: _emailController,
                  label: '',
                  hint: isAr ? 'example@gmail.com' : 'example@gmail.com',
                  prefixIcon: Icons.alternate_email_rounded,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  onSubmitted: _handleSendResetLink,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return isAr
                          ? 'يرجى إدخال البريد الإلكتروني'
                          : (isEn
                              ? 'Please enter your email'
                              : 'Veuillez saisir votre e-mail');
                    }
                    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                    if (!emailRegex.hasMatch(value.trim())) {
                      return isAr
                          ? 'صيغة البريد الإلكتروني غير صحيحة'
                          : (isEn
                              ? 'Invalid email format'
                              : 'Format d\'e-mail invalide');
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: GestureDetector(
              onTap: _isLoading ? null : _handleSendResetLink,
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
                    if (_isLoading)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                      )
                    else ...[
                      const Icon(Icons.send_rounded, size: 18, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        isAr
                            ? 'إرسال رابط الاستعادة'
                            : (isEn ? 'Send Reset Link' : 'Envoyer le lien'),
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

          const SizedBox(height: 24),

          // Return to Login Link
          GestureDetector(
            onTap: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/login');
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isAr
                        ? 'تذكرتِ كلمة المرور؟ '
                        : (isEn ? 'Remember your password? ' : 'Vous vous en souvenez ? '),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: secondaryText,
                    ),
                  ),
                  Text(
                    isAr
                        ? 'تسجيل الدخول'
                        : (isEn ? 'Sign In' : 'Se connecter'),
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: accent,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  // Success State: Link Sent & Instructions
  // ═════════════════════════════════════════════════════════════════════════

  Widget _buildSuccessView({
    required bool isDark,
    required Color surfaceColor,
    required Color textColor,
    required Color secondaryText,
    required Color accent,
    required bool isAr,
    required bool isEn,
  }) {
    final email = _emailController.text.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 20),

        // Glowing Success Check Icon
        Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF00C853), Color(0xFF69F0AE)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00C853).withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.mark_email_read_rounded,
              size: 42,
              color: Colors.white,
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Success Title
        Text(
          isAr
              ? 'تم إرسال الرابط بنجاح! 💌'
              : (isEn ? 'Email Sent Successfully! 💌' : 'E-mail envoyé avec succès ! 💌'),
          textAlign: TextAlign.center,
          style: AppTypography.fromContext(
            context,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: textColor,
          ),
        ),

        const SizedBox(height: 12),

        // Email destination card
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: accent.withValues(alpha: 0.2)),
          ),
          child: Text(
            email,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: accent,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Instructions
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            isAr
                ? 'يرجى فتح بريدكِ الإلكتروني والضغط على الرابط المرسل لإعادة تعيين كلمة المرور الجديدة.'
                : (isEn
                    ? 'Please check your inbox and tap the secure link to set your new password.'
                    : 'Veuillez consulter votre boîte de réception et cliquer sur le lien sécurisé pour définir un nouveau mot de passe.'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              height: 1.5,
              color: secondaryText,
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Spam Tip Box
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF9F7F8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white10 : const Color(0xFFECE4E8),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline_rounded, size: 20, color: Color(0xFFFF9100)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isAr
                      ? 'ملاحظة: إذا لم تجدي الرسالة في صندوق الوارد، تفقدِ مجلد الرسائل غير المرغوب فيها (Spam / Courrier indésirable).'
                      : (isEn
                          ? 'Note: If you do not see the email, please check your Spam or Junk folder.'
                          : 'Remarque : Si vous ne trouvez pas l\'e-mail, pensez à vérifier votre dossier Spam ou Courrier indésirable.'),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                    color: secondaryText,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Back to Login Primary Button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: GestureDetector(
            onTap: () => context.go('/login'),
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
                  const Icon(Icons.login_rounded, size: 18, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    isAr
                        ? 'العودة لتسجيل الدخول'
                        : (isEn ? 'Back to Sign In' : 'Retour à la connexion'),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Resend Button with Cooldown
        TextButton(
          onPressed: _cooldownSeconds > 0 || _isLoading ? null : _handleSendResetLink,
          child: Text(
            _cooldownSeconds > 0
                ? (isAr
                    ? 'إعادة الإرسال بعد $_cooldownSeconds ثانية'
                    : (isEn
                        ? 'Resend in ${_cooldownSeconds}s'
                        : 'Renvoyer dans ${_cooldownSeconds}s'))
                : (isAr
                    ? 'لم تستلمي الرابط؟ إعادة الإرسال'
                    : (isEn
                        ? 'Didn\'t receive the link? Resend'
                        : 'Vous n\'avez rien reçu ? Renvoyer')),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _cooldownSeconds > 0 ? secondaryText : accent,
            ),
          ),
        ),
      ],
    );
  }
}
