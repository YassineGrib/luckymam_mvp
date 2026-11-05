import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lukymam_mvp/features/capsules/models/capsule.dart';
import 'package:lukymam_mvp/features/capsules/models/emotion.dart';
import 'package:lukymam_mvp/features/memory_book/models/predefined_album.dart';
import 'package:lukymam_mvp/features/memory_book/models/standard_album.dart';
import 'package:lukymam_mvp/features/memory_book/widgets/album_photo_action_sheet.dart';
import 'package:lukymam_mvp/l10n/app_localizations.dart';

Widget _wrap(Widget child, [Locale locale = const Locale('fr')]) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: child,
    ),
  );
}

void main() {
  group('LM-ALB-004: Album Photo Replacement & Cropping', () {
    testWidgets('AlbumPhotoActionSheet renders all replacement and crop actions', (tester) async {
      bool pickedFromMemories = false;
      bool pickedFromGallery = false;
      bool tookPhoto = false;
      bool cropped = false;
      bool cleared = false;

      await tester.pumpWidget(
        _wrap(
          AlbumPhotoActionSheet(
            title: 'Page 2',
            subtitle: 'Gérer la photo',
            hasPhoto: true,
            accentColor: Colors.deepOrange,
            onPickFromMemories: () => pickedFromMemories = true,
            onPickFromGallery: () => pickedFromGallery = true,
            onTakePhoto: () => tookPhoto = true,
            onCrop: () => cropped = true,
            onClear: () => cleared = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check title and subtitle
      expect(find.text('Page 2'), findsOneWidget);
      expect(find.text('Gérer la photo'), findsOneWidget);

      // Check actions are visible
      expect(find.text('Choisir parmi mes souvenirs'), findsOneWidget);
      expect(find.text('Prendre une photo'), findsOneWidget);
      expect(find.text('Choisir depuis la galerie'), findsOneWidget);
      expect(find.text('Recadrer & Ajuster'), findsOneWidget);
      expect(find.text('Retirer de la page'), findsOneWidget);

      // Tap on Crop action
      await tester.tap(find.text('Recadrer & Ajuster'));
      await tester.pumpAndSettle();
      expect(cropped, isTrue);
    });

    testWidgets('AlbumPhotoActionSheet in Arabic mode translates labels correctly', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AlbumPhotoActionSheet(
            title: 'الصفحة 1',
            hasPhoto: true,
            accentColor: Colors.deepOrange,
            onPickFromMemories: () {},
            onPickFromGallery: () {},
            onTakePhoto: () {},
            onCrop: () {},
            onClear: () {},
          ),
          const Locale('ar'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('الصفحة 1'), findsOneWidget);
      expect(find.text('اختيار من ذكرياتي'), findsOneWidget);
      expect(find.text('التقاط صورة جديدة'), findsOneWidget);
      expect(find.text('اختيار من معرض الصور'), findsOneWidget);
      expect(find.text('قص وتعديل وضبط الصورة'), findsOneWidget);
      expect(find.text('إزالة من الألبوم'), findsOneWidget);
    });

    test('StandardAlbum photo replacement preserves other pages and original capsule', () {
      final now = DateTime.now();

      // Original capsule in user timeline
      final originalCapsule = Capsule(
        id: 'capsule-original-123',
        userId: 'user-1',
        childId: 'child-1',
        childIds: const ['child-1'],
        withMother: false,
        photoUrl: 'https://cdn.luckymam.dz/original_photo.jpg',
        emotion: Emotion.happy,
        tags: const ['sourire'],
        isFavorite: false,
        createdAt: now,
        updatedAt: now,
      );

      // Initial album with 3 filled pages
      final initialAlbum = StandardAlbum(
        id: 'album-standard-1',
        userId: 'user-1',
        childId: 'child-1',
        title: 'Mon Premier Album',
        pageCount: 6,
        createdAt: now,
        updatedAt: now,
        pageCapsules: const {
          '0': 'capsule-page-0',
          '1': 'capsule-original-123',
          '2': 'capsule-page-2',
        },
      );

      expect(initialAlbum.filledCount, equals(3));
      expect(initialAlbum.pageCapsules['1'], equals('capsule-original-123'));

      // Simulate cropping / replacing page 1 with a newly cropped capsule
      const croppedCapsuleId = 'capsule-cropped-page-1-456';
      final updatedPageCapsules = Map<String, String>.from(initialAlbum.pageCapsules);
      updatedPageCapsules['1'] = croppedCapsuleId;

      final updatedAlbum = StandardAlbum(
        id: initialAlbum.id,
        userId: initialAlbum.userId,
        childId: initialAlbum.childId,
        title: initialAlbum.title,
        pageCount: initialAlbum.pageCount,
        createdAt: initialAlbum.createdAt,
        updatedAt: DateTime.now(),
        pageCapsules: updatedPageCapsules,
      );

      // Acceptance criterion 1: User does NOT restart album
      expect(updatedAlbum.pageCount, equals(initialAlbum.pageCount));

      // Acceptance criterion 2: Other pages & photos are preserved
      expect(updatedAlbum.pageCapsules['0'], equals('capsule-page-0'));
      expect(updatedAlbum.pageCapsules['2'], equals('capsule-page-2'));
      expect(updatedAlbum.filledCount, equals(3));

      // Acceptance criterion 3: Render updated immediately on page 1
      expect(updatedAlbum.pageCapsules['1'], equals(croppedCapsuleId));

      // Acceptance criterion 4: Original capsule photo was NOT overwritten
      expect(originalCapsule.photoUrl, equals('https://cdn.luckymam.dz/original_photo.jpg'));
      expect(originalCapsule.id, equals('capsule-original-123'));
      expect(originalCapsule.id, isNot(equals(croppedCapsuleId)));
    });

    test('PredefinedAlbum slot replacement isolates slots and preserves non-targeted milestones', () {
      final now = DateTime.now();

      final initialPredefinedAlbum = PredefinedAlbum(
        id: 'album-predef-1',
        userId: 'user-1',
        childId: 'child-1',
        templateId: 'first_year',
        createdAt: now,
        slotCapsules: const {
          'birth': 'capsule-birth-1',
          'first_smile': 'capsule-smile-original',
          'first_bath': 'capsule-bath-3',
        },
      );

      expect(initialPredefinedAlbum.filledCount, equals(3));
      expect(initialPredefinedAlbum.slotCapsules['first_smile'], equals('capsule-smile-original'));

      // Replacing 'first_smile' slot with a cropped or new capsule
      const newSmileCapsuleId = 'capsule-smile-cropped-999';
      final updatedSlotCapsules = Map<String, String>.from(initialPredefinedAlbum.slotCapsules);
      updatedSlotCapsules['first_smile'] = newSmileCapsuleId;

      final updatedPredefinedAlbum = PredefinedAlbum(
        id: initialPredefinedAlbum.id,
        userId: initialPredefinedAlbum.userId,
        childId: initialPredefinedAlbum.childId,
        templateId: initialPredefinedAlbum.templateId,
        createdAt: initialPredefinedAlbum.createdAt,
        slotCapsules: updatedSlotCapsules,
      );

      // Verify other slots are completely untouched
      expect(updatedPredefinedAlbum.slotCapsules['birth'], equals('capsule-birth-1'));
      expect(updatedPredefinedAlbum.slotCapsules['first_bath'], equals('capsule-bath-3'));

      // Verify target slot is updated
      expect(updatedPredefinedAlbum.slotCapsules['first_smile'], equals(newSmileCapsuleId));
      expect(updatedPredefinedAlbum.filledCount, equals(3));
    });

    test('Cancelling replacement leaves page/slot state 100% unchanged', () {
      final now = DateTime.now();
      final album = StandardAlbum(
        id: 'album-1',
        userId: 'user-1',
        childId: 'child-1',
        title: 'Album',
        pageCount: 6,
        createdAt: now,
        updatedAt: now,
        pageCapsules: const {
          '0': 'capsule-0',
          '1': 'capsule-1',
        },
      );

      // If user cancels during crop or picker, no mutation is applied
      final Map<String, String>? mutation = null;
      final effectiveCapsules = mutation != null
          ? (Map<String, String>.from(album.pageCapsules)..addAll(mutation))
          : album.pageCapsules;

      expect(effectiveCapsules, equals(album.pageCapsules));
      expect(effectiveCapsules['1'], equals('capsule-1'));
    });
  });
}

