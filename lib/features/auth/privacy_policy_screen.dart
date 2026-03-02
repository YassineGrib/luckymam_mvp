import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

/// Full Privacy Policy & Terms of Use screen.
/// Accessible from the signup consent mention and from profile settings.
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;
    final textColor = isDark
        ? AppColors.onSurfaceDark
        : AppColors.onSurfaceLight;
    final secondaryColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final cardColor = isDark ? AppColors.surfaceDark : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: textColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Confidentialité & CGU',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.shield_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Vos données nous tiennent à cœur',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Dernière mise à jour : 1er mars 2026',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // ── POLITIQUE DE CONFIDENTIALITÉ ─────────────────────────────
            _SectionTitle(
              icon: Icons.lock_outline_rounded,
              title: 'Politique de Confidentialité',
              color: AppColors.magentaPink,
              textColor: textColor,
            ),

            _PolicyCard(
              cardColor: cardColor,
              secondaryColor: secondaryColor,
              textColor: textColor,
              title: '1. Données collectées',
              content:
                  'Lorsque vous créez un compte Luckymam, nous collectons :\n\n'
                  '• Votre nom et adresse e-mail\n'
                  '• Votre date du terme (grossesse)\n'
                  '• La date de naissance de votre bébé\n'
                  '• Les informations relatives à vos enfants (prénom, date de naissance)\n'
                  '• Les capsules photos et moments de vie que vous choisissez de partager\n'
                  '• Les données de santé saisies volontairement (vaccins, suivi médical)',
            ),

            _PolicyCard(
              cardColor: cardColor,
              secondaryColor: secondaryColor,
              textColor: textColor,
              title: '2. Utilisation de vos données',
              content:
                  'Vos données sont utilisées exclusivement pour :\n\n'
                  '• Vous fournir les fonctionnalités de l\'application (Timeline, Capsules, Vaccins)\n'
                  '• Personnaliser votre expérience selon votre profil maternel\n'
                  '• Vous envoyer des rappels et notifications pertinents\n'
                  '• Améliorer nos services de manière anonyme et agrégée\n\n'
                  'Nous ne vendons ni ne partageons jamais vos données personnelles avec des tiers à des fins commerciales.',
            ),

            _PolicyCard(
              cardColor: cardColor,
              secondaryColor: secondaryColor,
              textColor: textColor,
              title: '3. Stockage & Sécurité',
              content:
                  'Vos données sont stockées de manière sécurisée sur des serveurs Firebase '
                  '(Google Cloud Platform), certifiés ISO 27001 et conformes au RGPD.\n\n'
                  '• Chiffrement en transit (TLS 1.3) et au repos (AES-256)\n'
                  '• Accès restreint à votre seul compte via authentification sécurisée\n'
                  '• Sauvegardes automatiques chiffrées',
            ),

            _PolicyCard(
              cardColor: cardColor,
              secondaryColor: secondaryColor,
              textColor: textColor,
              title: '4. Vos droits (RGPD)',
              content:
                  'Conformément au Règlement Général sur la Protection des Données, vous disposez des droits suivants :\n\n'
                  '• Droit d\'accès à vos données personnelles\n'
                  '• Droit de rectification des données inexactes\n'
                  '• Droit à l\'effacement (« droit à l\'oubli »)\n'
                  '• Droit à la portabilité de vos données\n'
                  '• Droit d\'opposition au traitement\n\n'
                  'Pour exercer ces droits : privacy@luckymam.com',
            ),

            _PolicyCard(
              cardColor: cardColor,
              secondaryColor: secondaryColor,
              textColor: textColor,
              title: '5. Conservation des données',
              content:
                  'Vos données sont conservées tant que votre compte est actif. '
                  'En cas de suppression du compte, toutes vos données personnelles sont '
                  'effacées dans un délai de 30 jours.\n\n'
                  'Vous pouvez demander la suppression depuis : '
                  'Profil → Paramètres → Supprimer mon compte.',
            ),

            const SizedBox(height: AppSpacing.xl),

            // ── CONDITIONS D'UTILISATION ─────────────────────────────────
            _SectionTitle(
              icon: Icons.gavel_rounded,
              title: "Conditions d'Utilisation",
              color: AppColors.smaltBlue,
              textColor: textColor,
            ),

            _PolicyCard(
              cardColor: cardColor,
              secondaryColor: secondaryColor,
              textColor: textColor,
              title: '1. Acceptation des conditions',
              content:
                  'En créant un compte et en utilisant l\'application Luckymam, '
                  'vous acceptez les présentes conditions d\'utilisation dans leur intégralité. '
                  'Si vous n\'acceptez pas ces conditions, veuillez ne pas utiliser l\'application.',
            ),

            _PolicyCard(
              cardColor: cardColor,
              secondaryColor: secondaryColor,
              textColor: textColor,
              title: '2. Description du service',
              content:
                  'Luckymam est une application mobile dédiée à accompagner les mamans '
                  'dans leur parcours de maternité. Elle propose :\n\n'
                  '• La création et conservation de capsules photo de vie\n'
                  '• Le suivi de la Timeline des moments importants\n'
                  '• Le suivi des vaccinations de l\'enfant\n'
                  '• L\'accès à des Reels éducatifs sur la grossesse et la maternité\n'
                  '• Des fonctionnalités premium et VIP sur abonnement',
            ),

            _PolicyCard(
              cardColor: cardColor,
              secondaryColor: secondaryColor,
              textColor: textColor,
              title: '3. Responsabilités',
              content:
                  'Luckymam n\'est pas un service médical et ne remplace pas l\'avis d\'un professionnel de santé. '
                  'Les informations fournies (calendrier vaccinal, conseils de grossesse) sont '
                  'données à titre indicatif uniquement.\n\n'
                  'Vous êtes responsable de la confidentialité de vos identifiants de connexion '
                  'et de l\'exactitude des informations que vous saisissez.',
            ),

            _PolicyCard(
              cardColor: cardColor,
              secondaryColor: secondaryColor,
              textColor: textColor,
              title: '4. Abonnements & Facturation',
              content:
                  'Luckymam propose trois niveaux d\'accès :\n\n'
                  '• Gratuit : fonctionnalités de base\n'
                  '• Prémium : 2 490 DA/an — accès à toutes les fonctionnalités avancées\n'
                  '• VIP : 9 890 DA/an — carte VIP personnalisée + partenaires exclusifs\n\n'
                  'Les abonnements sont renouvelés automatiquement. '
                  'Vous pouvez annuler à tout moment depuis votre espace abonnement.',
            ),

            _PolicyCard(
              cardColor: cardColor,
              secondaryColor: secondaryColor,
              textColor: textColor,
              title: '5. Modifications',
              content:
                  'Luckymam se réserve le droit de modifier ces conditions à tout moment. '
                  'Toute modification sera notifiée par e-mail et dans l\'application. '
                  'L\'utilisation continue de l\'application après notification vaut acceptation des nouvelles conditions.',
            ),

            const SizedBox(height: AppSpacing.xl),

            // Contact block
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? AppColors.dividerDark
                      : AppColors.dividerLight,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.mail_outline_rounded,
                    color: AppColors.magentaPink,
                    size: 28,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Des questions ?',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Contactez-nous à privacy@luckymam.com',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: secondaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.color,
    required this.textColor,
  });

  final IconData icon;
  final String title;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _PolicyCard extends StatelessWidget {
  const _PolicyCard({
    required this.cardColor,
    required this.secondaryColor,
    required this.textColor,
    required this.title,
    required this.content,
  });

  final Color cardColor;
  final Color secondaryColor;
  final Color textColor;
  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            content,
            style: GoogleFonts.outfit(
              fontSize: 13,
              color: secondaryColor,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
