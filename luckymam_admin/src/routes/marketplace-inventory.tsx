import { createFileRoute } from "@tanstack/react-router";
import { useMemo, useState, useEffect } from "react";
import {
  Boxes,
  Baby,
  Milk,
  Heart,
  Search,
  Plus,
  Minus,
  Save,
  X,
  AlertTriangle,
  TrendingUp,
  PackageOpen,
  DollarSign,
  CheckCircle2,
  PackageCheck,
  Archive,
  Ban,
  Activity,
  Sparkles,
} from "lucide-react";

import { AppShell } from "@/components/admin/AppShell";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { cn } from "@/lib/utils";
import { useI18n } from "@/i18n";
import "@/i18n/pages/inventory";
import { db } from "@/lib/firebase";
import { collection, onSnapshot, query, doc, updateDoc } from "firebase/firestore";

export const Route = createFileRoute("/marketplace-inventory")({
  head: () => ({
    meta: [
      { title: "إدارة المخزون — Luckymam Admin" },
      {
        name: "description",
        content: "متابعة مستويات المخزون، قيمتها الإجمالية، وتعديل كميات الكتالوج لحظياً.",
      },
    ],
  }),
  component: MarketplaceInventoryPage,
});

type StockFilter = "all" | "out" | "low" | "ok";

interface ProductInventoryItem {
  id: string;
  sku: string;
  title: string;
  category: string;
  price: number;
  stock: number;
  status: "active" | "out_of_stock" | "archived";
  imageUrl?: string;
  image?: string;
}

const CATEGORY_META: Record<string, { label: string; icon: React.ElementType; color: string }> = {
  puericulture: { label: "رعاية الرضع", icon: Baby, color: "text-sky-600 bg-sky-50" },
  alimentation: { label: "تغذية الرضع", icon: Milk, color: "text-amber-600 bg-amber-50" },
  hygiene: { label: "نظافة وعناية", icon: Sparkles, color: "text-emerald-600 bg-emerald-50" },
  eveil: { label: "ألعاب وتنمية", icon: Activity, color: "text-violet-600 bg-violet-50" },
  maman: { label: "مستلزمات الأم", icon: Heart, color: "text-cherry-600 bg-cherry-50" },
};

function MarketplaceInventoryPage() {
  const { tr, dir } = useI18n();

  const formatDZD = (n: number) => {
    return new Intl.NumberFormat("fr-DZ").format(n) + " " + tr("دج");
  };

  // Firestore products state
  const [products, setProducts] = useState<ProductInventoryItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // Search, Filters & Editing Local States
  const [searchQuery, setSearchQuery] = useState("");
  const [categoryFilter, setCategoryFilter] = useState<string>("all");
  const [stockFilter, setStockFilter] = useState<StockFilter>("all");
  
  // Track temporary edits before saving: key = productId, value = temporary stock number
  const [editedStocks, setEditedStocks] = useState<Record<string, number>>({});
  const [savingId, setSavingId] = useState<string | null>(null);

  // Listen to Firestore marketplace_products
  useEffect(() => {
    const q = query(collection(db, "marketplace_products"));
    const unsubscribe = onSnapshot(
      q,
      (snapshot) => {
        const list = snapshot.docs.map((d) => {
          const data = d.data();
          return {
            id: d.id,
            sku: data.sku || "",
            title: data.title || "",
            category: data.category || "puericulture",
            price: Number(data.price || 0),
            stock: Number(data.stock || 0),
            status: data.status || "active",
            imageUrl: data.imageUrl || "",
            image: data.image || "📦",
          } as ProductInventoryItem;
        });

        // Filter out fully deleted ones if any, sort alphabetically by title
        setProducts(list.sort((a, b) => a.title.localeCompare(b.title)));
        setLoading(false);
      },
      (err) => {
        console.error("Firestore inventory stream error:", err);
        setError(err.message);
        setLoading(false);
      }
    );
    return unsubscribe;
  }, []);

  // Compute Statistics (Valuation & Alert Levels)
  const stats = useMemo(() => {
    let totalItems = 0;
    let outOfStock = 0;
    let lowStock = 0;
    let totalValuation = 0;

    for (const p of products) {
      if (p.status === "archived") continue;
      totalItems++;
      if (p.stock === 0) {
        outOfStock++;
      } else if (p.stock <= 5) {
        lowStock++;
      }
      totalValuation += p.price * p.stock;
    }

    return { totalItems, outOfStock, lowStock, totalValuation };
  }, [products]);

  // Filtered Products List
  const filtered = useMemo(() => {
    return products.filter((p) => {
      // 1. Search Query
      if (searchQuery) {
        const q = searchQuery.toLowerCase().trim();
        if (
          !p.title.toLowerCase().includes(q) &&
          !p.sku.toLowerCase().includes(q)
        ) {
          return false;
        }
      }

      // 2. Category Filter
      if (categoryFilter !== "all" && p.category !== categoryFilter) return false;

      // 3. Stock Level Alert Filter
      if (stockFilter === "out" && p.stock !== 0) return false;
      if (stockFilter === "low" && (p.stock === 0 || p.stock > 5)) return false;
      if (stockFilter === "ok" && p.stock <= 5) return false;

      return true;
    });
  }, [products, searchQuery, categoryFilter, stockFilter]);

  // Inline Stock Operations
  const handleTempStockChange = (id: string, val: number) => {
    const minVal = Math.max(0, val);
    setEditedStocks((prev) => ({
      ...prev,
      [id]: minVal,
    }));
  };

  const handleIncrementTemp = (id: string, currentVal: number) => {
    const val = editedStocks[id] !== undefined ? editedStocks[id] : currentVal;
    handleTempStockChange(id, val + 1);
  };

  const handleDecrementTemp = (id: string, currentVal: number) => {
    const val = editedStocks[id] !== undefined ? editedStocks[id] : currentVal;
    handleTempStockChange(id, val - 1);
  };

  const cancelEdit = (id: string) => {
    setEditedStocks((prev) => {
      const copy = { ...prev };
      delete copy[id];
      return copy;
    });
  };

  const saveStock = async (id: string, originalItem: ProductInventoryItem) => {
    const newStock = editedStocks[id];
    if (newStock === undefined || newStock === originalItem.stock) return;

    setSavingId(id);
    try {
      const docRef = doc(db, "marketplace_products", id);
      
      // Determine the correct status transition automatically
      let nextStatus = originalItem.status;
      if (originalItem.status !== "archived") {
        nextStatus = newStock > 0 ? "active" : "out_of_stock";
      }

      await updateDoc(docRef, {
        stock: newStock,
        status: nextStatus,
      });

      // Clear temp state for this product
      setEditedStocks((prev) => {
        const copy = { ...prev };
        delete copy[id];
        return copy;
      });
    } catch (err: any) {
      console.error("Error saving stock changes:", err);
      alert(`خطأ أثناء تحديث المخزون: ${err.message}`);
    } finally {
      setSavingId(null);
    }
  };

  // Bulk Quick Add Stock
  const handleBulkAdd = async (id: string, originalItem: ProductInventoryItem, addQty: number) => {
    const newStock = originalItem.stock + addQty;
    try {
      const docRef = doc(db, "marketplace_products", id);
      let nextStatus = originalItem.status;
      if (originalItem.status !== "archived") {
        nextStatus = newStock > 0 ? "active" : "out_of_stock";
      }
      await updateDoc(docRef, {
        stock: newStock,
        status: nextStatus,
      });
    } catch (err: any) {
      console.error("Error doing quick stock addition:", err);
    }
  };

  return (
    <AppShell>
      <div className="p-6 lg:p-10 space-y-8 max-w-[1600px] text-start font-sans" dir={dir}>
        {/* Header */}
        <header className="flex flex-wrap items-end justify-between gap-4">
          <div>
            <div className="text-xs font-bold uppercase tracking-[0.2em] text-cherry-600 mb-2 inline-flex items-center gap-2">
              <Boxes className="size-3.5" /> {tr("إدارة المتجر")}
            </div>
            <h1 className="font-display font-extrabold text-3xl md:text-4xl tracking-tight text-ink">
              {tr("إدارة المخزون والكميات")}
            </h1>
            <p className="text-sm text-ink-muted mt-2 max-w-[56ch]">
              {tr("متابعة المخزون الإجمالي، وتعديل كميات الكتالوج، وإعادة التعبئة وتدبير مستويات التحذير من النفاذ.")}
            </p>
          </div>
        </header>

        {loading ? (
          <div className="text-center py-10 text-sm text-ink-muted">{tr("جاري تحميل الكتالوج والمخازن...")}</div>
        ) : error ? (
          <div className="text-center py-6 text-sm text-rose-500 border border-rose-100 rounded-2xl bg-rose-50/50">{error}</div>
        ) : (
          <>
            {/* KPI Metrics */}
            <section className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3.5">
              <KpiTile
                label={tr("إجمالي المنتجات النشطة")}
                value={String(stats.totalItems)}
                hint={tr("في الكتالوج المعتمد")}
                icon={PackageOpen}
                tone="cherry"
              />
              <KpiTile
                label={tr("منتجات نافدة")}
                value={String(stats.outOfStock)}
                hint={tr("تتطلب إعادة تعبئة عاجلة")}
                icon={Ban}
                tone="amber"
                alert={stats.outOfStock > 0}
              />
              <KpiTile
                label={tr("مخزون منخفض")}
                value={String(stats.lowStock)}
                hint={tr("أقل من 5 قطع متوفرة")}
                icon={AlertTriangle}
                tone="violet"
                alert={stats.lowStock > 0}
              />
              <KpiTile
                label={tr("قيمة المخزون الإجمالية")}
                value={formatDZD(stats.totalValuation)}
                hint={tr("الكمية المتوفرة × السعر")}
                icon={TrendingUp}
                tone="emerald"
              />
            </section>

            {/* Toolbar Filters */}
            <section className="flex flex-wrap items-center justify-between gap-3 bg-white p-4 rounded-2xl ring-1 ring-border/70 shadow-sm shadow-cherry-50">
              <div className="flex flex-wrap items-center gap-3">
                {/* Search */}
                <div className="relative">
                  <Search className="size-4 text-ink-muted absolute right-3 top-1/2 -translate-y-1/2" />
                  <Input
                    value={searchQuery}
                    onChange={(e) => setSearchQuery(e.target.value)}
                    placeholder={tr("بحث بالمنتج أو SKU…")}
                    className="w-64 rounded-full pr-9 bg-muted/40 border-transparent focus-visible:ring-cherry-200"
                  />
                </div>

                {/* Category Filter */}
                <Select value={categoryFilter} onValueChange={setCategoryFilter}>
                  <SelectTrigger className="w-[180px] rounded-full border-border/80 bg-white text-xs font-semibold">
                    <SelectValue placeholder={tr("كل الفئات")} />
                  </SelectTrigger>
                  <SelectContent className="text-right">
                    <SelectItem value="all" className="text-right justify-end flex cursor-pointer">{tr("كل الفئات")}</SelectItem>
                    {Object.entries(CATEGORY_META).map(([key, value]) => (
                      <SelectItem key={key} value={key} className="text-right justify-end flex cursor-pointer">
                        {tr(value.label)}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>

                {/* Stock Level Filter */}
                <div className="inline-flex items-center rounded-full bg-muted/50 p-1 text-[11px] font-semibold ring-1 ring-border/60">
                  <button
                    onClick={() => setStockFilter("all")}
                    className={cn(
                      "px-3 py-1 rounded-full transition-colors cursor-pointer",
                      stockFilter === "all" ? "bg-cherry-600 text-white" : "text-ink-muted",
                    )}
                  >
                    {tr("الكل")}
                  </button>
                  <button
                    onClick={() => setStockFilter("ok")}
                    className={cn(
                      "px-3 py-1 rounded-full transition-colors cursor-pointer",
                      stockFilter === "ok" ? "bg-cherry-600 text-white" : "text-ink-muted",
                    )}
                  >
                    {tr("متوفر")}
                  </button>
                  <button
                    onClick={() => setStockFilter("low")}
                    className={cn(
                      "px-3 py-1 rounded-full transition-colors cursor-pointer",
                      stockFilter === "low" ? "bg-cherry-600 text-white" : "text-ink-muted",
                    )}
                  >
                    {tr("منخفض")}
                  </button>
                  <button
                    onClick={() => setStockFilter("out")}
                    className={cn(
                      "px-3 py-1 rounded-full transition-colors cursor-pointer",
                      stockFilter === "out" ? "bg-cherry-600 text-white" : "text-ink-muted",
                    )}
                  >
                    {tr("نافذ")}
                  </button>
                </div>
              </div>

              <div className="text-xs text-ink-muted">
                {tr("يعرض")} <span className="font-bold text-ink">{filtered.length}</span> {tr("من")} <span className="font-bold text-ink">{products.length}</span> {tr("منتج")}
              </div>
            </section>

            {/* Inventory Table */}
            <section className="rounded-3xl bg-white ring-1 ring-border/70 overflow-hidden shadow-sm shadow-cherry-100/40">
              <div className="overflow-x-auto">
                <table className="w-full text-sm">
                  <thead>
                    <tr className="text-[11px] uppercase tracking-wider text-ink-muted bg-cherry-50/50">
                      <Th>{tr("المنتج")}</Th>
                      <Th>{tr("SKU")}</Th>
                      <Th>{tr("الفئة")}</Th>
                      <Th>{tr("السعر")}</Th>
                      <Th className="text-center w-[200px]">{tr("المخزون المتوفر")}</Th>
                      <Th>{tr("الحالة")}</Th>
                      <Th>{tr("إجمالي القيمة")}</Th>
                      <Th className="text-left">{tr("تعبئة سريعة")}</Th>
                    </tr>
                  </thead>
                  <tbody>
                    {filtered.map((p) => {
                      const CatMeta = CATEGORY_META[p.category];
                      const isEdited = editedStocks[p.id] !== undefined;
                      const displayStock = isEdited ? editedStocks[p.id] : p.stock;

                      // Stock styling alert
                      let stockTextClass = "text-ink font-semibold";
                      let stockBgClass = "bg-slate-50";
                      if (displayStock === 0) {
                        stockTextClass = "text-rose-600 font-bold";
                        stockBgClass = "bg-rose-50";
                      } else if (displayStock <= 5) {
                        stockTextClass = "text-amber-600 font-semibold";
                        stockBgClass = "bg-amber-50";
                      }

                      return (
                        <tr
                          key={p.id}
                          className={cn(
                            "border-t border-border/60 hover:bg-cherry-50/20 transition-colors",
                            p.status === "archived" && "opacity-60 bg-slate-50/30"
                          )}
                        >
                          {/* Product Info */}
                          <td className="px-5 py-4">
                            <div className="flex items-center gap-3 flex-row-reverse text-right">
                              <div className="size-11 rounded-xl bg-cherry-50/50 ring-1 ring-cherry-100/50 grid place-items-center text-xl shrink-0 overflow-hidden">
                                {p.imageUrl ? (
                                  <img src={p.imageUrl} alt={p.title} className="w-full h-full object-cover" />
                                ) : (
                                  <span>{p.image}</span>
                                )}
                              </div>
                              <div className="min-w-0 flex-1">
                                <div className="font-semibold text-xs text-ink truncate max-w-[28ch]" title={p.title}>
                                  {p.title}
                                </div>
                                <div className="text-[10px] text-ink-muted mt-1 font-mono">{p.sku}</div>
                              </div>
                            </div>
                          </td>

                          {/* SKU */}
                          <td className="px-5 py-4 text-xs font-mono text-ink-muted">
                            {p.sku}
                          </td>

                          {/* Category */}
                          <td className="px-5 py-4">
                            {CatMeta ? (
                              <span className={cn("inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-[10px] font-bold", CatMeta.color)}>
                                <CatMeta.icon className="size-3" />
                                {tr(CatMeta.label)}
                              </span>
                            ) : (
                              <span className="text-xs text-ink-muted">—</span>
                            )}
                          </td>

                          {/* Price */}
                          <td className="px-5 py-4 text-xs font-semibold text-ink">
                            {formatDZD(p.price)}
                          </td>

                          {/* Stock Edit Controls */}
                          <td className="px-5 py-4">
                            <div className="flex items-center justify-center gap-2">
                              {/* Save/Cancel Indicators */}
                              {isEdited && (
                                <button
                                  onClick={() => saveStock(p.id, p)}
                                  disabled={savingId === p.id}
                                  className="size-7 rounded-lg bg-emerald-500 text-white grid place-items-center hover:bg-emerald-600 transition-colors shadow shadow-emerald-500/10 cursor-pointer"
                                  title={tr("حفظ التغيير")}
                                >
                                  <Save className="size-3.5" />
                                </button>
                              )}
                              {isEdited && (
                                <button
                                  onClick={() => cancelEdit(p.id)}
                                  className="size-7 rounded-lg bg-slate-100 text-ink-muted grid place-items-center hover:bg-slate-200 transition-colors cursor-pointer"
                                  title={tr("إلغاء")}
                                >
                                  <X className="size-3.5" />
                                </button>
                              )}

                              {/* Number input and +/- adjusters */}
                              <div className={cn("inline-flex items-center rounded-xl p-1 border", isEdited ? "border-emerald-400 ring-2 ring-emerald-100" : "border-border/80")}>
                                <button
                                  onClick={() => handleIncrementTemp(p.id, p.stock)}
                                  className="size-6 rounded-lg hover:bg-slate-100 grid place-items-center text-ink-muted transition-colors cursor-pointer"
                                >
                                  <Plus className="size-3.5" />
                                </button>
                                <input
                                  type="number"
                                  value={displayStock}
                                  onChange={(e) => handleTempStockChange(p.id, Number(e.target.value))}
                                  className={cn("w-12 h-6 text-center border-none focus:outline-none focus:ring-0 text-xs font-bold", stockTextClass)}
                                />
                                <button
                                  onClick={() => handleDecrementTemp(p.id, p.stock)}
                                  className="size-6 rounded-lg hover:bg-slate-100 grid place-items-center text-ink-muted transition-colors cursor-pointer"
                                >
                                  <Minus className="size-3.5" />
                                </button>
                              </div>
                            </div>
                          </td>

                          {/* Status Badge */}
                          <td className="px-5 py-4">
                            {p.status === "archived" ? (
                              <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-full bg-slate-100 text-slate-600 text-[10px] font-semibold ring-1 ring-slate-200">
                                <Archive className="size-3" />
                                {tr("مؤرشف")}
                              </span>
                            ) : p.stock === 0 ? (
                              <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-full bg-rose-50 text-rose-700 text-[10px] font-semibold ring-1 ring-rose-200">
                                <Ban className="size-3" />
                                {tr("نافذ")}
                              </span>
                            ) : p.stock <= 5 ? (
                              <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-full bg-amber-50 text-amber-800 text-[10px] font-semibold ring-1 ring-amber-200">
                                <AlertTriangle className="size-3" />
                                {tr("منخفض")}
                              </span>
                            ) : (
                              <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-full bg-emerald-50 text-emerald-700 text-[10px] font-semibold ring-1 ring-emerald-200">
                                <PackageCheck className="size-3" />
                                {tr("نشط")}
                              </span>
                            )}
                          </td>

                          {/* Total Valuation */}
                          <td className="px-5 py-4 text-xs font-semibold text-ink-muted">
                            {formatDZD(p.price * p.stock)}
                          </td>

                          {/* Quick refill options */}
                          <td className="px-5 py-4 text-left">
                            <div className="flex items-center gap-1 justify-end">
                              <button
                                onClick={() => handleBulkAdd(p.id, p, 10)}
                                className="px-2 py-1 rounded-lg bg-cherry-50 hover:bg-cherry-100 text-cherry-600 text-[10px] font-bold ring-1 ring-cherry-100 transition-all cursor-pointer"
                                title={tr("إضافة 10 قطع")}
                              >
                                +10
                              </button>
                              <button
                                onClick={() => handleBulkAdd(p.id, p, 50)}
                                className="px-2 py-1 rounded-lg bg-cherry-600 hover:bg-cherry-700 text-white text-[10px] font-bold transition-all cursor-pointer"
                                title={tr("إضافة 50 قطعة")}
                              >
                                +50
                              </button>
                            </div>
                          </td>
                        </tr>
                      );
                    })}

                    {filtered.length === 0 && (
                      <tr>
                        <td colSpan={8} className="px-5 py-16 text-center">
                          <div className="mx-auto size-12 rounded-2xl bg-cherry-100 grid place-items-center text-cherry-600 mb-3">
                            <Boxes className="size-5" />
                          </div>
                          <div className="text-sm font-semibold">{tr("لا توجد منتجات مطابقة في المخازن")}</div>
                          <div className="text-xs text-ink-muted mt-1">
                            {tr("جرّبي تعديل فلاتر التصفية أو البحث عن منتج آخر.")}
                          </div>
                        </td>
                      </tr>
                    )}
                  </tbody>
                </table>
              </div>
            </section>
          </>
        )}
      </div>
    </AppShell>
  );
}

// Subcomponents

function Th({ children, className }: { children: React.ReactNode; className?: string }) {
  return (
    <th className={cn("px-5 py-3 text-right font-semibold text-ink-muted", className)}>{children}</th>
  );
}

interface KpiTileProps {
  label: string;
  value: string;
  hint: string;
  icon: React.ElementType;
  tone: "cherry" | "sky" | "violet" | "emerald" | "amber";
  alert?: boolean;
}

const TONES = {
  cherry: { bg: "bg-cherry-100", text: "text-cherry-600", ring: "ring-cherry-200" },
  sky: { bg: "bg-sky-100", text: "text-sky-600", ring: "ring-sky-200" },
  violet: { bg: "bg-violet-100", text: "text-violet-600", ring: "ring-violet-200" },
  emerald: { bg: "bg-emerald-100", text: "text-emerald-600", ring: "ring-emerald-200" },
  amber: { bg: "bg-amber-100", text: "text-amber-600", ring: "ring-amber-200" },
} as const;

function KpiTile({
  label,
  value,
  hint,
  icon: Icon,
  tone,
  alert,
}: KpiTileProps) {
  const t = TONES[tone];
  return (
    <div
      className={cn(
        "text-start rounded-2xl bg-white p-5 ring-1 transition-all",
        alert
          ? "ring-rose-200 shadow-md shadow-rose-50"
          : "ring-border/70 shadow-sm shadow-cherry-100/10"
      )}
    >
      <div className="flex items-center justify-between mb-3">
        <span
          className={cn(
            "size-9 rounded-xl grid place-items-center shrink-0",
            alert ? "bg-rose-100 text-rose-600 ring-rose-200" : t.bg,
            alert ? "" : t.text,
          )}
        >
          <Icon className="size-4" />
        </span>
      </div>
      <div className="font-display font-extrabold text-2xl tracking-tight text-ink">
        {value}
      </div>
      <div className="mt-3 text-[11px] font-semibold text-ink-muted">{label}</div>
      <div className={cn("text-[10px] mt-1", alert ? "text-rose-600 font-medium" : "text-ink-muted")}>
        {hint}
      </div>
    </div>
  );
}
