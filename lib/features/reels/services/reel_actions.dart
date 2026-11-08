import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Downloads to an isolated temporary directory and always removes the copy.
class ReelActions {
  Future<void> share(String path, String text) =>
      _withVideo(path, (file) async {
        final result = await SharePlus.instance.share(
          ShareParams(
            files: [XFile(file.path, mimeType: 'video/mp4')],
            text: text,
          ),
        );
        if (result.status == ShareResultStatus.unavailable) {
          throw StateError('Sharing unavailable');
        }
      });

  Future<void> save(String path) async {
    if (!await Gal.hasAccess() && !await Gal.requestAccess()) {
      throw StateError('Gallery access denied');
    }
    await _withVideo(path, (file) => Gal.putVideo(file.path));
  }

  Future<void> _withVideo(
    String path,
    Future<void> Function(File) action,
  ) async {
    final directory = await (await getTemporaryDirectory()).createTemp('reel_');
    final file = File('${directory.path}/Luckymam.mp4');
    try {
      if (path.startsWith('https://') || path.startsWith('http://')) {
        final client = http.Client();
        try {
          final response = await client
              .send(http.Request('GET', Uri.parse(path)))
              .timeout(const Duration(seconds: 20));
          if (response.statusCode != 200) {
            throw const HttpException('Video download failed');
          }
          final sink = file.openWrite();
          try {
            await sink
                .addStream(response.stream.timeout(const Duration(seconds: 20)))
                .timeout(const Duration(minutes: 2));
          } finally {
            await sink.close();
          }
        } finally {
          client.close();
        }
      } else {
        final data = await rootBundle.load(path);
        await file.writeAsBytes(
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
        );
      }
      if (await file.length() == 0) throw StateError('Empty video');
      await action(file);
    } finally {
      await directory.delete(recursive: true);
    }
  }
}
