// Mirrors small, stable string enums defined on the Flutter side.
// Keep in sync by hand — this is a two-file diff, not a shared package.
// Source of truth for each:
//   PrintOrderStatus     ← lib/features/print_album/models/print_order.dart
//   AlbumClaimStatus     ← lib/features/subscription/models/subscription_models.dart (AlbumClaim)
//   MarketplaceOrderStatus ← lib/features/marketplace/models/marketplace_order.dart (OrderStatus)

export const PRINT_ORDER_STATUSES = [
  'pending',
  'processing',
  'shipped',
  'delivered',
] as const
export type PrintOrderStatus = (typeof PRINT_ORDER_STATUSES)[number]

export const ALBUM_CLAIM_STATUSES = [
  'pending',
  'processing',
  'shipped',
  'delivered',
] as const
export type AlbumClaimStatus = (typeof ALBUM_CLAIM_STATUSES)[number]

export const MARKETPLACE_ORDER_STATUSES = [
  'pending',
  'confirmed',
  'shipped',
  'delivered',
  'cancelled',
] as const
export type MarketplaceOrderStatus = (typeof MARKETPLACE_ORDER_STATUSES)[number]

export const STATUS_LABELS_FR: Record<string, string> = {
  pending: 'En attente',
  processing: 'En traitement',
  confirmed: 'Confirmée',
  shipped: 'Expédiée',
  delivered: 'Livrée',
  cancelled: 'Annulée',
}

export const STATUS_COLORS: Record<string, string> = {
  pending: '#F9AD4A',
  processing: '#4F8289',
  confirmed: '#4F8289',
  shipped: '#4F8289',
  delivered: '#43A047',
  cancelled: '#E53935',
}
