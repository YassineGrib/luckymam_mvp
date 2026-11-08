import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lukymam_mvp/features/reels/services/reel_actions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lukymam_mvp/features/reels/models/reel_item.dart';
import 'package:lukymam_mvp/features/reels/widgets/reel_player.dart';
import 'package:lukymam_mvp/l10n/app_localizations.dart';
// Tests replace the platform already supplied transitively by video_player.
// ignore: depend_on_referenced_packages
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

class FakeReelVideo extends VideoPlayerPlatform {
  bool initialize = false;
  int created = 0;
  int plays = 0;
  int pauses = 0;
  @override
  Future<void> init() async {}
  @override
  Future<int?> create(DataSource source) async => ++created;
  @override
  Stream<VideoEvent> videoEventsFor(int id) => initialize
      ? Stream.value(
          VideoEvent(
            eventType: VideoEventType.initialized,
            duration: const Duration(seconds: 30),
            size: const Size(360, 640),
          ),
        )
      : const Stream.empty();
  @override
  Future<void> dispose(int id) async {}
  @override
  Future<void> setLooping(int id, bool value) async {}
  @override
  Future<void> setVolume(int id, double value) async {}
  @override
  Future<void> setPlaybackSpeed(int id, double value) async {}
  @override
  Future<void> play(int id) async {
    plays++;
  }

  @override
  Future<void> pause(int id) async {
    pauses++;
  }

  @override
  Future<Duration> getPosition(int id) async => Duration.zero;
  @override
  Widget buildView(int id) => const SizedBox();
}

Widget app(Widget home) => MaterialApp(
  locale: const Locale('en'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: home,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('gallery denial fails before downloading or reporting saved', () async {
    final calls = <String>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('gal'), (call) async {
          calls.add(call.method);
          return false;
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel('gal'), null),
    );
    await expectLater(
      ReelActions().save('https://example.invalid/video.mp4'),
      throwsStateError,
    );
    expect(calls, ['hasAccess', 'requestAccess']);
  });
  test(
    'localized admin fields override legacy Arabic and survive favorites',
    () {
      final reel = ReelItem.fromMap('one', {
        'title': 'عنوان',
        'description': 'وصف',
        'titleFr': 'Titre',
        'description_en': 'English description',
        'translations': {
          'en': {'title': 'English title'},
        },
        'vaccineTags': ['BCG', 12],
        'likes': '9',
      }).copyWith(isFavorite: true);
      expect(reel.titleFor('fr'), 'Titre');
      expect(reel.titleFor('en'), 'English title');
      expect(reel.descriptionFor('en'), 'English description');
      expect(reel.titleFor('ar'), 'عنوان');
      expect(reel.vaccineTags, ['BCG']);
      expect(reel.likeCount, 9);
    },
  );
  test('canonical legacy seed captions have selected-language fallback', () {
    final reel = ReelItem.fromMap('reel_1', {
      'title': 'عنوان',
      'description': 'وصف',
    });
    expect(reel.titleFor('en'), 'Baby care');
    expect(reel.titleFor('fr'), 'Soins de bébé');
    expect(reel.descriptionFor('en'), contains('newborn'));
    final translated = ReelItem.fromMap('reel_1', {
      'titleEn': 'Updated content',
    });
    expect(translated.titleFor('en'), 'Updated content');
  });
  test('map translations and legacy captions remain compatible', () {
    final reel = ReelItem.fromMap('one', {
      'title': {'fr': 'Titre', 'en': 'Title'},
      'description': 'Legacy',
    });
    expect(reel.titleFor('en'), 'Title');
    expect(reel.descriptionFor('fr'), 'Legacy');
  });
  testWidgets('loading terminates with retry after timeout', (tester) async {
    final platform = FakeReelVideo();
    VideoPlayerPlatform.instance = platform;
    await tester.pumpWidget(
      app(const ReelPlayer(assetPath: 'assets/test.mp4', isActive: true)),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 16));
    await tester.pump();
    expect(find.text('Retry'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(platform.created, 2);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('initialized video that stops progressing offers retry', (
    tester,
  ) async {
    final platform = FakeReelVideo()..initialize = true;
    VideoPlayerPlatform.instance = platform;
    await tester.pumpWidget(
      app(const ReelPlayer(assetPath: 'assets/test.mp4', isActive: true)),
    );
    await tester.pumpAndSettle();
    expect(find.text('Retry'), findsNothing);
    await tester.pump(const Duration(seconds: 16));
    await tester.pump();
    expect(find.text('Retry'), findsOneWidget);
    expect(platform.pauses, greaterThan(0));
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('hidden route never restarts when app resumes', (tester) async {
    final platform = FakeReelVideo()..initialize = true;
    VideoPlayerPlatform.instance = platform;
    await tester.pumpWidget(
      app(
        const Scaffold(
          body: ReelPlayer(assetPath: 'assets/test.mp4', isActive: true),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(platform.plays, greaterThan(0));
    final context = tester.element(find.byType(ReelPlayer));
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: Text('Covered')),
      ),
    );
    await tester.pumpAndSettle();
    final playsBefore = platform.plays;
    expect(platform.pauses, greaterThan(0));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(platform.plays, playsBefore);
    await tester.pumpWidget(const SizedBox());
  });
}
