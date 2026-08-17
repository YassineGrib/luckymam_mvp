import { createFileRoute } from "@tanstack/react-router";
import { useMemo, useState, useEffect } from "react";
import {
  Search,
  Plus,
  Package,
  Star,
  TrendingUp,
  Boxes,
  AlertTriangle,
  Sparkles,
  LayoutGrid,
  Rows3,
  MoreHorizontal,
  Pencil,
  Archive,
  Upload,
  Film,
  Camera,
  Image as ImageIcon,
  Baby,
  Utensils,
  Sparkle,
  Gamepad2,
  Heart,
  Tag,
  CheckCircle,
} from "lucide-react";

import { AppShell } from "@/components/admin/AppShell";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Checkbox } from "@/components/ui/checkbox";
import { cn } from "@/lib/utils";
import {
  CATEGORY_META,
  PRODUCT_STATUS_META,
  type Product,
  type ProductCategory,
  type ProductStatus,
} from "@/data/catalog.mock";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogFooter,
  DialogDescription,
} from "@/components/ui/dialog";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Progress } from "@/components/ui/progress";
import { useI18n } from "@/i18n";
import "@/i18n/pages/marketplace-catalog";

// Firebase imports
import { 
  collection, 
  onSnapshot, 
  query, 
  doc, 
  addDoc, 
  updateDoc, 
  getDoc 
} from "firebase/firestore";
import { ref, uploadBytesResumable, getDownloadURL } from "firebase/storage";
import { db, storage } from "@/lib/firebase";

export const Route = createFileRoute("/marketplace-catalog")({
  head: () => ({
    meta: [
      { title: "كتالوج المتجر — Luckymam Admin" },
      {
        name: "description",
        content: "إدارة المنتجات، الفئات، المخزون، والأسعار في متجر Luckymam.",
      },
    ],
  }),
  component: CatalogPage,
});

type CatFilter = "all" | ProductCategory;
type StatusFilter = "all" | ProductStatus;
type View = "grid" | "list";
type SortKey = "recent" | "top" | "low_stock" | "price_desc" | "price_asc";

const SORTS: { key: SortKey; label: string }[] = [
  { key: "recent", label: "الأحدث" },
  { key: "top", label: "الأكثر مبيعًا" },
  { key: "low_stock", label: "المخزون المنخفض" },
  { key: "price_desc", label: "السعر: الأعلى" },
  { key: "price_asc", label: "السعر: الأقل" },
];

// Aligned partners/vendors metadata
export const PARTNER_META: Record<string, { name: string; phone: string; color: string }> = {
  partner_bebeconfort_dz: { name: "BébéConfort DZ", phone: "0550 12 34 56", color: "#4F8289" },
  partner_naturalait: { name: "NaturaLait", phone: "0551 22 33 44", color: "#F9AD4A" },
  partner_douceur_maman: { name: "Douceur Maman", phone: "0552 55 66 77", color: "#A7316E" },
  partner_eveil_jeux: { name: "Éveil & Jeux", phone: "0553 88 99 00", color: "#E85A71" },
};

// Lucide category icons mapping to replace emojis
export const CATEGORY_ICONS: Record<ProductCategory, React.ElementType> = {
  puericulture: Baby,
  alimentation: Utensils,
  hygiene: Sparkle,
  eveil: Gamepad2,
  maman: Heart,
};

// Client-side Image compression and resizing helper
async function compressAndResizeImage(file: File, maxWidth = 800, maxHeight = 800, quality = 0.75): Promise<Blob> {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.readAsDataURL(file);
    reader.onload = (event) => {
      const img = new Image();
      img.src = event.target?.result as string;
      img.onload = () => {
        const canvas = document.createElement("canvas");
        let width = img.width;
        let height = img.height;

        // Keep aspect ratio
        if (width > height) {
          if (width > maxWidth) {
            height = Math.round((height * maxWidth) / width);
            width = maxWidth;
          }
        } else {
          if (height > maxHeight) {
            width = Math.round((width * maxHeight) / height);
            height = maxHeight;
          }
        }

        canvas.width = width;
        canvas.height = height;

        const ctx = canvas.getContext("2d");
        ctx?.drawImage(img, 0, 0, width, height);

        canvas.toBlob(
          (blob) => {
            if (blob) {
              resolve(blob);
            } else {
              reject(new Error("Canvas to blob conversion failed"));
            }
          },
          "image/jpeg",
          quality
        );
      };
      img.onerror = (err) => reject(err);
    };
    reader.onerror = (err) => reject(err);
  });
}

function CatalogPage() {
  const { tr, dir } = useI18n();

  const formatDZD = (n: number) => {
    return new Intl.NumberFormat("fr-DZ").format(n) + " " + tr("د.ج");
  };

  // Firestore product list state
  const [items, setItems] = useState<Product[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // Filters state
  const [cat, setCat] = useState<CatFilter>("all");
  const [status, setStatus] = useState<StatusFilter>("all");
  const [queryStr, setQueryStr] = useState("");
  const [view, setView] = useState<View>("grid");
  const [sort, setSort] = useState<SortKey>("recent");

  // Form Dialog state
  const [isFormOpen, setIsFormOpen] = useState(false);
  const [editingProduct, setEditingProduct] = useState<Product | null>(null);

  // Form fields
  const [title, setTitle] = useState("");
  const [description, setDescription] = useState("");
  const [price, setPrice] = useState<number>(0);
  const [compareAt, setCompareAt] = useState<number | undefined>(undefined);
  const [partnerId, setPartnerId] = useState("partner_bebeconfort_dz");
  const [category, setCategory] = useState<ProductCategory>("puericulture");
  const [emoji, setEmoji] = useState("🍼");
  const [imageUrl, setImageUrl] = useState("");
  const [highlightsStr, setHighlightsStr] = useState("");
  const [stock, setStock] = useState<number>(10);
  const [productStatus, setProductStatus] = useState<ProductStatus>("active");
  const [featured, setFeatured] = useState(false);
  const [sku, setSku] = useState("");

  // Upload state
  const [uploading, setUploading] = useState(false);
  const [uploadProgress, setUploadProgress] = useState(0);
  const [uploadError, setUploadError] = useState<string | null>(null);

  // Listen to Firestore products
  useEffect(() => {
    const q = query(collection(db, "marketplace_products"));
    const unsubscribe = onSnapshot(
      q,
      (snapshot) => {
        const productList = snapshot.docs.map((d) => {
          const data = d.data();
          const pId = data.partnerId || "partner_bebeconfort_dz";
          const partnerName = PARTNER_META[pId]?.name || data.vendor || tr("مورد غير معروف");

          return {
            id: d.id,
            sku: data.sku || `SKU-${d.id.substring(0, 6).toUpperCase()}`,
            title: data.name || data.title || "",
            name: data.name || data.title || "",
            description: data.description || "",
            emoji: data.emoji || "📦",
            imageUrl: data.imageUrl || "",
            category: data.category || "puericulture",
            partnerId: pId,
            vendor: partnerName,
            price: Number(data.priceDZD || data.price || 0),
            priceDZD: Number(data.priceDZD || data.price || 0),
            compareAt: data.compareAt ? Number(data.compareAt) : undefined,
            stock: Number(data.stock !== undefined ? data.stock : 0),
            sold: Number(data.sold || 0),
            rating: Number(data.rating || 5.0),
            reviews: Number(data.reviews || 0),
            status: data.status || "active",
            createdAt: data.createdAt || new Date().toISOString().split("T")[0],
            featured: data.featured || false,
            highlights: data.highlights || [],
          } as Product;
        });

        setItems(productList);
        setLoading(false);
        setError(null);
      },
      (err) => {
        console.error("Firestore products listening error:", err);
        setError(err.message);
        setLoading(false);
      }
    );
    return unsubscribe;
  }, [tr]);

  // Set form fields
  const openForm = (prod: Product | null = null) => {
    setUploadError(null);
    setUploadProgress(0);
    setUploading(false);

    if (prod) {
      setEditingProduct(prod);
      setSku(prod.sku);
      setTitle(prod.title);
      setDescription(prod.description);
      setPrice(prod.priceDZD);
      setCompareAt(prod.compareAt);
      setPartnerId(prod.partnerId);
      setCategory(prod.category);
      setEmoji(prod.emoji);
      setImageUrl(prod.imageUrl || "");
      setHighlightsStr((prod.highlights || []).join(", "));
      setStock(prod.stock);
      setProductStatus(prod.status);
      setFeatured(prod.featured || false);
    } else {
      setEditingProduct(null);
      setSku(`SKU-${Math.floor(100000 + Math.random() * 900000)}`);
      setTitle("");
      setDescription("");
      setPrice(0);
      setCompareAt(undefined);
      setPartnerId("partner_bebeconfort_dz");
      setCategory("puericulture");
      setEmoji("🍼");
      setImageUrl("");
      setHighlightsStr("");
      setStock(10);
      setProductStatus("active");
      setFeatured(false);
    }
    setIsFormOpen(true);
  };

  // Image Compression & Resizing before Upload
  async function handleImageUpload(e: React.ChangeEvent<HTMLInputElement>) {
    const file = e.target.files?.[0];
    if (!file) return;

    setUploadError(null);
    setUploadProgress(0);
    setUploading(true);

    try {
      // 1. Compress & resize client side (Max 800x800, JPEG 75% quality)
      console.log(`Original file size: ${(file.size / 1024).toFixed(1)} KB`);
      const compressedBlob = await compressAndResizeImage(file, 800, 800, 0.75);
      console.log(`Compressed size: ${(compressedBlob.size / 1024).toFixed(1)} KB`);

      // 2. Upload to Storage
      const fileName = `prod_${Date.now()}_image.jpg`;
      const storageRef = ref(storage, `products/${fileName}`);
      const uploadTask = uploadBytesResumable(storageRef, compressedBlob);

      uploadTask.on(
        "state_changed",
        (snapshot) => {
          const progress = Math.round((snapshot.bytesTransferred / snapshot.totalBytes) * 100);
          setUploadProgress(progress);
        },
        (err) => {
          console.error("Storage image upload error:", err);
          setUploadError(`خطأ أثناء الرفع: ${err.message}`);
          setUploading(false);
        },
        async () => {
          try {
            const downloadUrl = await getDownloadURL(uploadTask.snapshot.ref);
            setImageUrl(downloadUrl);
            setUploading(false);
            setUploadProgress(100);
          } catch (err: any) {
            setUploadError(`خطأ الحصول على رابط الصورة: ${err.message}`);
            setUploading(false);
          }
        }
      );
    } catch (compressErr: any) {
      setUploadError(`خطأ في ضغط الصورة: ${compressErr.message}`);
      setUploading(false);
    }
  }

  // Save changes to Firestore
  async function handleSaveProduct(e: React.FormEvent) {
    e.preventDefault();

    const data = {
      sku,
      title, // Backward compatibility
      name: title, // Main MarketplaceProduct field
      description,
      priceDZD: Number(price),
      price: Number(price),
      compareAt: compareAt ? Number(compareAt) : null,
      partnerId,
      vendor: PARTNER_META[partnerId]?.name || "مورد معروف",
      category,
      emoji,
      imageUrl,
      highlights: highlightsStr
        .split(",")
        .map((h) => h.trim())
        .filter((h) => h.length > 0),
      stock: Number(stock),
      status: Number(stock) === 0 ? "out_of_stock" : productStatus,
      featured,
      createdAt: editingProduct ? editingProduct.createdAt : new Date().toISOString().split("T")[0],
    };

    try {
      if (editingProduct) {
        const docRef = doc(db, "marketplace_products", editingProduct.id);
        await updateDoc(docRef, data);
      } else {
        const collRef = collection(db, "marketplace_products");
        await addDoc(collRef, {
          ...data,
          sold: 0,
          rating: 5.0,
          reviews: 0,
        });
      }
      setIsFormOpen(false);
      setEditingProduct(null);
    } catch (err: any) {
      console.error("Error saving product:", err);
      alert(`خطأ أثناء الحفظ: ${err.message}`);
    }
  }

  // Archive Policy (Archiving instead of deleting)
  async function handleArchiveProduct(prod: Product) {
    const confirmMsg = tr("هل أنتِ متأكدة من أرشفة هذا المنتج؟ لن يظهر للمشترين في المتجر ولكنه سيبقى في السجلات لحماية تاريخ الطلبات.");
    if (!confirm(confirmMsg)) return;

    try {
      const docRef = doc(db, "marketplace_products", prod.id);
      await updateDoc(docRef, { status: "archived" });
    } catch (err: any) {
      console.error("Error archiving product:", err);
      alert(`خطأ أثناء الأرشفة: ${err.message}`);
    }
  }

  // Auto update status to Out of Stock in Firestore when stock hits 0
  const checkStockAndStatus = async (prod: Product, newStock: number) => {
    try {
      const docRef = doc(db, "marketplace_products", prod.id);
      await updateDoc(docRef, {
        stock: newStock,
        status: newStock === 0 ? "out_of_stock" : prod.status === "out_of_stock" ? "active" : prod.status,
      });
    } catch (err) {
      console.error("Error updating stock quantity:", err);
    }
  };

  // Compute stats
  const stats = useMemo(() => {
    const active = items.filter((p) => p.status === "active").length;
    const stock = items.reduce((s, p) => s + p.stock, 0);
    const low = items.filter(
      (p) => p.status !== "archived" && p.stock > 0 && p.stock <= 10
    ).length;
    const out = items.filter((p) => p.stock === 0).length;
    const revenue = items.reduce((s, p) => s + p.sold * p.priceDZD, 0);
    return { active, stock, low, out, revenue };
  }, [items]);

  // Compute counts per category
  const catCounts = useMemo(() => {
    const base: Record<CatFilter, number> = {
      all: items.length,
      puericulture: 0,
      alimentation: 0,
      hygiene: 0,
      eveil: 0,
      maman: 0,
    };
    for (const p of items) {
      if (base[p.category] !== undefined) {
        base[p.category]++;
      }
    }
    return base;
  }, [items]);

  // Filtered and Sorted Products
  const filtered = useMemo(() => {
    let list = items.filter((p) => {
      if (cat !== "all" && p.category !== cat) return false;
      if (status !== "all" && p.status !== status) return false;
      if (queryStr) {
        const q = queryStr.toLowerCase().trim();
        if (
          !p.title.toLowerCase().includes(q) &&
          !p.sku.toLowerCase().includes(q) &&
          !p.vendor.toLowerCase().includes(q) &&
          !(p.description || "").toLowerCase().includes(q)
        )
          return false;
      }
      return true;
    });

    list = [...list].sort((a, b) => {
      switch (sort) {
        case "top":
          return b.sold - a.sold;
        case "low_stock":
          return a.stock - b.stock;
        case "price_desc":
          return b.priceDZD - a.priceDZD;
        case "price_asc":
          return a.priceDZD - b.priceDZD;
        default:
          return a.createdAt < b.createdAt ? 1 : -1;
      }
    });
    return list;
  }, [items, cat, status, queryStr, sort]);

  return (
    <AppShell>
      <div className="p-6 lg:p-10 space-y-8 max-w-[1600px] text-start" dir={dir}>
        {/* Header */}
        <header className="flex flex-wrap items-end justify-between gap-4">
          <div>
            <div className="text-xs font-bold uppercase tracking-[0.2em] text-cherry-600 mb-2 inline-flex items-center gap-2">
              <Package className="size-3.5" /> {tr("إدارة المنتجات")}
            </div>
            <h1 className="font-display font-extrabold text-3xl md:text-4xl tracking-tight">
              {tr("كتالوج المتجر")}
            </h1>
            <p className="text-sm text-ink-muted mt-2 max-w-[56ch]">
              {tr("كل ما تعرضينه في متجر Luckymam. أضيفي منتجات، تابعي المخزون، وأبرزي منتجاتك المميزة.")}
            </p>
          </div>
          <div className="flex items-center gap-2">
            <Button 
              onClick={() => openForm()}
              className="rounded-full bg-cherry-600 hover:bg-cherry-500 text-white shadow-sm shadow-cherry-600/30 font-semibold"
            >
              <Plus className="size-4 ml-1.5" />
              {tr("منتج جديد")}
            </Button>
          </div>
        </header>

        {/* KPI Panel */}
        {loading ? (
          <div className="text-center py-6 text-sm text-ink-muted">{tr("جاري تحميل البيانات...")}</div>
        ) : error ? (
          <div className="text-center py-6 text-sm text-rose-500 border border-rose-100 rounded-2xl bg-rose-50/50">{error}</div>
        ) : (
          <>
            <section className="grid grid-cols-2 md:grid-cols-4 gap-3">
              <KpiCard
                label={tr("منتجات منشورة")}
                value={String(stats.active)}
                hint={`${tr("من أصل")} ${items.length}`}
                icon={Sparkles}
                hero
              />
              <KpiCard
                label={tr("إجمالي المخزون")}
                value={String(stats.stock)}
                hint={tr("قطعة متوفرة")}
                icon={Boxes}
              />
              <KpiCard
                label={tr("مخزون منخفض")}
                value={String(stats.low)}
                hint={tr("10 قطع أو أقل")}
                icon={AlertTriangle}
                tone="amber"
              />
              <KpiCard
                label={tr("قيمة المبيعات")}
                value={formatDZD(stats.revenue)}
                hint={`${stats.out} ${tr("منتج نافد")}`}
                icon={TrendingUp}
              />
            </section>

            {/* Category filters */}
            <section className="flex flex-wrap items-center gap-2">
              <CatChip
                active={cat === "all"}
                onClick={() => setCat("all")}
                label={tr("كل الفئات")}
                icon={Sparkles}
                count={catCounts.all}
              />
              {(Object.keys(CATEGORY_META) as ProductCategory[]).map((k) => {
                const IconComponent = CATEGORY_ICONS[k] || Package;
                return (
                  <CatChip
                    key={k}
                    active={cat === k}
                    onClick={() => setCat(k)}
                    label={tr(CATEGORY_META[k].label)}
                    icon={IconComponent}
                    count={catCounts[k]}
                  />
                );
              })}
            </section>

            {/* Toolbar */}
            <section className="flex flex-wrap items-center justify-between gap-3">
              <div className="flex flex-wrap items-center gap-2">
                <div className="inline-flex items-center rounded-full bg-white ring-1 ring-border p-1 text-[11px] font-semibold">
                  {(["all", "active", "draft", "out_of_stock", "archived"] as StatusFilter[]).map((s) => (
                    <button
                      key={s}
                      onClick={() => setStatus(s)}
                      className={cn(
                        "px-3 py-1 rounded-full transition-colors cursor-pointer",
                        status === s
                          ? "bg-cherry-600 text-white"
                          : "text-ink-muted hover:text-cherry-600",
                      )}
                    >
                      {s === "all" ? tr("كل الحالات") : tr(PRODUCT_STATUS_META[s].label)}
                    </button>
                  ))}
                </div>
                <div className="inline-flex items-center rounded-full bg-white ring-1 ring-border p-1 text-[11px] font-semibold">
                  {SORTS.map((s) => (
                    <button
                      key={s.key}
                      onClick={() => setSort(s.key)}
                      className={cn(
                        "px-3 py-1 rounded-full transition-colors cursor-pointer",
                        sort === s.key
                          ? "bg-ink text-white"
                          : "text-ink-muted hover:text-ink",
                      )}
                    >
                      {tr(s.label)}
                    </button>
                  ))}
                </div>
              </div>
              <div className="flex items-center gap-2">
                <div className="relative">
                  <Search className="size-4 text-ink-muted absolute right-3 top-1/2 -translate-y-1/2" />
                  <Input
                    value={queryStr}
                    onChange={(e) => setQueryStr(e.target.value)}
                    placeholder={tr("بحث بالاسم، SKU، أو المورد…")}
                    className="w-72 rounded-full pr-9 bg-white border-border/70 focus-visible:ring-cherry-200"
                  />
                </div>
                <div className="inline-flex items-center rounded-full bg-white ring-1 ring-border p-1">
                  <button
                    onClick={() => setView("grid")}
                    aria-label={tr("عرض شبكي")}
                    className={cn(
                      "size-8 rounded-full grid place-items-center transition-colors cursor-pointer",
                      view === "grid"
                        ? "bg-cherry-600 text-white"
                        : "text-ink-muted hover:text-cherry-600",
                    )}
                  >
                    <LayoutGrid className="size-4" />
                  </button>
                  <button
                    onClick={() => setView("list")}
                    aria-label={tr("عرض قائمة")}
                    className={cn(
                      "size-8 rounded-full grid place-items-center transition-colors cursor-pointer",
                      view === "list"
                        ? "bg-cherry-600 text-white"
                        : "text-ink-muted hover:text-cherry-600",
                    )}
                  >
                    <Rows3 className="size-4" />
                  </button>
                </div>
              </div>
            </section>

            <div className="text-xs text-ink-muted -mt-4">
              <span className="font-bold text-ink">{filtered.length}</span> {tr("منتج مطابق")}
            </div>

            {/* Grid & List views */}
            {view === "grid" ? (
              <section className="grid grid-cols-2 md:grid-cols-3 xl:grid-cols-4 gap-4">
                {filtered.map((p) => (
                  <ProductCard 
                    key={p.id} 
                    product={p} 
                    onEdit={() => openForm(p)}
                    onArchive={() => handleArchiveProduct(p)}
                  />
                ))}
                {filtered.length === 0 && <EmptyState />}
              </section>
            ) : (
              <section className="rounded-3xl bg-white ring-1 ring-border/70 overflow-hidden shadow-sm shadow-cherry-100/40">
                <div className="overflow-x-auto">
                  <table className="w-full text-sm">
                    <thead>
                      <tr className="text-[11px] uppercase tracking-wider text-ink-muted bg-cherry-50/50">
                        <Th>{tr("المنتج")}</Th>
                        <Th>{tr("الفئة")}</Th>
                        <Th>{tr("المورد")}</Th>
                        <Th>{tr("السعر")}</Th>
                        <Th>{tr("المخزون")}</Th>
                        <Th>{tr("المبيعات")}</Th>
                        <Th>{tr("التقييم")}</Th>
                        <Th>{tr("الحالة")}</Th>
                        <Th className="text-left">{""}</Th>
                      </tr>
                    </thead>
                    <tbody>
                      {filtered.map((p) => {
                        const s = PRODUCT_STATUS_META[p.status];
                        const IconComp = CATEGORY_ICONS[p.category] || Package;
                        return (
                          <tr
                            key={p.id}
                            className="border-t border-border/60 hover:bg-cherry-50/40 transition-colors"
                          >
                            <td className="px-5 py-3">
                              <div className="flex items-center gap-3">
                                {p.imageUrl ? (
                                  <img src={p.imageUrl} alt={p.title} className="size-11 rounded-2xl object-cover ring-1 ring-border/60" />
                                ) : (
                                  <div className="size-11 rounded-2xl bg-cherry-50 ring-1 ring-cherry-100 grid place-items-center text-xl">
                                    {p.emoji || "📦"}
                                  </div>
                                )}
                                <div>
                                  <div className="font-semibold text-[13px] text-ink">
                                    {p.title}
                                  </div>
                                  <div className="text-[10px] text-ink-muted font-mono">
                                    {p.sku}
                                  </div>
                                </div>
                              </div>
                            </td>
                            <td className="px-5 py-3 text-xs">
                              <span className="inline-flex items-center gap-1 rounded-full bg-cherry-50 px-2.5 py-1 font-semibold text-cherry-600 ring-1 ring-cherry-100/50">
                                <IconComp className="size-3.5 ml-1" />
                                {tr(CATEGORY_META[p.category].label)}
                              </span>
                            </td>
                            <td className="px-5 py-3 text-xs text-ink-muted">
                              {p.vendor}
                            </td>
                            <td className="px-5 py-3">
                              <div className="font-display font-bold text-sm">
                                {formatDZD(p.priceDZD)}
                              </div>
                              {p.compareAt && (
                                <div className="text-[10px] text-ink-muted line-through">
                                  {formatDZD(p.compareAt)}
                                </div>
                              )}
                            </td>
                            <td className="px-5 py-3">
                              <StockBar stock={p.stock} />
                            </td>
                            <td className="px-5 py-3 text-xs font-semibold">
                              {p.sold}
                            </td>
                            <td className="px-5 py-3">
                              <div className="inline-flex items-center gap-1 text-xs">
                                <Star className="size-3.5 fill-amber-400 text-amber-400" />
                                <span className="font-semibold">{p.rating}</span>
                                <span className="text-ink-muted">({p.reviews})</span>
                              </div>
                            </td>
                            <td className="px-5 py-3">
                              <span
                                className={cn(
                                  "inline-flex items-center gap-1.5 rounded-full px-2.5 py-1 text-[11px] font-semibold ring-1",
                                  s.chip,
                                )}
                              >
                                <span className={cn("size-1.5 rounded-full", s.dot)} />
                                {tr(s.label)}
                              </span>
                            </td>
                            <td className="px-5 py-3">
                              <RowMenu 
                                onEdit={() => openForm(p)}
                                onArchive={() => handleArchiveProduct(p)}
                              />
                            </td>
                          </tr>
                        );
                      })}
                      {filtered.length === 0 && (
                        <tr>
                          <td colSpan={9}>
                            <EmptyState />
                          </td>
                        </tr>
                      )}
                    </tbody>
                  </table>
                </div>
              </section>
            )}
          </>
        )}
      </div>

      {/* Add / Edit Form Modal */}
      <Dialog open={isFormOpen} onOpenChange={setIsFormOpen}>
        <DialogContent className="max-w-4xl text-start font-sans max-h-[90vh] overflow-y-auto" dir={dir}>
          <DialogHeader>
            <DialogTitle className="font-display font-extrabold text-2xl text-ink">
              {editingProduct ? tr("تعديل بيانات منتج") : tr("إضافة منتج جديد للمتجر")}
            </DialogTitle>
          </DialogHeader>

          <form onSubmit={handleSaveProduct} className="grid grid-cols-1 md:grid-cols-2 gap-6 py-4">
            {/* Left Column: Form Details */}
            <div className="space-y-4">
              <div className="grid grid-cols-2 gap-3">
                <div className="space-y-2">
                  <Label htmlFor="prod-title" className="text-xs font-semibold text-ink">
                    {tr("اسم المنتج")}
                  </Label>
                  <Input
                    id="prod-title"
                    required
                    placeholder={tr("مثال: حفاضات قطنية")}
                    value={title}
                    onChange={(e) => setTitle(e.target.value)}
                    className="rounded-xl border-border/80 focus-visible:ring-cherry-200"
                  />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="prod-sku" className="text-xs font-semibold text-ink">
                    {tr("رقم SKU المنتج")}
                  </Label>
                  <Input
                    id="prod-sku"
                    required
                    placeholder="PROD-12345"
                    value={sku}
                    onChange={(e) => setSku(e.target.value)}
                    className="rounded-xl border-border/80 focus-visible:ring-cherry-200 font-mono text-left"
                    dir="ltr"
                  />
                </div>
              </div>

              <div className="space-y-2">
                <Label htmlFor="prod-desc" className="text-xs font-semibold text-ink">
                  {tr("وصف المنتج")}
                </Label>
                <Textarea
                  id="prod-desc"
                  placeholder={tr("تفاصيل ومواصفات المنتج...")}
                  value={description}
                  onChange={(e) => setDescription(e.target.value)}
                  className="rounded-xl border-border/80 focus-visible:ring-cherry-200 min-h-[90px]"
                />
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div className="space-y-2">
                  <Label htmlFor="prod-price" className="text-xs font-semibold text-ink">
                    {tr("السعر (دينار جزائري)")}
                  </Label>
                  <Input
                    id="prod-price"
                    type="number"
                    required
                    min={0}
                    value={price}
                    onChange={(e) => setPrice(Number(e.target.value))}
                    className="rounded-xl border-border/80 focus-visible:ring-cherry-200"
                  />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="prod-compare" className="text-xs font-semibold text-ink">
                    {tr("السعر السابق / المقارنة")}
                  </Label>
                  <Input
                    id="prod-compare"
                    type="number"
                    placeholder="مثال: 3200"
                    value={compareAt || ""}
                    onChange={(e) => setCompareAt(e.target.value ? Number(e.target.value) : undefined)}
                    className="rounded-xl border-border/80 focus-visible:ring-cherry-200"
                  />
                </div>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div className="space-y-2">
                  <Label className="text-xs font-semibold text-ink">{tr("المورد / الشريك")}</Label>
                  <Select value={partnerId} onValueChange={setPartnerId}>
                    <SelectTrigger className="rounded-xl border-border/80 focus:ring-cherry-200">
                      <SelectValue placeholder={tr("اختر المورد")} />
                    </SelectTrigger>
                    <SelectContent className="text-start">
                      {Object.keys(PARTNER_META).map((key) => (
                        <SelectItem key={key} value={key} className="text-start flex">
                          {PARTNER_META[key].name}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>
                <div className="space-y-2">
                  <Label className="text-xs font-semibold text-ink">{tr("فئة المنتج")}</Label>
                  <Select
                    value={category}
                    onValueChange={(val: ProductCategory) => setCategory(val)}
                  >
                    <SelectTrigger className="rounded-xl border-border/80 focus:ring-cherry-200">
                      <SelectValue placeholder={tr("اختر الفئة")} />
                    </SelectTrigger>
                    <SelectContent className="text-start">
                      {(Object.keys(CATEGORY_META) as ProductCategory[]).map((k) => {
                        const ItemIcon = CATEGORY_ICONS[k] || Tag;
                        return (
                          <SelectItem key={k} value={k} className="text-start flex">
                            <div className="flex items-center gap-2">
                              <ItemIcon className="size-3.5 shrink-0 me-1.5" />
                              <span>{CATEGORY_META[k].label}</span>
                            </div>
                          </SelectItem>
                        );
                      })}
                    </SelectContent>
                  </Select>
                </div>
              </div>

              <div className="grid grid-cols-3 gap-2">
                <div className="space-y-2 col-span-2">
                  <Label htmlFor="prod-status" className="text-xs font-semibold text-ink">{tr("الحالة")}</Label>
                  <Select
                    value={productStatus}
                    onValueChange={(val: ProductStatus) => setProductStatus(val)}
                  >
                    <SelectTrigger className="rounded-xl border-border/80 focus:ring-cherry-200">
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent className="text-start">
                      {(["active", "draft", "archived"] as ProductStatus[]).map((s) => (
                        <SelectItem key={s} value={s} className="text-start flex">
                          {tr(PRODUCT_STATUS_META[s].label)}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>
                <div className="space-y-2">
                  <Label htmlFor="prod-stock" className="text-xs font-semibold text-ink">
                    {tr("الكمية")}
                  </Label>
                  <Input
                    id="prod-stock"
                    type="number"
                    required
                    min={0}
                    value={stock}
                    onChange={(e) => setStock(Number(e.target.value))}
                    className="rounded-xl border-border/80 focus-visible:ring-cherry-200"
                  />
                </div>
              </div>
            </div>

            {/* Right Column: Upload & fallbacks */}
            <div className="space-y-4 flex flex-col justify-between">
              <div className="space-y-4">
                <div className="space-y-2">
                  <Label className="text-xs font-semibold text-ink">{tr("صورة المنتج")}</Label>
                  <div className="border-2 border-dashed border-border/90 rounded-2xl p-4 bg-muted/20 flex flex-col items-center justify-center text-center relative hover:border-cherry-300 transition-colors">
                    <input
                      type="file"
                      accept="image/*"
                      onChange={handleImageUpload}
                      disabled={uploading}
                      className="absolute inset-0 opacity-0 cursor-pointer disabled:cursor-not-allowed"
                    />
                    <Upload className="size-6 text-cherry-600 mb-2" />
                    <span className="text-xs font-bold text-ink">{tr("اسحب صورة المنتج هنا أو انقر للتصفح")}</span>
                    <span className="text-[10px] text-ink-muted mt-1 leading-normal">
                      {tr("سيتم تصغير وضغط الصورة تلقائياً لتوفير مساحة التخزين")}
                    </span>
                  </div>

                  {/* Upload progress indicator */}
                  {uploading && (
                    <div className="space-y-1.5 p-3 rounded-xl bg-cherry-50/50 border border-cherry-100">
                      <div className="flex justify-between items-center text-[10px] font-bold text-cherry-700">
                        <span>{tr("جاري ضغط ورفع الصورة...")}</span>
                        <span>{uploadProgress}%</span>
                      </div>
                      <Progress value={uploadProgress} className="h-1.5 bg-cherry-100" />
                    </div>
                  )}

                  {uploadError && (
                    <div className="flex items-start gap-2 p-3 rounded-xl border border-rose-200 bg-rose-50 text-[10px] text-rose-600 font-semibold leading-normal">
                      <AlertTriangle className="size-4 shrink-0" />
                      <span>{uploadError}</span>
                    </div>
                  )}
                </div>

                <div className="grid grid-cols-3 gap-2">
                  <div className="space-y-2 col-span-2">
                    <Label htmlFor="prod-url" className="text-xs font-semibold text-ink">
                      {tr("أو أدخل رابط الصورة مباشرة")}
                    </Label>
                    <Input
                      id="prod-url"
                      type="url"
                      placeholder="https://..."
                      value={imageUrl}
                      onChange={(e) => setImageUrl(e.target.value)}
                      className="rounded-xl border-border/80 focus-visible:ring-cherry-200 text-left text-xs"
                      dir="ltr"
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="prod-emoji" className="text-xs font-semibold text-ink">
                      {tr("الرمز البديل")}
                    </Label>
                    <Input
                      id="prod-emoji"
                      placeholder="🍼"
                      value={emoji}
                      onChange={(e) => setEmoji(e.target.value)}
                      className="rounded-xl border-border/80 focus-visible:ring-cherry-200 text-center text-lg"
                    />
                  </div>
                </div>

                <div className="space-y-2">
                  <Label htmlFor="prod-highlights" className="text-xs font-semibold text-ink">
                    {tr("المميزات ( highlights )")}
                  </Label>
                  <Input
                    id="prod-highlights"
                    placeholder={tr("ميزة 1, ميزة 2, ميزة 3")}
                    value={highlightsStr}
                    onChange={(e) => setHighlightsStr(e.target.value)}
                    className="rounded-xl border-border/80 focus-visible:ring-cherry-200 text-xs"
                  />
                </div>
              </div>

              {/* Featured & Confirmations buttons */}
              <div className="pt-4 border-t border-border/60 space-y-4">
                <div className="flex items-center justify-end gap-3 cursor-pointer">
                  <Label htmlFor="prod-featured" className="text-xs font-semibold text-ink cursor-pointer">
                    {tr("تثبيت المنتج كـ مميز")}
                  </Label>
                  <Checkbox
                    id="prod-featured"
                    checked={featured}
                    onCheckedChange={(checked) => setFeatured(Boolean(checked))}
                    className="data-[state=checked]:bg-cherry-600 data-[state=checked]:border-cherry-600 rounded-md"
                  />
                </div>

                <div className="flex items-center justify-center p-3 rounded-xl border border-emerald-100 bg-emerald-50/30 text-[10px] text-emerald-800 font-semibold gap-2 leading-relaxed">
                  <CheckCircle className="size-4 shrink-0 text-emerald-600" />
                  <span>{tr("المنتجات المضافة يتم ربطها لحظياً مع التطبيق وسيتم توجيهها للشركاء المقابلين.")}</span>
                </div>
              </div>
            </div>

            <div className="col-span-full border-t border-border/60 pt-4 flex justify-end gap-2.5">
              <Button
                type="button"
                variant="outline"
                onClick={() => setIsFormOpen(false)}
                className="rounded-full"
              >
                {tr("إلغاء")}
              </Button>
              <Button
                type="submit"
                disabled={uploading}
                className="rounded-full bg-cherry-600 hover:bg-cherry-700 text-white font-semibold px-6 shadow-md"
              >
                {tr("حفظ ونشر المنتج")}
              </Button>
            </div>
          </form>
        </DialogContent>
      </Dialog>
    </AppShell>
  );
}

// Subcomponents

interface ProductCardProps {
  product: Product;
  onEdit: () => void;
  onArchive: () => void;
}

function ProductCard({ product: p, onEdit, onArchive }: ProductCardProps) {
  const { tr } = useI18n();
  const formatDZD = (n: number) =>
    new Intl.NumberFormat("fr-DZ").format(n) + " " + tr("د.ج");
  const s = PRODUCT_STATUS_META[p.status];
  const discount = p.compareAt
    ? Math.round(((p.compareAt - p.priceDZD) / p.compareAt) * 100)
    : 0;
  const CategoryIcon = CATEGORY_ICONS[p.category] || Package;

  return (
    <article className="group rounded-3xl bg-white ring-1 ring-border/70 overflow-hidden transition-all hover:-translate-y-0.5 hover:ring-cherry-200 hover:shadow-lg hover:shadow-cherry-100/50">
      <div className="relative aspect-[4/3] bg-gradient-to-br from-cherry-50 to-white grid place-items-center overflow-hidden">
        {p.imageUrl ? (
          <img src={p.imageUrl} alt={p.title} className="w-full h-full object-cover transition-transform group-hover:scale-105" />
        ) : (
          <span className="text-6xl transition-transform group-hover:scale-110">
            {p.emoji || "📦"}
          </span>
        )}
        <div className="absolute top-3 right-3 flex flex-col items-end gap-1.5">
          {p.featured && (
            <span className="inline-flex items-center gap-1 rounded-full bg-ink text-white px-2 py-0.5 text-[10px] font-bold">
              <Sparkles className="size-3" /> {tr("مميّز")}
            </span>
          )}
          {discount > 0 && (
            <span className="inline-flex items-center rounded-full bg-cherry-600 text-white px-2 py-0.5 text-[10px] font-bold">
              -{discount}%
            </span>
          )}
        </div>
        <div className="absolute top-3 left-3">
          <span
            className={cn(
              "inline-flex items-center gap-1.5 rounded-full px-2.5 py-1 text-[10px] font-semibold ring-1 bg-white/90 backdrop-blur",
              s.chip,
            )}
          >
            <span className={cn("size-1.5 rounded-full", s.dot)} />
            {tr(s.label)}
          </span>
        </div>
        <div className="absolute bottom-3 left-3">
          <RowMenu onEdit={onEdit} onArchive={onArchive} />
        </div>
      </div>
      <div className="p-4 space-y-2">
        <div className="flex items-center justify-between text-[10px]">
          <span className="inline-flex items-center gap-1 rounded-full bg-cherry-50 px-2 py-0.5 font-semibold text-cherry-600 ring-1 ring-cherry-100/50">
            <CategoryIcon className="size-3.5 ml-1" />
            {tr(CATEGORY_META[p.category].label)}
          </span>
          <div className="inline-flex items-center gap-1 text-ink-muted">
            <Star className="size-3 fill-amber-400 text-amber-400" />
            <span className="font-semibold text-ink">{p.rating}</span>
            <span>({p.reviews})</span>
          </div>
        </div>
        <h3 className="font-semibold text-[14px] leading-snug line-clamp-2 min-h-[2.6em] text-start">
          {p.title}
        </h3>
        <div className="text-[11px] text-ink-muted text-start">{p.vendor}</div>
        <div className="flex items-end justify-between pt-1">
          <div>
            <div className="font-display font-extrabold text-lg text-cherry-600">
              {formatDZD(p.priceDZD)}
            </div>
            {p.compareAt && (
              <div className="text-[11px] text-ink-muted line-through">
                {formatDZD(p.compareAt)}
              </div>
            )}
          </div>
          <div className="text-left">
            <div className="text-[10px] uppercase tracking-wider text-ink-muted">
              {tr("بيعت")}
            </div>
            <div className="text-[13px] font-bold">{p.sold}</div>
          </div>
        </div>
        <div className="pt-2">
          <StockBar stock={p.stock} />
        </div>
      </div>
    </article>
  );
}

function StockBar({ stock }: { stock: number }) {
  const { tr } = useI18n();
  const max = 100;
  const pct = Math.min(100, (stock / max) * 100);
  const color =
    stock === 0
      ? "bg-rose-500"
      : stock <= 10
      ? "bg-amber-500"
      : "bg-emerald-500";
  const label =
    stock === 0 ? tr("نفدت الكمية") : stock <= 10 ? tr("منخفض") : tr("متوفر");
  return (
    <div>
      <div className="flex items-center justify-between text-[10px] mb-1">
        <span className="text-ink-muted">
          <span className="font-bold text-ink">{stock}</span> {tr("قطعة")}
        </span>
        <span
          className={cn(
            "font-semibold",
            stock === 0
              ? "text-rose-600"
              : stock <= 10
              ? "text-amber-600"
              : "text-emerald-600",
          )}
        >
          {label}
        </span>
      </div>
      <div className="h-1.5 rounded-full bg-cherry-50 overflow-hidden">
        <div
          className={cn("h-full rounded-full transition-all", color)}
          style={{ width: `${pct}%` }}
        />
      </div>
    </div>
  );
}

interface RowMenuProps {
  onEdit: () => void;
  onArchive: () => void;
}

function RowMenu({ onEdit, onArchive }: RowMenuProps) {
  const { tr } = useI18n();
  return (
    <DropdownMenu>
      <DropdownMenuTrigger asChild>
        <button
          aria-label={tr("خيارات")}
          className="size-8 rounded-full bg-white/90 backdrop-blur ring-1 ring-border grid place-items-center text-ink-muted hover:text-cherry-600 hover:ring-cherry-200 transition-colors cursor-pointer"
        >
          <MoreHorizontal className="size-4" />
        </button>
      </DropdownMenuTrigger>
      <DropdownMenuContent align="end" className="text-xs text-start font-sans">
        <DropdownMenuItem onClick={onEdit} className="text-start flex cursor-pointer">
          <Pencil className="size-3.5 me-2" /> {tr("تعديل")}
        </DropdownMenuItem>
        <DropdownMenuItem onClick={onArchive} className="text-rose-600 text-start flex cursor-pointer">
          <Archive className="size-3.5 me-2" /> {tr("أرشفة")}
        </DropdownMenuItem>
      </DropdownMenuContent>
    </DropdownMenu>
  );
}

interface CatChipProps {
  active: boolean;
  onClick: () => void;
  label: string;
  icon: React.ElementType;
  count: number;
}

function CatChip({
  active,
  onClick,
  label,
  icon: Icon,
  count,
}: CatChipProps) {
  return (
    <button
      onClick={onClick}
      className={cn(
        "inline-flex items-center gap-2 rounded-2xl px-4 py-2 text-xs font-semibold ring-1 transition-all cursor-pointer",
        active
          ? "bg-cherry-600 text-white ring-cherry-600 shadow-sm shadow-cherry-600/30"
          : "bg-white text-ink ring-border hover:ring-cherry-200 hover:text-cherry-600",
      )}
    >
      <Icon className="size-4 shrink-0" />
      <span>{label}</span>
      <span
        className={cn(
          "rounded-full px-1.5 py-0 text-[10px] font-bold",
          active ? "bg-white/20 text-white" : "bg-cherry-100 text-cherry-600",
        )}
      >
        {count}
      </span>
    </button>
  );
}

interface KpiCardProps {
  label: string;
  value: string;
  hint: string;
  icon: React.ElementType;
  hero?: boolean;
  tone?: "amber";
}

function KpiCard({
  label,
  value,
  hint,
  icon: Icon,
  hero,
  tone,
}: KpiCardProps) {
  const { dir } = useI18n();
  return (
    <div
      className={cn(
        "rounded-2xl p-5 ring-1 relative overflow-hidden text-start",
        hero
          ? "bg-gradient-to-bl from-cherry-600 to-cherry-500 text-white ring-cherry-600/40"
          : "bg-white ring-border/70 shadow-sm",
      )}
      dir={dir}
    >
      <div className="flex items-center justify-between mb-3">
        <span
          className={cn(
            "size-9 rounded-xl grid place-items-center",
            hero
              ? "bg-white/15 text-white"
              : tone === "amber"
              ? "bg-amber-100 text-amber-600"
              : "bg-cherry-100 text-cherry-600",
          )}
        >
          <Icon className="size-4" />
        </span>
      </div>
      <div
        className={cn(
          "font-display font-extrabold tracking-tight mt-1",
          hero ? "text-3xl" : "text-2xl",
        )}
      >
        {value}
      </div>
      <div
        className={cn(
          "mt-3 text-[11px] font-semibold uppercase tracking-wider",
          hero ? "text-white/70" : "text-ink-muted",
        )}
      >
        {label}
      </div>
      <div
        className={cn(
          "text-[10px] mt-1",
          hero ? "text-white/70" : "text-ink-muted",
        )}
      >
        {hint}
      </div>
    </div>
  );
}

interface ThProps {
  children: React.ReactNode;
  className?: string;
}

function Th({ children, className }: ThProps) {
  return (
    <th className={cn("px-5 py-3 text-start font-semibold", className)}>
      {children}
    </th>
  );
}

function EmptyState() {
  const { tr } = useI18n();
  return (
    <div className="col-span-full px-5 py-16 text-center">
      <div className="mx-auto size-12 rounded-2xl bg-cherry-100 grid place-items-center text-cherry-600 mb-3">
        <Package className="size-5" />
      </div>
      <div className="text-sm font-semibold">{tr("لا توجد منتجات مطابقة")}</div>
      <div className="text-xs text-ink-muted mt-1">
        {tr("جرّبي تعديل الفلاتر أو أضيفي منتجًا جديدًا.")}
      </div>
    </div>
  );
}
