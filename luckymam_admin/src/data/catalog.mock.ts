export type ProductCategory =
  | "puericulture"
  | "alimentation"
  | "hygiene"
  | "eveil"
  | "maman";

export const CATEGORY_META: Record<
  ProductCategory,
  { label: string; emoji: string }
> = {
  puericulture: { label: "رعاية الرضع / العتاد", emoji: "🍼" },
  alimentation: { label: "تغذية الرضع", emoji: "🥣" },
  hygiene: { label: "النظافة والعناية", emoji: "🧴" },
  eveil: { label: "ألعاب التنمية واليقظة", emoji: "🧸" },
  maman: { label: "عناية الأم", emoji: "🌸" },
};

export type ProductStatus = "active" | "draft" | "out_of_stock" | "archived";

export const PRODUCT_STATUS_META: Record<
  ProductStatus,
  { label: string; chip: string; dot: string }
> = {
  active: {
    label: "منشور",
    chip: "bg-emerald-50 text-emerald-700 ring-emerald-200",
    dot: "bg-emerald-500",
  },
  draft: {
    label: "مسودة",
    chip: "bg-slate-50 text-slate-600 ring-slate-200",
    dot: "bg-slate-400",
  },
  out_of_stock: {
    label: "نفدت الكمية",
    chip: "bg-amber-50 text-amber-700 ring-amber-200",
    dot: "bg-amber-500",
  },
  archived: {
    label: "مؤرشف",
    chip: "bg-rose-50 text-rose-700 ring-rose-200",
    dot: "bg-rose-500",
  },
};

export type Product = {
  id: string;
  sku: string;
  title: string;
  name: string; // Sync with MarketplaceProduct field
  description: string;
  emoji: string;
  imageUrl?: string;
  category: ProductCategory;
  partnerId: string;
  vendor: string; // display name
  price: number;
  priceDZD: number; // Sync with MarketplaceProduct field
  compareAt?: number;
  stock: number;
  sold: number;
  rating: number;
  reviews: number;
  status: ProductStatus;
  createdAt: string;
  featured?: boolean;
  highlights?: string[];
};

export const products: Product[] = [];

export const formatDZD = (n: number) =>
  new Intl.NumberFormat("fr-DZ").format(n) + " دج";
