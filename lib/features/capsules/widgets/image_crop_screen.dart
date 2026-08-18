import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../core/extensions/l10n_extension.dart';
import '../../../core/theme/app_colors.dart';

/// Screen allowing the user to interactively pan, scale, and crop an image to a clean vertical (3:4) ratio.
class ImageCropScreen extends StatefulWidget {
  final File imageFile;

  const ImageCropScreen({
    super.key,
    required this.imageFile,
  });

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

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.primaryDark : AppColors.primaryLight;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.capsuleCropTitle,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: (_decodedImage != null && !_isCropping) ? _cropAndSave : null,
            child: _isCropping
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    l10n.confirm,
                    style: TextStyle(
                      color: primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
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
                  // Top instruction bar — clear and separated from the image
                  Container(
                    margin: const EdgeInsets.fromLTRB(20, 6, 20, 12),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.pinch_rounded,
                          color: Colors.white70,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            l10n.capsuleCropHint,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 9:16 Full Screen Crop Viewport — Expands cleanly without overlap
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: AspectRatio(
                          aspectRatio: 9 / 16,
                          child: Container(
                            key: _cropKey,
                            clipBehavior: Clip.hardEdge,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: primary.withValues(alpha: 0.9),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: primary.withValues(alpha: 0.15),
                                  blurRadius: 16,
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

                                    // Initialize transform to center the image within the viewport
                                    if (!_hasInitializedTransform) {
                                      _hasInitializedTransform = true;
                                      final double initialTx = -(childW - viewportW) / 2;
                                      final double initialTy = -(childH - viewportH) / 2;
                                      _transformationController.value =
                                          Matrix4.identity()..translate(initialTx, initialTy);
                                    }

                                    return InteractiveViewer(
                                      transformationController: _transformationController,
                                      minScale: 1.0,
                                      maxScale: 5.0,
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
                                // Internal grid lines strictly inside the 9:16 frame
                                IgnorePointer(
                                  child: CustomPaint(
                                    painter: _GridPainter(gridColor: Colors.white38),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
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

      // Scale canvas so that the viewport (viewportW x viewportH) matches target output (1080 x 1920)
      canvas.scale(scaleFactor, scaleFactor);

      // Apply the user's pan / zoom transform
      canvas.transform(transform.storage);

      // Draw the original image onto the child's (childW x childH) layout rectangle
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

class _GridPainter extends CustomPainter {
  final Color gridColor;

  _GridPainter({required this.gridColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Rule of thirds vertical lines
    canvas.drawLine(
      Offset(size.width / 3, 0),
      Offset(size.width / 3, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 2 / 3, 0),
      Offset(size.width * 2 / 3, size.height),
      paint,
    );

    // Rule of thirds horizontal lines
    canvas.drawLine(
      Offset(0, size.height / 3),
      Offset(size.width, size.height / 3),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height * 2 / 3),
      Offset(size.width, size.height * 2 / 3),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
