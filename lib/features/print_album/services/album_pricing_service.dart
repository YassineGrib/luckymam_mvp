import 'package:intl/intl.dart';

/// Official pricing engine for LuckyMam photobooks and printed albums.
/// Complies with Algerian specifications LM-FREE-001 and LM-ORD-001:
/// - Currency: Algerian Dinar (DA / DZD).
/// - Quantities allowed: 1, 2, 4, 6, 8, 10, 12 photos.
/// - Formats: A5 (15x21 cm), A4 (21x30 cm), A3 (30x42 cm - 1 photo portrait only).
/// - Shipping fee: shown on a separate line (500 DA standard, 0 DA for VIP).
/// - Mandatory notice: "Prix hors frais de livraison".
class AlbumPricingService {
  const AlbumPricingService();

  static const List<int> allowedPhotoCounts = [1, 2, 4, 6, 8, 10, 12];
  static const List<String> availableFormats = ['A5', 'A4', 'A3'];

  /// Standard shipping fee in Dinar Algérien (500 DA across Algerian wilayas).
  static const int standardShippingFee = 500;

  /// Official Price Table in DZD (DA) - Exclusive of shipping fees.
  /// Map<photoCount, Map<format, priceInDA>>
  static const Map<int, Map<String, int>> _officialPriceGrid = {
    1: {'A5': 440, 'A4': 690, 'A3': 990},
    2: {'A5': 830, 'A4': 1280},
    4: {'A5': 1210, 'A4': 1860},
    6: {'A5': 1980, 'A4': 3030},
    8: {'A5': 2750, 'A4': 4200},
    10: {'A5': 3520, 'A4': 5370},
    12: {'A5': 4290, 'A4': 6540},
  };

  /// Returns the base price in DA for an album with [photoCount] photos in [format].
  /// Returns null if the combination is not defined (e.g. A3 with > 1 photo).
  static int? getAlbumPrice({
    required int photoCount,
    required String format,
  }) {
    final formatUpper = format.trim().toUpperCase();
    final row = _officialPriceGrid[photoCount];
    if (row == null) return null;
    return row[formatUpper];
  }

  /// Checks whether a combination of [photoCount] and [format] is defined and available.
  static bool isOptionAvailable({
    required int photoCount,
    required String format,
  }) {
    return getAlbumPrice(photoCount: photoCount, format: format) != null;
  }

  /// Calculates the starting price (lowest available format) for a given [photoCount].
  static int getStartingPriceForPhotoCount(int photoCount) {
    final row = _officialPriceGrid[photoCount];
    if (row == null || row.isEmpty) return 440;
    // A5 is always the lowest price tier
    return row['A5'] ?? row.values.first;
  }

  /// Calculates shipping fee according to VIP membership.
  static int calculateShippingFee({required bool isVip}) {
    return isVip ? 0 : standardShippingFee;
  }

  /// Calculates the total order cost.
  /// Returns null if the combination has no price defined.
  static int? calculateOrderTotal({
    required int photoCount,
    required String format,
    required bool isVip,
    int copies = 1,
  }) {
    final basePrice = getAlbumPrice(photoCount: photoCount, format: format);
    if (basePrice == null) return null;

    final subtotal = basePrice * (copies > 0 ? copies : 1);
    final shipping = calculateShippingFee(isVip: isVip);
    return subtotal + shipping;
  }

  /// Formats an amount in Algerian Dinars with proper thousand separators.
  /// Example: 1980 -> "1 980 DA"
  static String formatDinar(int amount, {String? locale}) {
    final isAr = locale == 'ar';
    final formatter = NumberFormat('#,###', isAr ? 'ar_DZ' : 'fr_FR');
    final formatted = formatter.format(amount).replaceAll('\u00A0', ' ');
    return '$formatted ${isAr ? 'د.ج' : 'DA'}';
  }

  /// Formats price or displays "Non défini" / "غير متوفر" if not available.
  static String formatPriceOrUnavailable(int? price, {String? locale}) {
    if (price == null) {
      final isAr = locale == 'ar';
      return isAr ? 'غير متوفر' : 'Non défini';
    }
    return formatDinar(price, locale: locale);
  }
}

