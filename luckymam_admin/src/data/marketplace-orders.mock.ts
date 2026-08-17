export type PaymentMethod = "cod" | "card" | "ccp";
export type PaymentStatus = "paid" | "pending" | "refunded";
export type MarketplaceOrderStatus = "pending" | "confirmed" | "shipped" | "delivered" | "cancelled";

export const PAYMENT_META: Record<PaymentMethod, { label: string }> = {
  cod: { label: "الدفع عند الاستلام" },
  card: { label: "بطاقة CIB / EDAHABIA" },
  ccp: { label: "تحويل CCP" },
};

export type MarketplaceItem = {
  sku: string;
  title: string;
  variant?: string;
  qty: number;
  unitPrice: number; // DZD
  image: string; // emoji/fallback icon key
  imageUrl?: string;
  vendor: string;
};

export type MarketplaceOrder = {
  id: string;
  userId?: string;
  customer: {
    name: string;
    initials: string;
    phone: string;
    wilaya: string;
    address: string;
  };
  items: MarketplaceItem[];
  subtotal: number;
  shipping: number;
  total: number;
  payment: {
    method: PaymentMethod;
    status: PaymentStatus;
  };
  createdAt: string;
  status: MarketplaceOrderStatus;
  statusUpdatedAt?: string;
  statusUpdatedBy?: string;
  history?: { status: MarketplaceOrderStatus; at: string; by: string }[];
};

export const marketplaceOrders: MarketplaceOrder[] = [];

export const formatDZD = (n: number) =>
  new Intl.NumberFormat("fr-DZ").format(n) + " دج";
