import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

import '../../../core/extensions/l10n_extension.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/top_ambient_gradient.dart';
import '../providers/print_order_providers.dart';
import '../services/album_pdf_service.dart';
import 'print_order_screen.dart';

/// Flagship VIP Print Preview Screen for LuckyMam.
/// Provides a realistic, tactile photobook flip simulator with gold foil details,
/// paper texture, binding spine, page-turning physics, and technical PDF preview mode.
class AlbumPrintPreviewScreen extends ConsumerStatefulWidget {
  const AlbumPrintPreviewScreen({
    super.key,
    required this.childId,
    required this.childName,
    required this.albumId,
    required this.albumType,
    required this.albumTitle,
    required this.pages,
  });

  final String childId;
  final String childName;
  final String albumId;

  /// 'predefined' | 'standard'
  final String albumType;
  final String albumTitle;
  final List<AlbumPdfPage> pages;

  @override
  ConsumerState<AlbumPrintPreviewScreen> createState() =>
      _AlbumPrintPreviewScreenState();
}

class _AlbumPrintPreviewScreenState
    extends ConsumerState<AlbumPrintPreviewScreen> {
  bool _isPhotobookMode = true;
  late final PageController _pageController;
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.88);
    AnalyticsService().logEvent(
      'pdf_preview_opened',
      parameters: {'albumId': widget.albumId, 'albumType': widget.albumType},
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isRtl = context.isRtl;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;
    final textColor = isDark ? Colors.white : AppColors.onSurfaceLight;
    final secondaryText = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    final totalBookPages = widget.pages.length + 1; // 1 for cover + pages

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // ── Atmospheric VIP Ambient Glow ──
          const TopAmbientGradient(height: 360),

          SafeArea(
            child: Column(
              children: [
                // ── 1. VIP Integrated Header ──
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

                      // Title & VIP Badge
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  l10n.printPreviewTitle,
                                  style: AppTypography.fromContext(
                                    context,
                                    fontSize: 16.5,
                                    fontWeight: FontWeight.w800,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFFFD700),
                                        Color(0xFFFFA500),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'VIP',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.albumTitle,
                              style: AppTypography.fromContext(
                                context,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: secondaryText,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      // View Mode Switcher: 📖 Flip vs 📄 PDF
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isDark ? Colors.white12 : const Color(0xFFE8E0E4),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildPreviewTab(
                              icon: Icons.auto_stories_rounded,
                              label: isRtl ? 'الكتاب' : 'Livre',
                              isSelected: _isPhotobookMode,
                              onTap: () {
                                if (!_isPhotobookMode) {
                                  HapticFeedback.selectionClick();
                                  setState(() => _isPhotobookMode = true);
                                }
                              },
                            ),
                            const SizedBox(width: 2),
                            _buildPreviewTab(
                              icon: Icons.picture_as_pdf_rounded,
                              label: 'PDF',
                              isSelected: !_isPhotobookMode,
                              onTap: () {
                                if (_isPhotobookMode) {
                                  HapticFeedback.selectionClick();
                                  setState(() => _isPhotobookMode = false);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 6),

                // ── 2. Active Preview Viewport ──
                Expanded(
                  child: _isPhotobookMode
                      ? _buildPhotobookFlipViewer(
                          context: context,
                          totalBookPages: totalBookPages,
                          textColor: textColor,
                          secondaryText: secondaryText,
                          isDark: isDark,
                          isRtl: isRtl,
                        )
                      : _buildPdfViewer(context, textColor, isDark),
                ),

                // ── 3. VIP Quality & Paper Guarantee Strip ──
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPaddingH,
                    vertical: 6,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1F1C25)
                          : const Color(0xFFFFF9FA),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.35),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.verified_rounded,
                            size: 18,
                            color: Color(0xFFD97706),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isRtl
                                    ? 'جودة طباعة استثنائية ورق حريري 250g'
                                    : 'Impression VIP Papier Soie 250g',
                                style: AppTypography.fromContext(
                                  context,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: textColor,
                                ),
                              ),
                              Text(
                                isRtl
                                    ? 'تجليد مقوى فاخر مع صندوق هدايا تذكاري خاص'
                                    : 'Couverture rigide et coffret cadeau inclus',
                                style: AppTypography.fromContext(
                                  context,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w500,
                                  color: secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── 4. Bottom Order Printing CTA ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenPaddingH,
                    6,
                    AppSpacing.screenPaddingH,
                    14,
                  ),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.magentaPink.withValues(alpha: 0.38),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => PrintOrderScreen(
                              childId: widget.childId,
                              childName: widget.childName,
                              albumId: widget.albumId,
                              albumType: widget.albumType,
                              albumTitle: widget.albumTitle,
                              pageCount: widget.pages.length,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.local_shipping_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      label: Text(
                        isRtl
                            ? 'متابعة لإدخال عنوان الشحن والتأكيد'
                            : l10n.printOrderPrinting,
                        style: AppTypography.fromContext(
                          context,
                          fontSize: 15.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewTab({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.coral : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.coral.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? Colors.white : Colors.grey,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // REALISTIC PHOTOBOOK FLIP SIMULATOR
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildPhotobookFlipViewer({
    required BuildContext context,
    required int totalBookPages,
    required Color textColor,
    required Color secondaryText,
    required bool isDark,
    required bool isRtl,
  }) {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            itemCount: totalBookPages,
            onPageChanged: (i) {
              HapticFeedback.selectionClick();
              setState(() => _currentPageIndex = i);
            },
            itemBuilder: (context, index) {
              if (index == 0) {
                // Page 0: Hardcover Front Cover
                return _buildBookFrontCover(isDark, isRtl);
              }

              // Inner Print Pages
              final page = widget.pages[index - 1];
              return _buildInnerPrintPage(
                page: page,
                pageIndex: index,
                totalPages: totalBookPages,
                textColor: textColor,
                secondaryText: secondaryText,
                isDark: isDark,
                isRtl: isRtl,
              );
            },
          ),
        ),

        const SizedBox(height: 8),

        // Page Indicator Scrubber
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(totalBookPages, (i) {
            final isCurrent = i == _currentPageIndex;
            return GestureDetector(
              onTap: () {
                _pageController.animateToPage(
                  i,
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeOutCubic,
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isCurrent ? 24 : 7,
                height: 7,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: isCurrent
                      ? AppColors.coral
                      : isDark
                          ? Colors.white24
                          : Colors.black12,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  /// Front Hardcover with golden embossing and luxury finish.
  Widget _buildBookFrontCover(bool isDark, bool isRtl) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF2C2230),
            Color(0xFF1A141D),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFFFD700).withValues(alpha: 0.45),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(21),
        child: Stack(
          children: [
            // Gold Embossed Frame Border
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),

            // Book Spine Highlight
            Positioned(
              top: 0,
              bottom: 0,
              left: isRtl ? null : 0,
              right: isRtl ? 0 : null,
              width: 18,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black54,
                      Colors.black12,
                      Colors.white.withValues(alpha: 0.2),
                      Colors.transparent,
                    ],
                    begin: isRtl ? Alignment.centerRight : Alignment.centerLeft,
                    end: isRtl ? Alignment.centerLeft : Alignment.centerRight,
                  ),
                ),
              ),
            ),

            // Cover Center Text & Gold Emblem
            Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.auto_stories_rounded,
                        color: Colors.black87,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      widget.albumTitle,
                      style: const TextStyle(
                        fontFamily: 'serif',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFFE082),
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Text(
                        'كتاب ذكريات ${widget.childName}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'اسحبي للبدء في تصفح الألبوم',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFFD4AF37),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 14,
                          color: Color(0xFFD4AF37),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Inner photobook printable page spread.
  Widget _buildInnerPrintPage({
    required AlbumPdfPage page,
    required int pageIndex,
    required int totalPages,
    required Color textColor,
    required Color secondaryText,
    required bool isDark,
    required bool isRtl,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1A22) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.09)
              : Colors.black.withValues(alpha: 0.08),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(21),
        child: Stack(
          children: [
            // Center Spine Shadow
            Positioned(
              top: 0,
              bottom: 0,
              left: isRtl ? null : 0,
              right: isRtl ? 0 : null,
              width: 16,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.22),
                      Colors.black.withValues(alpha: 0.05),
                      Colors.transparent,
                    ],
                    begin: isRtl ? Alignment.centerRight : Alignment.centerLeft,
                    end: isRtl ? Alignment.centerLeft : Alignment.centerRight,
                  ),
                ),
              ),
            ),

            // Inner Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Page Header: Page number
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'صفحة $pageIndex',
                        style: AppTypography.fromContext(
                          context,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: secondaryText,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.coral.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.childName,
                          style: AppTypography.fromContext(
                            context,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.coral,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Printable Photo Frame
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          page.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            color: isDark ? Colors.grey[850] : Colors.grey[200],
                            child: const Center(
                              child: Icon(
                                Icons.photo_camera_back_rounded,
                                size: 38,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Milestone Caption
                  if (page.caption.isNotEmpty)
                    Text(
                      page.caption,
                      style: AppTypography.fromContext(
                        context,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TECHNICAL PDF PREVIEW MODE
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildPdfViewer(BuildContext context, Color textColor, bool isDark) {
    return PdfPreview(
      build: (format) => ref.read(albumPdfServiceProvider).generateAlbumPdf(
            albumTitle: widget.albumTitle,
            childName: widget.childName,
            pages: widget.pages,
          ),
      allowPrinting: true,
      allowSharing: true,
      canChangePageFormat: false,
      canChangeOrientation: false,
      canDebug: false,
      pdfPreviewPageDecoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      loadingWidget: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.coral),
            const SizedBox(height: AppSpacing.md),
            Text(
              context.l10n.printPreparingAlbum,
              style: AppTypography.fromContext(
                context,
                fontSize: 14,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
