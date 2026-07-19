// Mirrors the Firestore document shapes written by the Flutter app.
// Field names must match exactly — see the .toFirestore() of each model.

export interface BaseOrder {
  id: string
  userId: string
  fullName: string
  phone: string
  wilaya: string
  address: string
  status: string
  createdAt: string // ISO 8601
  statusUpdatedAt?: { seconds: number; nanoseconds: number } | null
  statusUpdatedBy?: string | null
}

/** users/{uid}/... no — top-level `print_orders`. Source: lib/features/print_album/models/print_order.dart */
export interface PrintOrder extends BaseOrder {
  childId: string
  childName: string
  albumId: string
  albumType: 'predefined' | 'standard'
  albumTitle: string
  pageCount: number
  isVipFree: boolean
}

/** Top-level `album_claims`. Source: lib/features/subscription/models/subscription_models.dart (AlbumClaim) */
export interface AlbumClaim extends BaseOrder {
  childId: string
  childName: string
  dateRange: string
}

/** Top-level `marketplace_orders`. Source: lib/features/marketplace/models/marketplace_order.dart */
export interface MarketplaceOrderLine {
  productId: string
  productName: string
  partnerId: string
  unitPriceDZD: number
  quantity: number
  lineTotalDZD: number
}

export interface MarketplaceOrder extends BaseOrder {
  lines: MarketplaceOrderLine[]
  totalDZD: number
}
