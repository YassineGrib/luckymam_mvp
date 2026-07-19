/// A print order for a physical copy of a predefined or standard album.
/// Immutable once created — status changes are handled by the fulfillment
/// team, not the client (audit trail).
class PrintOrder {
  final String id;
  final String userId;
  final String childId;
  final String childName;
  final String albumId;

  /// 'predefined' | 'standard'
  final String albumType;
  final String albumTitle;
  final int pageCount;

  final String fullName;
  final String phone;
  final String wilaya;
  final String address;

  /// Whether this order is covered by the VIP free-print perk.
  final bool isVipFree;

  final String status; // pending, processing, shipped, delivered
  final DateTime createdAt;

  const PrintOrder({
    required this.id,
    required this.userId,
    required this.childId,
    required this.childName,
    required this.albumId,
    required this.albumType,
    required this.albumTitle,
    required this.pageCount,
    required this.fullName,
    required this.phone,
    required this.wilaya,
    required this.address,
    required this.isVipFree,
    this.status = 'pending',
    required this.createdAt,
  });

  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    'childId': childId,
    'childName': childName,
    'albumId': albumId,
    'albumType': albumType,
    'albumTitle': albumTitle,
    'pageCount': pageCount,
    'fullName': fullName,
    'phone': phone,
    'wilaya': wilaya,
    'address': address,
    'isVipFree': isVipFree,
    'status': status,
    'createdAt': createdAt.toIso8601String(),
  };
}
