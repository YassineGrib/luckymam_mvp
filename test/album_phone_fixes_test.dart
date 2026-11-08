import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lukymam_mvp/features/capsules/models/capsule.dart';
import 'package:lukymam_mvp/features/capsules/models/emotion.dart';
import 'package:lukymam_mvp/features/capsules/providers/capsule_providers.dart';
import 'package:lukymam_mvp/features/memory_book/models/standard_album.dart';
import 'package:lukymam_mvp/features/memory_book/widgets/capsule_picker_sheet.dart';
import 'package:lukymam_mvp/features/profile/widgets/edit_dialogs.dart';
import 'package:lukymam_mvp/l10n/app_localizations.dart';

void main() {
  test(
    'order wilayas include every official code through 69 without duplicates',
    () {
      expect(algerianWilayas.length, 69);
      expect(algerianWilayas.toSet().length, 69);
      expect(algerianWilayas[48], 'Timimoun');
      expect(algerianWilayas.sublist(58), [
        'Aflou',
        'Barika',
        'El Kantara',
        'Bir El Ater',
        'El Aricha',
        'Ksar Chellala',
        'Aïn Ouessara',
        'Messaad',
        'Ksar El Boukhari',
        'Bou Saâda',
        'El Abiodh Sidi Cheikh',
      ]);
    },
  );
  test('free album accepts at most six photos', () {
    for (var count = 1; count <= 6; count++) {
      expect(() => StandardAlbum.validatePageCount(count), returnsNormally);
    }
    expect(() => StandardAlbum.validatePageCount(7), throwsArgumentError);
    expect(() => StandardAlbum.validatePageCount(0), throwsArgumentError);
  });
  testWidgets(
    'existing photos appear directly and one tap selects one capsule',
    (tester) async {
      final now = DateTime(2026, 11, 6);
      final photo = Capsule(
        id: 'photo',
        userId: 'user',
        childId: 'child',
        photoUrl: 'https://example.com/photo.jpg',
        emotion: Emotion.happy,
        createdAt: now,
        updatedAt: now,
      );
      Capsule? selected;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            capsulesByChildProvider(
              'child',
            ).overrideWith((ref) => Stream.value([photo])),
          ],
          child: MaterialApp(
            locale: const Locale('fr'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            home: Scaffold(
              body: AlbumExistingPhotoList(
                childId: 'child',
                onSelected: (capsule) => selected = capsule,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ListView), findsOneWidget);
      await tester.tap(find.byType(InkWell));
      expect(selected?.id, 'photo');
    },
  );
}
