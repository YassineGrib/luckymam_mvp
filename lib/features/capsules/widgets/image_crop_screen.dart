import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../core/extensions/l10n_extension.dart';
import '../../../core/theme/app_colors.dart';

/// Screen allowing the user to interactively pan, scale, rotate, and crop an image
/// to a full-screen vertical (9:16) Story ratio with zero top/bottom black bars.
class ImageCropScreen extends StatefulWidget {
  final File imageFile;

  const ImageCropScreen({
    super.key,
    required this.imageFile,
  });

  /// Checks whether an image is already vertical and close to the 9:16 Story ratio (0.5625).
  /// If true, the caller can auto-crop without interrupting the user.
  static Future<bool> isCloseToStoryRatio(
    File file, {
    double minRatio = 0.48,
    double maxRatio = 0.62,
  }) async {
    try {
      final bytes = await file.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final img = frame.image;
      final aspect = img.width / img.height;
      img.dispose();
      return aspect >= minRatio && aspect <= maxRatio;
    } catch (_) {
      return false;
    }
  }

  /// Instant centered auto-crop to exact 9:16 ratio for vertical images that
  /// are already close to the Story aspect ratio. Produces a crisp 1080x1920 image.
  static Future<File> autoCropCenter(
    File file, {
    int targetWidth = 1080,
    int targetHeight = 1920,
  }) async {
    try {
      final bytes = await file.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final image = frame.image;

      final double imgW = image.width.toDouble();
      final double imgH = image.height.toDouble();
      const double targetAspect = 9.0 / 16.0;
      final double currentAspect = imgW / imgH;

      double srcW = imgW;
      double srcH = imgH;
      double srcX = 0;
      double srcY = 0;

      if (currentAspect > targetAspect) {
        // Image is slightly wider than 9:16 -> trim sides equally
        srcW = imgH * targetAspect;
        srcX = (imgW - srcW) / 2.0;
      } else if (currentAspect < targetAspect) {
        // Image is slightly taller than 9:16 -> trim top/bottom equally
        srcH = imgW / targetAspect;
        srcY = (imgH - srcH) / 2.0;
      }

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      final srcRect = Rect.fromLTWH(srcX, srcY, srcW, srcH);
      final dstRect = Rect.fromLTWH(
        0,
        0,
        targetWidth.toDouble(),
        targetHeight.toDouble(),
      );
      final paint = Paint()..filterQuality = ui.FilterQuality.high;

      canvas.drawImageRect(image, srcRect, dstRect, paint);

      final picture = recorder.endRecording();
      final cropped = await picture.toImage(targetWidth, targetHeight);
      final byteData =
          await cropped.toByteData(format: ui.ImageByteFormat.png);

      image.dispose();
      cropped.dispose();

      if (byteData == null) return file;

      final tempPath =
          '${Directory.systemTemp.path}/story_autocrop_${DateTime.now().millisecondsSinceEpoch}.png';
      final outFile = File(tempPath);
      await outFile.writeAsBytes(byteData.buffer.asUint8List());
      return outFile;
    } catch (_) {
      return file;
    }
  }

  @override
  State<ImageCropScreen> createState() => _ImageCropScreenState();
}

class _ImageCropScreenState extends State<ImageCropScreen> {
  final TransformationController _transformationController =
      TransformationController();
  final GlobalKey _cropKey = GlobalKey();

  ui.Image? _decodedImage;
  bool _isCropping = false;
  bool _hasInitializedTransform = false;
  bool _showGrid = true;
  bool _isPreviewMode = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    final bytes = await widget.imageFile.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    if (mounted) {
      setState(() {
        _decodedImage = frame.image;
      });
    }
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _decodedImage?.dispose();
    super.dispose();
  }

  /// Rotates the in-memory image 90 degrees clockwise and re-centers the crop viewport.
  Future<void> _rotate90() async {
    if (_decodedImage == null || _isCropping) return;
    setState(() => _isCropping = true);

    try {
      final oldImg = _decodedImage!;
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final double targetW = oldImg.height.toDouble();
      final double targetH = oldImg.width.toDouble();

      canvas.translate(targetW / 2.0, targetH / 2.0);
      canvas.rotate(math.pi / 2.0);
      canvas.drawImage(
        oldImg,
        Offset(-oldImg.width / 2.0, -oldImg.height / 2.0),
        Paint()..filterQuality = ui.FilterQuality.high,
      );

      final picture = recorder.endRecording();
      final newImg = await picture.toImage(oldImg.height, oldImg.width);
      oldImg.dispose();

      if (mounted) {
        setState(() {
          _decodedImage = newImg;
          _hasInitializedTransform = false;
          _isCropping = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCropping = false);
      }
    }
  }

  /// Centers the image in the 9:16 viewport at 1.0x scale.
  void _resetTransform() {
    if (_cropKey.currentContext == null || _decodedImage == null) return;
    final RenderBox? renderBox =
        _cropKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final double viewportW = renderBox.size.width;
    final double viewportH = renderBox.size.height;
    final double imgW = _decodedImage!.width.toDouble();
    final double imgH = _decodedImage!.height.toDouble();
    final double viewportAspect = viewportW / viewportH;
    final double imgAspect = imgW / imgH;

    double childW, childH;
    if (imgAspect > viewportAspect) {
      childH = viewportH;
      childW = viewportH * imgAspect;
    } else {
      childW = viewportW;
      childH = viewportW / imgAspect;
    }

    final double initialTx = -(childW - viewportW) / 2.0;
    final double initialTy = -(childH - viewportH) / 2.0;
    setState(() {
      _transformationController.value =
          Matrix4.translationValues(initialTx, initialTy, 0.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final lang = Localizations.localeOf(context).languageCode;
    final isAr = lang == 'ar';
    final isFr = lang == 'fr';

    return Scaffold(
      backgroundColor: const Color(0xFF0D0B12),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0B12),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.capsuleCropTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: primary.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: const Text(
                'Story 9:16',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 8),
            child: TextButton.icon(
              onPressed:
                  (_decodedImage != null && !_isCropping) ? _cropAndSave : null,
              style: TextButton.styleFrom(
                backgroundColor: primary,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              icon: _isCropping
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check_rounded, color: Colors.white, size: 18),
              label: Text(
                l10n.confirm,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
      body: _decodedImage == null
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          : SafeArea(
              child: Column(
                children: [
                  // Top instruction banner
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _isPreviewMode
                          ? primary.withValues(alpha: 0.15)
                          : Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _isPreviewMode
                            ? primary.withValues(alpha: 0.4)
                            : Colors.white12,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isPreviewMode
                              ? Icons.visibility_rounded
                              : Icons.touch_app_rounded,
                          color: _isPreviewMode ? primary : Colors.white70,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            _isPreviewMode
                                ? (isAr
                                    ? 'وضع المعاينة: هكذا ستملأ الصورة الشاشة بدون أي فراغات'
                                    : (isFr
                                        ? 'Mode Aperçu : la photo remplit tout l\'écran sans bandes'
                                        : 'Preview mode: photo fills the screen with zero black bars'))
                                : (isAr
                                    ? 'حرّك وقرّب لضبط الستوري بحجم الشاشة الكاملة'
                                    : l10n.capsuleCropHint),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _isPreviewMode ? Colors.white : Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 9:16 Full Screen Story Viewport
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 4,
                        ),
                        child: AspectRatio(
                          aspectRatio: 9 / 16,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            key: _cropKey,
                            clipBehavior: Clip.hardEdge,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _isPreviewMode
                                    ? Colors.white24
                                    : primary.withValues(alpha: 0.9),
                                width: _isPreviewMode ? 1.0 : 2.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _isPreviewMode
                                      ? Colors.black.withValues(alpha: 0.5)
                                      : primary.withValues(alpha: 0.25),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    final double viewportW = constraints.maxWidth;
                                    final double viewportH = constraints.maxHeight;
                                    final double imgW =
                                        _decodedImage!.width.toDouble();
                                    final double imgH =
                                        _decodedImage!.height.toDouble();
                                    final double viewportAspect =
                                        viewportW / viewportH;
                                    final double imgAspect = imgW / imgH;

                                    double childW, childH;
                                    if (imgAspect > viewportAspect) {
                                      // Image is wider than 9:16 -> fit height, width extends
                                      childH = viewportH;
                                      childW = viewportH * imgAspect;
                                    } else {
                                      // Image is taller than 9:16 -> fit width, height extends
                                      childW = viewportW;
                                      childH = viewportW / imgAspect;
                                    }

                                    // Initialize transform to center the image within the viewport
                                    if (!_hasInitializedTransform) {
                                      _hasInitializedTransform = true;
                                      final double initialTx =
                                          -(childW - viewportW) / 2.0;
                                      final double initialTy =
                                          -(childH - viewportH) / 2.0;
                                      _transformationController.value =
                                          Matrix4.translationValues(
                                        initialTx,
                                        initialTy,
                                        0.0,
                                      );
                                    }

                                    return InteractiveViewer(
                                      transformationController:
                                          _transformationController,
                                      minScale: 1.0,
                                      maxScale: 4.5,
                                      constrained: false,
                                      boundaryMargin: EdgeInsets.zero,
                                      child: SizedBox(
                                        width: childW,
                                        height: childH,
                                        child: RawImage(
                                          image: _decodedImage,
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    );
                                  },
                                ),

                                // Internal grid lines & photography corner brackets
                                if (_showGrid && !_isPreviewMode)
                                  IgnorePointer(
                                    child: CustomPaint(
                                      painter: _StoryGridPainter(
                                        gridColor:
                                            Colors.white.withValues(alpha: 0.35),
                                        cornerColor: primary,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Bottom Studio Dock Controls
                  Container(
                    margin: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B1824).withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 18,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildToolButton(
                          icon: Icons.rotate_right_rounded,
                          label: isAr
                              ? 'تدوير 90°'
                              : (isFr ? 'Pivoter' : 'Rotate'),
                          onTap: _rotate90,
                          primaryColor: primary,
                        ),
                        _buildToolButton(
                          icon: Icons.restart_alt_rounded,
                          label: isAr
                              ? 'توسيط'
                              : (isFr ? 'Centrer' : 'Center'),
                          onTap: _resetTransform,
                          primaryColor: primary,
                        ),
                        _buildToolButton(
                          icon: _showGrid
                              ? Icons.grid_on_rounded
                              : Icons.grid_off_rounded,
                          label: isAr
                              ? 'الشبكة'
                              : (isFr ? 'Grille' : 'Grid'),
                          isActive: _showGrid,
                          onTap: () =>
                              setState(() => _showGrid = !_showGrid),
                          primaryColor: primary,
                        ),
                        _buildToolButton(
                          icon: _isPreviewMode
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          label: isAr
                              ? 'معاينة'
                              : (isFr ? 'Aperçu' : 'Preview'),
                          isActive: _isPreviewMode,
                          onTap: () =>
                              setState(() => _isPreviewMode = !_isPreviewMode),
                          primaryColor: primary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color primaryColor,
    bool isActive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isActive
                    ? primaryColor.withValues(alpha: 0.22)
                    : Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isActive
                      ? primaryColor.withValues(alpha: 0.6)
                      : Colors.white10,
                ),
              ),
              child: Icon(
                icon,
                color: isActive ? primaryColor : Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                color: isActive ? primaryColor : Colors.white70,
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _cropAndSave() async {
    if (_decodedImage == null) return;
    setState(() => _isCropping = true);

    try {
      final RenderBox? renderBox =
          _cropKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox == null) return;

      final Size cropSize = renderBox.size;
      final Matrix4 transform = _transformationController.value;

      const int targetWidth = 1080;
      const int targetHeight = 1920;

      final double viewportW = cropSize.width;
      final double viewportH = cropSize.height;
      final double imgW = _decodedImage!.width.toDouble();
      final double imgH = _decodedImage!.height.toDouble();
      final double viewportAspect = viewportW / viewportH;
      final double imgAspect = imgW / imgH;

      double childW, childH;
      if (imgAspect > viewportAspect) {
        childH = viewportH;
        childW = viewportH * imgAspect;
      } else {
        childW = viewportW;
        childH = viewportW / imgAspect;
      }

      final double scaleFactor = targetWidth / viewportW;

      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder);

      // Scale canvas so that the viewport matches the output target resolution (1080 x 1920)
      canvas.scale(scaleFactor, scaleFactor);

      // Apply the user's pan / zoom transform
      canvas.transform(transform.storage);

      // Draw the original image onto the child's layout rectangle
      final Rect srcRect = Rect.fromLTWH(0, 0, imgW, imgH);
      final Rect dstRect = Rect.fromLTWH(0, 0, childW, childH);
      final Paint paint = Paint()..filterQuality = ui.FilterQuality.high;
      canvas.drawImageRect(_decodedImage!, srcRect, dstRect, paint);

      final ui.Picture picture = recorder.endRecording();
      final ui.Image croppedImage =
          await picture.toImage(targetWidth, targetHeight);
      final ByteData? byteData =
          await croppedImage.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) throw Exception("Failed to encode cropped image");

      final String tempPath =
          '${Directory.systemTemp.path}/cropped_${DateTime.now().millisecondsSinceEpoch}.png';
      final File croppedFile = File(tempPath);
      await croppedFile.writeAsBytes(byteData.buffer.asUint8List());

      if (mounted) {
        Navigator.pop(context, croppedFile);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCropping = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error cropping image: $e"),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

class _StoryGridPainter extends CustomPainter {
  final Color gridColor;
  final Color cornerColor;

  _StoryGridPainter({
    required this.gridColor,
    required this.cornerColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = gridColor
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    // Rule of thirds vertical lines
    canvas.drawLine(
      Offset(size.width / 3, 0),
      Offset(size.width / 3, size.height),
      linePaint,
    );
    canvas.drawLine(
      Offset(size.width * 2 / 3, 0),
      Offset(size.width * 2 / 3, size.height),
      linePaint,
    );

    // Rule of thirds horizontal lines
    canvas.drawLine(
      Offset(0, size.height / 3),
      Offset(size.width, size.height / 3),
      linePaint,
    );
    canvas.drawLine(
      Offset(0, size.height * 2 / 3),
      Offset(size.width, size.height * 2 / 3),
      linePaint,
    );

    // Camera Corner Brackets
    final cornerPaint = Paint()
      ..color = cornerColor
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    const double cornerLen = 16.0;

    // Top-Left
    canvas.drawLine(const Offset(4, 4), const Offset(4 + cornerLen, 4), cornerPaint);
    canvas.drawLine(const Offset(4, 4), const Offset(4, 4 + cornerLen), cornerPaint);

    // Top-Right
    canvas.drawLine(
      Offset(size.width - 4, 4),
      Offset(size.width - 4 - cornerLen, 4),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(size.width - 4, 4),
      Offset(size.width - 4, 4 + cornerLen),
      cornerPaint,
    );

    // Bottom-Left
    canvas.drawLine(
      Offset(4, size.height - 4),
      Offset(4 + cornerLen, size.height - 4),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(4, size.height - 4),
      Offset(4, size.height - 4 - cornerLen),
      cornerPaint,
    );

    // Bottom-Right
    canvas.drawLine(
      Offset(size.width - 4, size.height - 4),
      Offset(size.width - 4 - cornerLen, size.height - 4),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(size.width - 4, size.height - 4),
      Offset(size.width - 4, size.height - 4 - cornerLen),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _StoryGridPainter oldDelegate) =>
      oldDelegate.gridColor != gridColor ||
      oldDelegate.cornerColor != cornerColor;
}
