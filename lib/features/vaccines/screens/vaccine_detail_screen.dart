import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../models/vaccine.dart';

/// Static rich info for known vaccine codes.
const _vaccineInfo = <String, _VaccineDetail>{
  'BCG': _VaccineDetail(
    description:
        'Le BCG (Bacille Calmette-Guérin) est un vaccin vivant atténué qui protège contre les formes graves de tuberculose, notamment la méningite tuberculeuse chez les nourrissons et les jeunes enfants.',
    howItWorks:
        'Le vaccin stimule le système immunitaire à produire des lymphocytes T spécifiques qui reconnaissent et combattent la bactérie Mycobacterium tuberculosis.',
    sideEffects:
        'Réaction locale au site d\'injection (rougeur, petite plaie), ganglion sous-axillaire bénin. Réactions sévères rares.',
    icon: '🩺',
    color: Color(0xFF4CAF50),
  ),
  'HBV': _VaccineDetail(
    description:
        'Le vaccin contre l\'Hépatite B protège contre une infection virale grave du foie pouvant évoluer vers la cirrhose ou le cancer hépatique. Transmissible par le sang et les fluides corporels.',
    howItWorks:
        'Contient des protéines de surface du virus (Ag HBs). L\'organisme développe des anticorps protecteurs (anti-HBs) sans contact avec le virus vivant.',
    sideEffects:
        'Douleur légère au site d\'injection, légère fièvre possible. Effets graves très rares.',
    icon: '🦠',
    color: Color(0xFF2196F3),
  ),
  'DTCaVPI-Hib-HBV': _VaccineDetail(
    description:
        'Le vaccin hexavalent protège contre 6 maladies en une seule injection : Diphtérie, Tétanos, Coqueluche acellulaire, Poliomyélite inactivée, Haemophilus influenzae type b, et Hépatite B.',
    howItWorks:
        'Combine plusieurs antigènes et toxoïdes pour générer une immunité simultanée contre 6 agents pathogènes, réduisant le nombre total d\'injections requises.',
    sideEffects:
        'Fièvre (fréquente), rougeur et gonflement au site d\'injection. Compresses froides et paracétamol pour soulager.',
    icon: '💉',
    color: Color(0xFFE91E63),
  ),
  'VPOb': _VaccineDetail(
    description:
        'Le vaccin antipoliomyélitique oral (bivalent) protège contre la poliomyélite, maladie paralysante causée par un entérovirus. L\'Algérie vise l\'éradication totale.',
    howItWorks:
        'Virus atténués administrés oralement. Ils se répliquent dans l\'intestin, induisant une immunité mucosale et systémique.',
    sideEffects:
        'Excellente tolérance. Très rarement, poliomyélite associée au vaccin (PVDAV) chez les immunodéprimés.',
    icon: '💊',
    color: Color(0xFF9C27B0),
  ),
  'VPC': _VaccineDetail(
    description:
        'Le vaccin pneumococcique conjugué prévient les infections à Streptococcus pneumoniae, cause majeure de pneumonie, méningite et septicémie chez les enfants de moins de 2 ans.',
    howItWorks:
        'Les antigènes polysaccharidiques sont conjugués à une protéine porteuse pour induire une réponse immunologique robuste chez le nourrisson.',
    sideEffects:
        'Irritabilité, somnolence, perte d\'appétit, fièvre légère. Symptômes transitoires resolving en 1-2 jours.',
    icon: '🫁',
    color: Color(0xFF00BCD4),
  ),
  'ROR': _VaccineDetail(
    description:
        'Le vaccin ROR (Rougeole-Oreillons-Rubéole) est un vaccin trivalent vivant atténué contre trois maladies virales très contagieuses. La rougeole peut causer des complications sévères chez les jeunes enfants.',
    howItWorks:
        'Contient des virus vivants atténués des trois maladies. Induit une immunité durable en un minimum de 2 doses.',
    sideEffects:
        'Légère éruption cutanée, fièvre, gonflement des glandes 5-12 jours après. Réactions allergiques sévères très rares.',
    icon: '🤧',
    color: Color(0xFFFF5722),
  ),
  'DTCa-VPI': _VaccineDetail(
    description:
        'Le rappel scolaire tétravalent renforce l\'immunité acquise dans l\'enfance contre Diphtérie, Tétanos, Coqueluche et Poliomyélite, avant l\'entrée à l\'école primaire.',
    howItWorks:
        'Dose de rappel qui booste les anticorps existants. Particulièrement important car l\'immunité de la petite enfance peut diminuer avec le temps.',
    sideEffects:
        'Réaction locale au site d\'injection, légère fatigue. Très bien toléré.',
    icon: '🏫',
    color: Color(0xFF607D8B),
  ),
  'dT': _VaccineDetail(
    description:
        'Le vaccin bivalent adulte renforce la protection contre le Tétanos et la Diphtérie, deux maladies potentiellement mortelles. Le rappel décennal maintient une immunité optimale tout au long de la vie.',
    howItWorks:
        'Contient des toxoïdes tétanique et diphtérique — formes inactivées des toxines — qui stimulent la production d\'anticorps neutralisants.',
    sideEffects:
        'Rougeur et sensibilité au point d\'injection, légère fatigue. Effets systémiques rares.',
    icon: '🛡️',
    color: Color(0xFF795548),
  ),
};

class _VaccineDetail {
  const _VaccineDetail({
    required this.description,
    required this.howItWorks,
    required this.sideEffects,
    required this.icon,
    required this.color,
  });

  final String description;
  final String howItWorks;
  final String sideEffects;
  final String icon;
  final Color color;
}

/// Detail screen for a single vaccine, showing rich educational content.
class VaccineDetailScreen extends StatelessWidget {
  const VaccineDetailScreen({super.key, required this.vaccine});

  final Vaccine vaccine;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;
    final surface = isDark ? AppColors.surfaceDark : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.onSurfaceLight;
    final secondaryText = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    final info = _vaccineInfo[vaccine.code];
    final accentColor = info?.color ?? AppColors.primaryLight;
    final emoji = info?.icon ?? '💉';

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        slivers: [
          // Hero header
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: accentColor,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accentColor, accentColor.withValues(alpha: 0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    // Background pattern overlay
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.06,
                        child: Image.asset(
                          'assets/images/heroPatern.png',
                          fit: BoxFit.cover,
                          repeat: ImageRepeat.repeat,
                        ),
                      ),
                    ),
                    // Content
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 80, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(emoji, style: const TextStyle(fontSize: 40)),
                          const SizedBox(height: 8),
                          Text(
                            vaccine.code,
                            style: GoogleFonts.outfit(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            vaccine.nameFr,
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.85),
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

          // Body
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Protects chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.shield_rounded,
                          size: 16,
                          color: accentColor,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Protège contre : ${vaccine.protectsFr}',
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: accentColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Description
                  if (info != null) ...[
                    _InfoSection(
                      icon: Icons.info_outline_rounded,
                      title: 'À quoi sert ce vaccin ?',
                      content: info.description,
                      accentColor: accentColor,
                      surface: surface,
                      textColor: textColor,
                      secondaryText: secondaryText,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),
                    _InfoSection(
                      icon: Icons.biotech_rounded,
                      title: 'Comment fonctionne-t-il ?',
                      content: info.howItWorks,
                      accentColor: accentColor,
                      surface: surface,
                      textColor: textColor,
                      secondaryText: secondaryText,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),
                    _InfoSection(
                      icon: Icons.healing_rounded,
                      title: 'Effets secondaires possibles',
                      content: info.sideEffects,
                      accentColor: accentColor,
                      surface: surface,
                      textColor: textColor,
                      secondaryText: secondaryText,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'Ce vaccin fait partie du calendrier vaccinal national algérien. Consultez votre pédiatre pour plus d\'informations.',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          color: secondaryText,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Disclaimer
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.amber.withValues(alpha: 0.1)
                          : Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.amber.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          size: 18,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Ces informations sont à titre éducatif uniquement. Consultez toujours votre médecin ou pédiatre avant toute décision médicale.',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: isDark
                                  ? Colors.amber.shade200
                                  : Colors.amber.shade900,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({
    required this.icon,
    required this.title,
    required this.content,
    required this.accentColor,
    required this.surface,
    required this.textColor,
    required this.secondaryText,
    required this.isDark,
  });

  final IconData icon;
  final String title;
  final String content;
  final Color accentColor;
  final Color surface;
  final Color textColor;
  final Color secondaryText;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: accentColor),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: GoogleFonts.outfit(
              fontSize: 13,
              color: secondaryText,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
