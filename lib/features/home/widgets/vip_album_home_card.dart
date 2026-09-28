import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_typography.dart';
import '../../memory_book/data/album_templates_data.dart';
import '../../memory_book/models/album_template.dart';
import '../../memory_book/models/predefined_album.dart';
import '../../memory_book/models/standard_album.dart';
import '../../memory_book/providers/predefined_album_providers.dart';
import '../../memory_book/providers/standard_album_providers.dart';
import '../../memory_book/screens/album_template_picker_screen.dart';
import '../../memory_book/screens/memory_book_screen.dart';
import '../../memory_book/screens/predefined_album_detail_screen.dart';
import '../../memory_book/screens/standard_album_detail_screen.dart';
import '../../profile/models/profile_models.dart';
import '../../profile/providers/profile_providers.dart';
import '../../subscription/providers/subscription_providers.dart';

/// Flagship VIP Album Card displayed at the bottom of the Home screen
/// exclusively for VIP subscribers.
///
/// Features:
/// - Replaces the upgrade prompt banner when user is on the VIP tier.
/// - Tactile 3D hardcover children's photobook preview with spine and ribbon bookmark.
/// - Dynamic album detection: automatically showcases the user's latest PredefinedAlbum
///   or StandardAlbum with real-time memory completion progress (e.g. 6/12 slots).
/// - If no album is created yet, showcases the VIP Free Printed Album perk and
///   launches the template picker in 1 tap.
/// - Tapping the card opens the album details screen with book flip mode, photo gallery,
///   and print ordering.
class VipAlbumHomeCard extends ConsumerWidget {
  const VipAlbumHomeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isVip = ref.watch(isVipProvider);
    if (!isVip) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final lang = Localizations.localeOf(context).languageCode;

    final predefinedAlbumsAsync = ref.watch(allPredefinedAlbumsProvider);
    final standardAlbumsAsync = ref.watch(allStandardAlbumsProvider);
    final childrenAsync = ref.watch(childrenProvider);
    final claimAsync = ref.watch(latestAlbumClaimProvider);

    final children = childrenAsync.valueOrNull ?? [];
    final predefinedAlbums = predefinedAlbumsAsync.valueOrNull ?? [];
    final standardAlbums = standardAlbumsAsync.valueOrNull ?? [];
    final latestClaim = claimAsync.valueOrNull;

    // ── VIP Royal Amber / Gold luxury palette ──
    final bg = isDark ? const Color(0xFF221A12) : const Color(0xFFFFFDF8);
    final borderColor = isDark
        ? const Color(0xFFFFB300).withValues(alpha: 0.28)
        : const Color(0xFFFFC107).withValues(alpha: 0.40);
    final textColor = isDark ? Colors.white : const Color(0xFF24160E);
    final secondaryColor = isDark
        ? const Color(0xFFFFE082).withValues(alpha: 0.75)
        : const Color(0xFF7A6452);
    const goldAccent = Color(0xFFFF8F00);
    const goldLight = Color(0xFFFFB300);

    // ── Determine Active Album Configuration ──
    final PredefinedAlbum? activePredefined =
        predefinedAlbums.isNotEmpty ? predefinedAlbums.first : null;
    final StandardAlbum? activeStandard =
        (activePredefined == null && standardAlbums.isNotEmpty)
            ? standardAlbums.first
            : null;

    final AlbumTemplate? activeTemplate;
    if (activePredefined != null) {
      activeTemplate = albumTemplates.firstWhere(
        (t) => t.id == activePredefined.templateId,
        orElse: () => albumTemplates.first,
      );
    } else {
      activeTemplate = null;
    }

    // Resolve Child Name
    final String? childName;
    if (activePredefined != null) {
      final child = children.where((c) => c.id == activePredefined.childId);
      childName = child.isNotEmpty ? child.first.name : null;
    } else if (activeStandard != null) {
      final child = children.where((c) => c.id == activeStandard.childId);
      childName = child.isNotEmpty ? child.first.name : null;
    } else if (children.isNotEmpty) {
      childName = children.first.name;
    } else {
      childName = null;
    }

    // ── Card Titles & Progress ──
    final String cardBadge;
    final String albumTitle;
    final String albumSubtitle;
    final double? progressFraction;
    final int? filledCount;
    final int? totalSlots;
    final List<Color> bookCoverColors;
    final IconData bookIcon;
    final IconData badgeIcon;

    if (activePredefined != null && activeTemplate != null) {
      filledCount = activePredefined.filledCount;
      totalSlots = activeTemplate.slots.length;
      progressFraction =
          totalSlots > 0 ? (filledCount / totalSlots).clamp(0.0, 1.0) : 0.0;
      bookCoverColors = activeTemplate.gradientColors;
      bookIcon = activeTemplate.icon;

      if (latestClaim != null) {
        badgeIcon = Icons.local_shipping_rounded;
        cardBadge = isRtl
            ? 'طلب الطباعة قيد التجهيز'
            : (lang == 'fr'
                ? 'Impression en cours'
                : 'Print order processing');
      } else if (filledCount >= totalSlots && totalSlots > 0) {
        badgeIcon = Icons.check_circle_outline_rounded;
        cardBadge = isRtl
            ? 'الألبوم مكتمل وجاهز للطباعة'
            : (lang == 'fr'
                ? 'Album prêt à imprimer'
                : 'Album ready to print');
      } else {
        badgeIcon = Icons.workspace_premium_rounded;
        cardBadge = isRtl
            ? 'ألبوم VIP الورقي'
            : (lang == 'fr' ? 'Livre Souvenir VIP' : 'VIP Printed Album');
      }

      albumTitle = activeTemplate.getTitle(lang);
      albumSubtitle = childName != null
          ? '$childName • $filledCount / $totalSlots ${isRtl ? 'ذكرى موثقة' : (lang == 'fr' ? 'souvenirs' : 'memories')}'
          : '$filledCount / $totalSlots ${isRtl ? 'ذكرى موثقة' : (lang == 'fr' ? 'souvenirs' : 'memories')}';
    } else if (activeStandard != null) {
      filledCount = activeStandard.pageCount;
      totalSlots = null;
      progressFraction = null;
      bookCoverColors = const [Color(0xFFFF8F00), Color(0xFFFFB300)];
      bookIcon = Icons.dashboard_customize_rounded;
      badgeIcon = Icons.workspace_premium_rounded;

      cardBadge = isRtl
          ? 'ألبوم VIP الخاص بكِ'
          : (lang == 'fr' ? 'Votre Album VIP' : 'Your VIP Album');
      albumTitle = activeStandard.title.isNotEmpty
          ? activeStandard.title
          : (isRtl
              ? 'ألبوم الذكريات المخصص'
              : (lang == 'fr' ? 'Album Personnalisé' : 'Custom Memory Album'));
      albumSubtitle = childName != null
          ? '$childName • ${activeStandard.pageCount} ${isRtl ? 'صفحات مصممة' : (lang == 'fr' ? 'pages créées' : 'pages created')}'
          : '${activeStandard.pageCount} ${isRtl ? 'صفحات مصممة' : (lang == 'fr' ? 'pages créées' : 'pages created')}';
    } else {
      // No album created yet: prompt to claim and choose template
      filledCount = null;
      totalSlots = null;
      progressFraction = null;
      bookCoverColors = const [Color(0xFFFF8F00), Color(0xFFFF6F00)];
      bookIcon = Icons.auto_stories_rounded;
      badgeIcon = Icons.card_giftcard_rounded;

      cardBadge = isRtl
          ? 'هدية باقة VIP المشمولة'
          : (lang == 'fr' ? 'Cadeau VIP Inclus' : 'VIP Free Printed Album');
      albumTitle = isRtl
          ? 'ألبوم طفلكِ الورقي الفاخر'
          : (lang == 'fr'
              ? 'Votre Livre Souvenir Imprimé'
              : 'Your Luxury Printed Photobook');
      albumSubtitle = isRtl
          ? 'طباعة وشحن مجاني لمنزلكِ • انقري لبدء تصميم الألبوم'
          : (lang == 'fr'
              ? 'Impression et livraison gratuites • Touchez pour créer'
              : 'Free print & home delivery • Tap to start design');
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor, width: 1.3),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.35)
                  : goldAccent.withValues(alpha: 0.12),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Bleeding luxury watermark icon in background corner
              PositionedDirectional(
                bottom: -24,
                end: -18,
                child: IgnorePointer(
                  child: Icon(
                    Icons.auto_stories_rounded,
                    size: 110,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.03)
                        : goldAccent.withValues(alpha: 0.07),
                  ),
                ),
              ),

              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _handleCardTap(
                      context: context,
                      activePredefined: activePredefined,
                      activeStandard: activeStandard,
                      children: children,
                    );
                  },
                  borderRadius: BorderRadius.circular(24),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Header Row: Micro-Pill Badge + Action Arrow
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4.5,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? goldAccent.withValues(alpha: 0.16)
                                    : const Color(0xFFFFF3D6),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: goldAccent.withValues(alpha: 0.35),
                                  width: 0.8,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    badgeIcon,
                                    size: 13,
                                    color: goldAccent,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    cardBadge,
                                    style: const TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w800,
                                      color: goldAccent,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : goldAccent.withValues(alpha: 0.12),
                              ),
                              child: Icon(
                                isRtl
                                    ? Icons.arrow_back_ios_new_rounded
                                    : Icons.arrow_forward_ios_rounded,
                                size: 13,
                                color: isDark ? Colors.white70 : goldAccent,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // Main Content: Tactile 3D Photobook + Details
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // 3D Hardcover Book Preview
                            _TactileBookCoverWidget(
                              gradientColors: bookCoverColors,
                              icon: bookIcon,
                              isDark: isDark,
                            ),

                            const SizedBox(width: 14),

                            // Album Details & Progress
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    albumTitle,
                                    style: AppTypography.fromContext(
                                      context,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    albumSubtitle,
                                    style: AppTypography.fromContext(
                                      context,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: secondaryColor,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),

                                  if (progressFraction != null) ...[
                                    const SizedBox(height: 8),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: Stack(
                                        children: [
                                          Container(
                                            height: 5.5,
                                            width: double.infinity,
                                            color: isDark
                                                ? Colors.white.withValues(
                                                    alpha: 0.10,
                                                  )
                                                : const Color(0xFFFFECB3),
                                          ),
                                          FractionallySizedBox(
                                            widthFactor: progressFraction,
                                            child: Container(
                                              height: 5.5,
                                              decoration: BoxDecoration(
                                                gradient: const LinearGradient(
                                                  colors: [
                                                    goldAccent,
                                                    goldLight,
                                                  ],
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],

                                  const SizedBox(height: 7),

                                  // Action Callout Hint
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.visibility_rounded,
                                        size: 13,
                                        color: goldAccent.withValues(
                                          alpha: 0.9,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        isRtl
                                            ? 'استعراض تفاصيل الألبوم بالكامل'
                                            : (lang == 'fr'
                                                ? 'Voir tous les détails du livre'
                                                : 'View full photobook details'),
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: goldAccent,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleCardTap({
    required BuildContext context,
    required PredefinedAlbum? activePredefined,
    required StandardAlbum? activeStandard,
    required List<Child> children,
  }) {
    final child = children.firstWhere(
      (c) => c.id == (activePredefined?.childId ?? activeStandard?.childId),
      orElse: () => children.isNotEmpty
          ? children.first
          : Child(
              id: activePredefined?.childId ?? '',
              name: '',
              birthDate: DateTime.now(),
              gender: ChildGender.boy,
            ),
    );

    if (activePredefined != null) {
      // 1. Establish navigation stack: [Home -> AlbumTemplatePickerScreen -> PredefinedAlbumDetailScreen]
      // This ensures pressing Back in the album returns to AlbumTemplatePickerScreen instead of exiting to Home.
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => AlbumTemplatePickerScreen(
            childId: child.id,
            childName: child.name,
          ),
        ),
      );
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PredefinedAlbumDetailScreen(
            albumId: activePredefined.id,
            childId: activePredefined.childId,
          ),
        ),
      );
    } else if (activeStandard != null) {
      // 2. Establish navigation stack for Standard Album
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => AlbumTemplatePickerScreen(
            childId: child.id,
            childName: child.name,
          ),
        ),
      );
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => StandardAlbumDetailScreen(
            albumId: activeStandard.id,
            childId: activeStandard.childId,
          ),
        ),
      );
    } else {
      // 3. User has no album yet -> launch template picker or memory book hub
      if (children.isNotEmpty) {
        final firstChild = children.first;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AlbumTemplatePickerScreen(
              childId: firstChild.id,
              childName: firstChild.name,
            ),
          ),
        );
      } else {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const MemoryBookScreen(),
          ),
        );
      }
    }
  }
}

/// Tactile 3D Hardcover Book representation with realistic spine,
/// gold embossing, and silk ribbon bookmark.
class _TactileBookCoverWidget extends StatelessWidget {
  const _TactileBookCoverWidget({
    required this.gradientColors,
    required this.icon,
    required this.isDark,
  });

  final List<Color> gradientColors;
  final IconData icon;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Ribbon bookmark hanging slightly below the book bottom
        PositionedDirectional(
          bottom: -6,
          start: 22,
          child: Container(
            width: 9,
            height: 14,
            decoration: BoxDecoration(
              color: const Color(0xFFD32F2F),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(2),
                bottomRight: Radius.circular(2),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),

        // Main Book Cover with hardcover spine
        Container(
          width: 62,
          height: 78,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(isRtl ? 8 : 3),
              bottomLeft: Radius.circular(isRtl ? 8 : 3),
              topRight: Radius.circular(isRtl ? 3 : 8),
              bottomRight: Radius.circular(isRtl ? 3 : 8),
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors.length >= 2
                  ? gradientColors
                  : [const Color(0xFFFF8F00), const Color(0xFFFF6F00)],
            ),
            boxShadow: [
              BoxShadow(
                color: (gradientColors.isNotEmpty
                        ? gradientColors.first
                        : const Color(0xFFFF8F00))
                    .withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(2, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Spine shadow overlay
              PositionedDirectional(
                top: 0,
                bottom: 0,
                start: 0,
                child: Container(
                  width: 6,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(isRtl ? 0 : 3),
                      bottomLeft: Radius.circular(isRtl ? 0 : 3),
                      topRight: Radius.circular(isRtl ? 3 : 0),
                      bottomRight: Radius.circular(isRtl ? 3 : 0),
                    ),
                  ),
                ),
              ),

              // Diagonal subtle light gloss across book cover
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.25),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.15),
                      ],
                    ),
                  ),
                ),
              ),

              // Centered foil icon & embossed lines
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.25),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.4),
                          width: 0.8,
                        ),
                      ),
                      child: Icon(
                        icon,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      width: 28,
                      height: 2,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                    const SizedBox(height: 2.5),
                    Container(
                      width: 18,
                      height: 1.5,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
