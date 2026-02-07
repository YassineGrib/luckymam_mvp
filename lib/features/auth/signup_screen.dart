import 'package:flutter/material.dart';
import 'package:lukymam_mvp/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../shared/widgets/buttons/primary_button.dart';
import '../../shared/widgets/buttons/social_button.dart';
import '../../shared/widgets/inputs/app_text_field.dart';

/// Sign Up screen matching the reference dark UI design.
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _rememberMe = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    final authService = AuthService();
    final result = await authService.signUpWithEmailAndPassword(
      name: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (result.isSuccess) {
      // Navigate to home/dashboard on success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bienvenue ${result.user?.displayName ?? ""}!'),
          backgroundColor: Colors.green,
        ),
      );
      // TODO: Navigate to dashboard
      // context.go('/home');
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.errorMessage ?? 'Erreur inconnue'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.onSurfaceLight;
    final secondaryColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => context.go('/login'),
        ),
        title: Text(l10n.appName),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.lg),

                // Title
                Text(
                  l10n.signUpTitle,
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Name Field
                AppTextField(
                  controller: _nameController,
                  label: l10n.name,
                  hint: l10n.nameHint,
                  keyboardType: TextInputType.name,
                  prefixIcon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.errorRequired;
                    }
                    if (value.length < 2) {
                      return l10n.errorNameTooShort;
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.inputGap),

                // Email Field
                AppTextField(
                  controller: _emailController,
                  label: l10n.email,
                  hint: l10n.emailHint,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.errorRequired;
                    }
                    if (!value.contains('@')) {
                      return l10n.errorInvalidEmail;
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.inputGap),

                // Password Field
                AppTextField(
                  controller: _passwordController,
                  label: l10n.password,
                  isPassword: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.errorRequired;
                    }
                    if (value.length < 8) {
                      return l10n.errorPasswordTooShort;
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.inputGap),

                // Confirm Password Field
                AppTextField(
                  controller: _confirmPasswordController,
                  label: l10n.confirmPassword,
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  onSubmitted: _handleSignUp,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.errorRequired;
                    }
                    if (value != _passwordController.text) {
                      return l10n.errorPasswordsDoNotMatch;
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.md),

                // Remember Me
                Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _rememberMe,
                        onChanged: (value) {
                          setState(() => _rememberMe = value ?? false);
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        side: BorderSide(color: secondaryColor),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.rememberMe,
                      style: TextStyle(fontSize: 13, color: secondaryColor),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.lg),

                // Sign Up Button
                PrimaryButton(
                  text: l10n.signUp,
                  onPressed: _handleSignUp,
                  isLoading: _isLoading,
                ),

                const SizedBox(height: AppSpacing.lg),

                // OR Divider
                _OrDivider(text: l10n.or),

                const SizedBox(height: AppSpacing.lg),

                // Social Buttons
                SocialButton.google(
                  text: l10n.signInWithGoogle,
                  onPressed: () {
                    // TODO: Google Sign In
                  },
                ),

                const SizedBox(height: AppSpacing.sm),

                SocialButton.apple(
                  text: l10n.signInWithApple,
                  onPressed: () {
                    // TODO: Apple Sign In
                  },
                ),

                const SizedBox(height: AppSpacing.xl),

                // Login Link
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.alreadyHaveAccount,
                        style: TextStyle(color: secondaryColor, fontSize: 14),
                      ),
                      const SizedBox(width: 4),
                      TextButton(
                        onPressed: () => context.go('/login'),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          l10n.login,
                          style: TextStyle(
                            color: isDark
                                ? AppColors.primaryDark
                                : AppColors.primaryLight,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Divider with "OR" text in the middle.
class _OrDivider extends StatelessWidget {
  const _OrDivider({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dividerColor = isDark
        ? AppColors.dividerDark
        : AppColors.dividerLight;
    final textColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return Row(
      children: [
        Expanded(child: Divider(color: dividerColor)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(text, style: TextStyle(color: textColor, fontSize: 13)),
        ),
        Expanded(child: Divider(color: dividerColor)),
      ],
    );
  }
}
