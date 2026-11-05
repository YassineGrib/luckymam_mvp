import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/extensions/l10n_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../models/digital_slideshow_model.dart';

/// Fullscreen immersive digital slideshow player for LuckyMam (LM-DIG-001).
/// Features:
/// - Opening & closing branded cards with LuckyMam clover
/// - 3.5s per slide with smooth animated progress segments
/// - Tap left/right to navigate, tap center or hold to pause/resume
/// - Discreet 38% opacity clover watermark on every photo in safe margins
/// - Resilient image loading with soft pastel fallback on network delay
class DigitalSlideshowPlayerScreen extends StatefulWidget {
  const DigitalSlideshowPlayerScreen({
    super.key,
    required this.slideshow,
  });

  final DigitalSlideshow slideshow;

  @override
  State<DigitalSlideshowPlayerScreen> createState() =>
      _DigitalSlideshowPlayerScreenState();
}

class _DigitalSlideshowPlayerScreenState
    extends State<DigitalSlideshowPlayerScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progressController;
  late final PageController _pageController;

  int _currentIndex = 0;
  bool _isPaused = false;

  int get _totalSteps => widget.slideshow.slides.length + 2; // +1 opening, +1 closing

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _progressController = AnimationController(
      vsync: this,
      duration: widget.slideshow.durationPerSlide,
    );

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _goToNext();
      }
    });

    _startCurrentSlide();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _startCurrentSlide() {
    _progressController.reset();
    if (!_isPaused && _currentIndex < _totalSteps - 1) {
      _progressController.forward();
    }
  }

  void _goToNext() {
    if (_currentIndex < _totalSteps - 1) {
      setState(() {
        _currentIndex++;
      });
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
      _startCurrentSlide();
    } else {
      _progressController.stop();
    }
  }

  void _goToPrevious() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
      _startCurrentSlide();
    }
  }

  void _togglePause() {
    HapticFeedback.lightImpact();
    setState(() {
      _isPaused = !_isPaused;
      if (_isPaused) {
        _progressController.stop();
      } else {
        _progressController.forward();
      }
    });
  }

  void _restart() {
    HapticFeedback.mediumImpact();
    setState(() {
      _currentIndex = 0;
      _isPaused = false;
    });
    _pageController.jumpToPage(0);
    _startCurrentSlide();
  }

  Future<void> _shareSlideshow(BuildContext context) async {
    final l10n = context.l10n;
    HapticFeedback.selectionClick();
    final text = '${l10n.diaporamaShareMessage(widget.slideshow.childName)}\n\n🍀 LuckyMam';
    await SharePlus.instance.share(ShareParams(text: text));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isRtl = context.isRtl;

    return Scaffold(
      backgroundColor: const Color(0xFF110E13),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── 1. PageView for Slides (Opening -> Photos -> Closing) ──
          PageView.builder(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _totalSteps,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildOpeningCard(context, l10n);
              } else if (index == _totalSteps - 1) {
                return _buildClosingCard(context, l10n);
              } else {
                final slide = widget.slideshow.slides[index - 1];
                return _buildPhotoSlide(context, slide, index, l10n, isRtl);
              }
            },
          ),

          // ── 2. Tap Navigation Touch Zones ──
          SafeArea(
            child: Row(
              children: [
                // Left 30%: Previous slide
                Expanded(
                  flex: 3,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: isRtl ? _goToNext : _goToPrevious,
                  ),
                ),
                // Center 40%: Pause / Resume
                Expanded(
                  flex: 4,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: _togglePause,
                    onLongPressStart: (_) {
                      if (!_isPaused) _togglePause();
                    },
                    onLongPressEnd: (_) {
                      if (_isPaused) _togglePause();
                    },
                  ),
                ),
                // Right 30%: Next slide
                Expanded(
                  flex: 3,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: isRtl ? _goToPrevious : _goToNext,
                  ),
                ),
              ],
            ),
          ),

          // ── 3. Top Progress Bar & Header Controls ──
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Segmented Progress Bar
                  Row(
                    children: List.generate(_totalSteps, (i) {
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: SizedBox(
                              height: 3,
                              child: AnimatedBuilder(
                                animation: _progressController,
                                builder: (context, _) {
                                  double value = 0.0;
                                  if (i < _currentIndex) {
                                    value = 1.0;
                                  } else if (i == _currentIndex) {
                                    value = _progressController.value;
                                  }
                                  return LinearProgressIndicator(
                                    value: value,
                                    backgroundColor:
                                        Colors.white.withValues(alpha: 0.25),
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                      Color(0xFFFFD54F),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 10),

                  // Top Action Bar (Close & Pause Indicator)
                  Row(
                    children: [
                      // Close button
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.35),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const Spacer(),

                      // Pause Badge Indicator (if paused)
                      if (_isPaused)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFFFD54F)
                                  .withValues(alpha: 0.5),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.pause_rounded,
                                size: 14,
                                color: Color(0xFFFFD54F),
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Pause',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFFFD54F),
                                ),
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
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // SLIDE 0: OPENING BRANDED CARD (LM-DIG-001)
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildOpeningCard(BuildContext context, dynamic l10n) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF24161B), Color(0xFF140D12), Color(0xFF0F0A0E)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // LuckyMam Glowing Clover Emblem
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.coral, Color(0xFFFF8F00)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.coral.withValues(alpha: 0.45),
                      blurRadius: 32,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_stories_rounded,
                  size: 42,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 28),

              // Title
              Text(
                l10n.diaporamaOpeningTitle(widget.slideshow.childName),
                style: AppTypography.fromContext(
                  context,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Photo Count Pill
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.22),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.photo_library_rounded,
                      size: 14,
                      color: Color(0xFFFFD54F),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${widget.slideshow.slides.length} photos',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              // Subtitle hint
              Text(
                '🍀 LuckyMam',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withValues(alpha: 0.55),
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // SLIDES 1 to N: PHOTO SLIDE WITH WATERMARK & FALLBACK
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildPhotoSlide(
    BuildContext context,
    DigitalSlide slide,
    int index,
    dynamic l10n,
    bool isRtl,
  ) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Photo with Ken-Burns scale and safe fallback
        Image.network(
          slide.photoUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildFallbackCard(slide),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return _buildFallbackCard(slide, isLoading: true);
          },
        ),

        // 2. Gentle Top & Bottom Vignette Overlays
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 120,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withValues(alpha: 0.65),
                  Colors.transparent,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 180,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.8),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),

        // 3. Caption Overlay (Title, Date & Counter)
        Positioned(
          left: 20,
          right: 20,
          bottom: 40,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.18),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            slide.title,
                            style: AppTypography.fromContext(
                              context,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (slide.date != null) ...[
                            const SizedBox(height: 3),
                            Text(
                              '${slide.date!.day}/${slide.date!.month}/${slide.date!.year}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$index / ${widget.slideshow.slides.length}',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // 4. LM-ALB-003 & LM-DIG-001: Discreet Clover Watermark in safe margin (38% opacity)
              Align(
                alignment: isRtl
                    ? Alignment.bottomLeft
                    : Alignment.bottomRight,
                child: Opacity(
                  opacity: 0.38,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.eco_rounded,
                        size: 13,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'LuckyMam',
                        style: AppTypography.fromContext(
                          context,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Fallback card when an image takes time or fails (Edge Case 2 arbitration)
  Widget _buildFallbackCard(DigitalSlide slide, {bool isLoading = false}) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2D1E26), Color(0xFF1E141B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isLoading
                    ? Icons.hourglass_top_rounded
                    : Icons.photo_camera_rounded,
                size: 32,
                color: const Color(0xFFFF8F00),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              slide.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // SLIDE N+1: CLOSING BRANDED CARD (LM-DIG-001)
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildClosingCard(BuildContext context, dynamic l10n) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1F1218), Color(0xFF120A0F), Color(0xFF0C070A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Clover Emblem with Golden Halo
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.coral, Color(0xFFFF8F00)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF8F00).withValues(alpha: 0.4),
                      blurRadius: 36,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  size: 44,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 28),

              // Warm Message
              Text(
                l10n.diaporamaClosingTitle,
                style: AppTypography.fromContext(
                  context,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 36),

              // Action Buttons Row (Replay & Share)
              Row(
                children: [
                  // Replay Button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _restart,
                      icon: const Icon(Icons.replay_rounded, color: Colors.white),
                      label: Text(
                        l10n.diaporamaReplay,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.35),
                          width: 1.2,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Share Button
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.coral, Color(0xFFFF8F00)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.coral.withValues(alpha: 0.4),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () => _shareSlideshow(context),
                        icon: const Icon(
                          Icons.share_rounded,
                          color: Colors.white,
                        ),
                        label: Text(
                          l10n.diaporamaShare,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Dismiss
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Fermer',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

