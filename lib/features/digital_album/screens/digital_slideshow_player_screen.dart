import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:share_plus/share_plus.dart';

import '../../../core/extensions/l10n_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_logo.dart';
import '../models/digital_slideshow_model.dart';

/// Touch navigation is confined to photos: it must never cover end-card actions.
class DigitalSlideshowPlayerScreen extends StatefulWidget {
  const DigitalSlideshowPlayerScreen({super.key, required this.slideshow});
  final DigitalSlideshow slideshow;

  @override
  State<DigitalSlideshowPlayerScreen> createState() =>
      _DigitalSlideshowPlayerScreenState();
}

class _DigitalSlideshowPlayerScreenState
    extends State<DigitalSlideshowPlayerScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _progress;
  late final PageController _pages;
  int _index = 0;
  bool _paused = false;
  bool _sharing = false;
  bool _resumeAfterHold = false;
  int get _steps => widget.slideshow.slides.length + 2;
  bool get _atEnd => _index == _steps - 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pages = PageController();
    _progress =
        AnimationController(
            vsync: this,
            duration: widget.slideshow.durationPerSlide,
          )
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed && !_atEnd) _go(1);
          })
          ..forward();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed && !_paused) _setPaused(true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _progress.dispose();
    _pages.dispose();
    super.dispose();
  }

  void _go(int delta) {
    final next = (_index + delta).clamp(0, _steps - 1);
    if (next == _index) return;
    setState(() => _index = next);
    _pages.animateToPage(
      next,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
    );
    _progress.reset();
    if (!_paused && !_atEnd) _progress.forward();
  }

  void _setPaused(bool paused) {
    if (_atEnd) return;
    setState(() => _paused = paused);
    paused ? _progress.stop() : _progress.forward();
  }

  Future<void> _share() async {
    if (_sharing) return;
    setState(() => _sharing = true);
    _progress.stop();
    try {
      final box = context.findRenderObject() as RenderBox?;
      await SharePlus.instance.share(
        ShareParams(
          text:
              '${context.l10n.diaporamaShareMessage(widget.slideshow.childName)}\n\n'
              'https://play.google.com/store/apps/details?id=com.luckmam.luckmam_mvp&hl=en',
          sharePositionOrigin: box == null
              ? null
              : box.localToGlobal(Offset.zero) & box.size,
        ),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.retry)));
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF171316),
      body: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _pages,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _steps,
            itemBuilder: (context, index) {
              if (index == 0) return _bookend(closing: false);
              if (index == _steps - 1) return _bookend(closing: true);
              return _photo(widget.slideshow.slides[index - 1]);
            },
          ),
          // At the end the card itself owns all touch input.
          if (!_atEnd)
            Positioned.fill(
              child: Row(
                textDirection: TextDirection.ltr,
                children: [
                  Expanded(
                    flex: 3,
                    child: GestureDetector(
                      key: const ValueKey('slideshow-previous'),
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _go(-1),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _setPaused(!_paused),
                      onLongPressStart: (_) {
                        _resumeAfterHold = !_paused;
                        _setPaused(true);
                      },
                      onLongPressEnd: (_) {
                        if (_resumeAfterHold) _setPaused(false);
                      },
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: GestureDetector(
                      key: const ValueKey('slideshow-next'),
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _go(1),
                    ),
                  ),
                ],
              ),
            ),
          // A bounded header avoids a full-height hit-test layer over the card.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedBuilder(
                      animation: _progress,
                      builder: (context, _) => Row(
                        children: List.generate(
                          _steps,
                          (i) => Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 2,
                              ),
                              child: LinearProgressIndicator(
                                minHeight: 3,
                                value: i < _index || _atEnd
                                    ? 1
                                    : i == _index
                                    ? _progress.value
                                    : 0,
                                color: AppColors.coral,
                                backgroundColor: Colors.white24,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        IconButton(
                          key: const ValueKey('slideshow-close'),
                          tooltip: MaterialLocalizations.of(
                            context,
                          ).closeButtonTooltip,
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black38,
                          ),
                        ),
                        const Spacer(),
                        if (_paused && !_atEnd)
                          const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.pause_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Pause',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
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
    );
  }

  Widget _bookend({required bool closing}) {
    final l10n = context.l10n;
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF38272E), Color(0xFF191418)],
        ),
      ),
      child: Stack(
        children: [
          PositionedDirectional(
            end: -45,
            top: 130,
            child: Icon(
              closing
                  ? Icons.favorite_outline_rounded
                  : Icons.auto_stories_outlined,
              size: 280,
              color: AppColors.coral.withValues(alpha: 0.09),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(32, 100, 32, 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const LuckymamLogo(size: 70, color: Colors.white),
                    const SizedBox(height: 32),
                    Text(
                      closing
                          ? l10n.diaporamaClosingTitle
                          : l10n.diaporamaOpeningTitle(
                              widget.slideshow.childName,
                            ),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 28,
                        height: 1.25,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(width: 40, height: 3, color: AppColors.coral),
                    const SizedBox(height: 24),
                    if (closing)
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          key: const ValueKey('slideshow-share'),
                          onPressed: _sharing ? null : _share,
                          icon: _sharing
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.ios_share_rounded),
                          label: Text(l10n.diaporamaShare),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.coral,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                        ),
                      )
                    else
                      Text(
                        widget.slideshow.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                        ),
                      ),
                    const SizedBox(height: 32),
                    const Text(
                      'LuckyMam',
                      style: TextStyle(
                        color: Colors.white54,
                        letterSpacing: 2,
                        fontSize: 12,
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

  Widget _photo(DigitalSlide slide) {
    final lang = Localizations.localeOf(context).languageCode;
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          slide.photoUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => const ColoredBox(
            color: Color(0xFF30242B),
            child: Center(
              child: Icon(
                Icons.photo_outlined,
                size: 56,
                color: Colors.white54,
              ),
            ),
          ),
          loadingBuilder: (context, child, progress) => progress == null
              ? child
              : const ColoredBox(
                  color: Color(0xFF30242B),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.coral),
                  ),
                ),
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.center,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black87],
            ),
          ),
        ),
        Positioned(
          left: 24,
          right: 24,
          bottom: 0,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(
                        slide.emotions.isEmpty
                            ? Icons.favorite_outline_rounded
                            : slide.emotions.first.icon,
                        size: 32,
                        color: AppColors.coral,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              slide.emotions.isEmpty
                                  ? slide.title
                                  : slide.emotions
                                        .map((e) => e.getLabel(lang))
                                        .join(' · '),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              [
                                widget.slideshow.childName,
                                if (slide.date != null)
                                  DateFormat(
                                    'd MMM yyyy',
                                    lang,
                                  ).format(slide.date!),
                              ].join(' · '),
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (slide.category != null) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          slide.category!.icon,
                          color: Colors.white70,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          slide.category!.getLabel(lang),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (slide.tags.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      slide.tags.join(' · '),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  const Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: Opacity(
                      opacity: 0.38,
                      child: LuckymamLogo(size: 24, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
