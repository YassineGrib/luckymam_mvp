import 'package:flutter_test/flutter_test.dart';
import 'package:lukymam_mvp/features/memory_book/models/standard_album.dart';
import 'package:lukymam_mvp/features/print_album/models/print_order.dart';
import 'package:lukymam_mvp/features/print_album/services/album_pricing_service.dart';

void main() {
  group('LM-FREE-001 & LM-ORD-001: Photo Quantities & Official Pricing Grid', () {
    test('Allowed photo quantities are strictly [1, 2, 4, 6, 8, 10, 12]', () {
      expect(
        AlbumPricingService.allowedPhotoCounts,
        equals([1, 2, 4, 6, 8, 10, 12]),
      );
    });

    test('Official pricing matrix matches Algerian specification exactly', () {
      // 1 photo
      expect(AlbumPricingService.getAlbumPrice(photoCount: 1, format: 'A5'), equals(440));
      expect(AlbumPricingService.getAlbumPrice(photoCount: 1, format: 'A4'), equals(690));
      expect(AlbumPricingService.getAlbumPrice(photoCount: 1, format: 'A3'), equals(990));

      // 2 photos
      expect(AlbumPricingService.getAlbumPrice(photoCount: 2, format: 'A5'), equals(830));
      expect(AlbumPricingService.getAlbumPrice(photoCount: 2, format: 'A4'), equals(1280));
      expect(AlbumPricingService.getAlbumPrice(photoCount: 2, format: 'A3'), isNull);

      // 4 photos
      expect(AlbumPricingService.getAlbumPrice(photoCount: 4, format: 'A5'), equals(1210));
      expect(AlbumPricingService.getAlbumPrice(photoCount: 4, format: 'A4'), equals(1860));
      expect(AlbumPricingService.getAlbumPrice(photoCount: 4, format: 'A3'), isNull);

      // 6 photos (Acceptance Criterion: Un album A5 avec 6 photos affiche 1 980 DA)
      expect(AlbumPricingService.getAlbumPrice(photoCount: 6, format: 'A5'), equals(1980));
      expect(AlbumPricingService.getAlbumPrice(photoCount: 6, format: 'A4'), equals(3030));
      expect(AlbumPricingService.getAlbumPrice(photoCount: 6, format: 'A3'), isNull);

      // 8 photos
      expect(AlbumPricingService.getAlbumPrice(photoCount: 8, format: 'A5'), equals(2750));
      expect(AlbumPricingService.getAlbumPrice(photoCount: 8, format: 'A4'), equals(4200));
      expect(AlbumPricingService.getAlbumPrice(photoCount: 8, format: 'A3'), isNull);

      // 10 photos (Acceptance Criterion: Un album A4 avec 10 photos affiche 5 370 DA)
      expect(AlbumPricingService.getAlbumPrice(photoCount: 10, format: 'A5'), equals(3520));
      expect(AlbumPricingService.getAlbumPrice(photoCount: 10, format: 'A4'), equals(5370));
      expect(AlbumPricingService.getAlbumPrice(photoCount: 10, format: 'A3'), isNull);

      // 12 photos
      expect(AlbumPricingService.getAlbumPrice(photoCount: 12, format: 'A5'), equals(4290));
      expect(AlbumPricingService.getAlbumPrice(photoCount: 12, format: 'A4'), equals(6540));
      expect(AlbumPricingService.getAlbumPrice(photoCount: 12, format: 'A3'), isNull);
    });

    test('A3 format is disabled and returns null for any photo count > 1 (No invented prices)', () {
      for (final count in [2, 4, 6, 8, 10, 12, 16, 20]) {
        expect(
          AlbumPricingService.getAlbumPrice(photoCount: count, format: 'A3'),
          isNull,
          reason: 'A3 price must NOT be invented for $count photos',
        );
        expect(
          AlbumPricingService.isOptionAvailable(photoCount: count, format: 'A3'),
          isFalse,
        );
      }

      // Only 1 photo A3 is available (Acceptance Criterion: portrait A3 avec 1 photo affiche 990 DA)
      expect(AlbumPricingService.isOptionAvailable(photoCount: 1, format: 'A3'), isTrue);
      expect(AlbumPricingService.getAlbumPrice(photoCount: 1, format: 'A3'), equals(990));
    });

    test('Thousand separators are formatted properly', () {
      expect(AlbumPricingService.formatDinar(1980), equals('1 980 DA'));
      expect(AlbumPricingService.formatDinar(5370), equals('5 370 DA'));
      expect(AlbumPricingService.formatDinar(990), equals('990 DA'));
      expect(AlbumPricingService.formatDinar(6540), equals('6 540 DA'));
    });

    test('Order calculation computes subtotal and shipping fee dynamically', () {
      // Non-VIP: Subtotal 1980 + Shipping 500 = 2480 DA
      final totalStandard = AlbumPricingService.calculateOrderTotal(
        photoCount: 6,
        format: 'A5',
        isVip: false,
        copies: 1,
      );
      expect(totalStandard, equals(2480));

      // VIP: Subtotal 1980 + Shipping 0 = 1980 DA
      final totalVip = AlbumPricingService.calculateOrderTotal(
        photoCount: 6,
        format: 'A5',
        isVip: true,
        copies: 1,
      );
      expect(totalVip, equals(1980));

      // Multiple copies (2 copies of A4 10 photos: 5370 * 2 = 10740 + 500 = 11240 DA)
      final totalMultiple = AlbumPricingService.calculateOrderTotal(
        photoCount: 10,
        format: 'A4',
        isVip: false,
        copies: 2,
      );
      expect(totalMultiple, equals(11240));

      // Invalid combination returns null
      final totalInvalid = AlbumPricingService.calculateOrderTotal(
        photoCount: 6,
        format: 'A3',
        isVip: false,
      );
      expect(totalInvalid, isNull);
    });

    test('StandardAlbum model supports custom photo capacities (1, 2, 4, 6, 8, 10, 12)', () {
      final now = DateTime.now();

      final albumSingle = StandardAlbum(
        id: 'alb-1',
        userId: 'u1',
        childId: 'c1',
        title: 'Portrait Souvenir',
        pageCount: 1,
        createdAt: now,
        updatedAt: now,
      );
      expect(albumSingle.pageCount, equals(1));

      final albumLarge = StandardAlbum(
        id: 'alb-12',
        userId: 'u1',
        childId: 'c1',
        title: 'Grand Livre Bébé',
        pageCount: 12,
        createdAt: now,
        updatedAt: now,
        pageCapsules: const {
          '0': 'cap-0',
          '1': 'cap-1',
        },
      );
      expect(albumLarge.pageCount, equals(12));
      expect(albumLarge.filledCount, equals(2));
    });

    test('PrintOrder stores immutable pricing snapshot at order time', () {
      final now = DateTime.now();
      final order = PrintOrder(
        id: 'ord-123',
        userId: 'u1',
        childId: 'c1',
        childName: 'Sarah',
        albumId: 'alb-standard',
        albumType: 'standard',
        albumTitle: 'Album de Sarah',
        pageCount: 6,
        format: 'A5',
        subtotal: 1980,
        shippingFee: 500,
        totalAmount: 2480,
        albumCopies: 1,
        fullName: 'Amina MAM',
        phone: '0550123456',
        wilaya: '16 - Alger',
        address: 'Didouche Mourad, Alger Centre',
        isVipFree: false,
        createdAt: now,
      );

      final map = order.toFirestore();
      expect(map['format'], equals('A5'));
      expect(map['subtotal'], equals(1980));
      expect(map['shippingFee'], equals(500));
      expect(map['totalAmount'], equals(2480));
      expect(map['albumCopies'], equals(1));
      expect(map['wilaya'], equals('16 - Alger'));
    });
  });
}

