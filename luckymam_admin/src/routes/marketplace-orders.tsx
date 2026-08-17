import { createFileRoute } from "@tanstack/react-router";
import { useMemo, useState, useEffect } from "react";
import {
  Search,
  Clock,
  Truck,
  PackageCheck,
  Layers,
  ShoppingBag,
  Download,
  Phone,
  MapPin,
  Wallet,
  CreditCard,
  Banknote,
  Receipt,
  TrendingUp,
  ArrowUpRight,
  Printer,
  XCircle,
  PackageOpen,
  AlertTriangle,
} from "lucide-react";

import { AppShell } from "@/components/admin/AppShell";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import {
  Sheet,
  SheetContent,
  SheetDescription,
  SheetHeader,
  SheetTitle,
} from "@/components/ui/sheet";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { cn } from "@/lib/utils";
import {
  PAYMENT_META,
  type MarketplaceOrder,
  type PaymentMethod,
  type PaymentStatus,
  type MarketplaceOrderStatus,
} from "@/data/marketplace-orders.mock";
import { CATEGORY_ICONS } from "./marketplace-catalog";
import { useI18n } from "@/i18n";
import { useAdminProfile } from "@/hooks/useAdminProfile";
import "@/i18n/pages/marketplace-orders";

// Firebase imports
import { 
  collection, 
  onSnapshot, 
  query, 
  doc, 
  updateDoc,
  runTransaction,
  where, 
  getDocs 
} from "firebase/firestore";
import { db } from "@/lib/firebase";

export const Route = createFileRoute("/marketplace-orders")({
  head: () => ({
    meta: [
      { title: "طلبات المتجر — Luckymam Admin" },
      {
        name: "description",
        content:
          "متابعة وإدارة طلبات المتجر من الاستلام حتى التسليم مع تفاصيل الدفع والمنتجات.",
      },
    ],
  }),
  component: MarketplaceOrdersPage,
});

type Filter = "all" | MarketplaceOrderStatus;

// Custom metadata for marketplace statuses
export const MARKETPLACE_STATUS_META: Record<
  MarketplaceOrderStatus,
  { label: string; dot: string; chip: string; ring: string; tone: "cherry" | "amber" | "sky" | "violet" | "emerald" }
> = {
  pending: {
    label: "معلق",
    dot: "bg-amber-500",
    chip: "bg-amber-50 text-amber-700 ring-amber-200",
    ring: "ring-amber-200",
    tone: "amber",
  },
  confirmed: {
    label: "قيد التحضير",
    dot: "bg-sky-500",
    chip: "bg-sky-50 text-sky-700 ring-sky-200",
    ring: "ring-sky-200",
    tone: "sky",
  },
  shipped: {
    label: "مشحون",
    dot: "bg-violet-500",
    chip: "bg-violet-50 text-violet-700 ring-violet-200",
    ring: "ring-violet-200",
    tone: "violet",
  },
  delivered: {
    label: "تم التسليم",
    dot: "bg-emerald-500",
    chip: "bg-emerald-50 text-emerald-700 ring-emerald-200",
    ring: "ring-emerald-200",
    tone: "emerald",
  },
  cancelled: {
    label: "ملغي",
    dot: "bg-rose-500",
    chip: "bg-rose-50 text-rose-700 ring-rose-200",
    ring: "ring-rose-200",
    tone: "cherry",
  },
};

const FILTERS: { key: Filter; label: string; icon: React.ElementType }[] = [
  { key: "all", label: "الكل", icon: Layers },
  { key: "pending", label: "معلق", icon: Clock },
  { key: "confirmed", label: "قيد التحضير", icon: Printer },
  { key: "shipped", label: "مشحون", icon: Truck },
  { key: "delivered", label: "تم التسليم", icon: PackageCheck },
  { key: "cancelled", label: "ملغي", icon: XCircle },
];

const PAY_STATUS_LABEL: Record<PaymentStatus, string> = {
  paid: "مدفوع",
  pending: "بانتظار الدفع",
  refunded: "مسترجع/ملغي",
};

const PAY_ICON: Record<PaymentMethod, React.ElementType> = {
  cod: Banknote,
  card: CreditCard,
  ccp: Receipt,
};

const PAY_STATUS_CHIP: Record<PaymentStatus, string> = {
  paid: "bg-emerald-50 text-emerald-700 ring-emerald-200",
  pending: "bg-amber-50 text-amber-700 ring-amber-200",
  refunded: "bg-rose-50 text-rose-700 ring-rose-200",
};

function MarketplaceStatusBadge({ status, className }: { status: MarketplaceOrderStatus; className?: string }) {
  const { tr } = useI18n();
  const meta = MARKETPLACE_STATUS_META[status];
  return (
    <span
      className={cn(
        "inline-flex items-center gap-1.5 rounded-full px-2.5 py-1 text-[11px] font-semibold ring-1",
        meta.chip,
        className,
      )}
    >
      <span className={cn("size-1.5 rounded-full", meta.dot)} />
      {tr(meta.label)}
    </span>
  );
}

function MarketplaceStatusSelect({
  value,
  onChange,
  disabled,
}: {
  value: MarketplaceOrderStatus;
  onChange: (val: MarketplaceOrderStatus) => void;
  disabled?: boolean;
}) {
  const { tr } = useI18n();
  return (
    <Select value={value} onValueChange={onChange} disabled={disabled}>
      <SelectTrigger className="w-[130px] h-8 rounded-full border-border/70 text-[11px] font-semibold bg-white">
        <SelectValue />
      </SelectTrigger>
      <SelectContent className="text-start">
        {(["pending", "confirmed", "shipped", "delivered", "cancelled"] as MarketplaceOrderStatus[]).map((s) => (
          <SelectItem key={s} value={s} className="text-start flex cursor-pointer">
            {tr(MARKETPLACE_STATUS_META[s].label)}
          </SelectItem>
        ))}
      </SelectContent>
    </Select>
  );
}

function MarketplaceOrdersPage() {
  const { tr, dir } = useI18n();
  const { displayName } = useAdminProfile();

  const formatDZD = (n: number) => {
    return new Intl.NumberFormat("fr-DZ").format(n) + " " + tr("د.ج");
  };

  // Firestore orders state
  const [orders, setOrders] = useState<MarketplaceOrder[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const [filter, setFilter] = useState<Filter>("all");
  const [payFilter, setPayFilter] = useState<"all" | PaymentMethod>("all");
  const [queryStr, setQueryStr] = useState("");
  const [selectedId, setSelectedId] = useState<string | null>(null);
  const [open, setOpen] = useState(false);
  const [updatingOrderIds, setUpdatingOrderIds] = useState<Set<string>>(
    () => new Set(),
  );

  // Listen to Firestore marketplace_orders
  useEffect(() => {
    const q = query(collection(db, "marketplace_orders"));
    const unsubscribe = onSnapshot(
      q,
      (snapshot) => {
        const orderList = snapshot.docs.map((d) => {
          const data = d.data();
          const itemsRaw = data.items || [];
          const customerRaw = data.customer || {};

          return {
            id: d.id,
            userId: data.userId || "",
            customer: {
              name: customerRaw.name || tr("زبونة غير معروفة"),
              initials: customerRaw.initials || "أم",
              phone: customerRaw.phone || "",
              wilaya: customerRaw.wilaya || "",
              address: customerRaw.address || "",
            },
            items: itemsRaw.map((it: any) => ({
              sku: it.sku || "",
              title: it.title || "",
              variant: it.variant || "",
              qty: Number(it.qty || 1),
              unitPrice: Number(it.unitPrice || 0),
              image: it.image || "📦",
              imageUrl: it.imageUrl || "",
              vendor: it.vendor || "",
            })),
            subtotal: Number(data.subtotal || 0),
            shipping: Number(data.shipping || 0),
            total: Number(data.total || 0),
            payment: {
              method: (data.payment?.method || "cod") as PaymentMethod,
              status: (data.payment?.status || "pending") as PaymentStatus,
            },
            createdAt: data.createdAt || new Date().toISOString().split("T")[0],
            status: (data.status || "pending") as MarketplaceOrderStatus,
            statusUpdatedAt: data.statusUpdatedAt || "",
            statusUpdatedBy: data.statusUpdatedBy || "",
            history: data.history || [],
          } as MarketplaceOrder;
        });

        setOrders(orderList);
        setLoading(false);
        setError(null);
      },
      (err) => {
        console.error("Firestore marketplace orders error:", err);
        setError(err.message);
        setLoading(false);
      }
    );
    return unsubscribe;
  }, [tr]);

  // Update order status with dynamic payment rules and automatic restocking
  const updateStatus = async (id: string, next: MarketplaceOrderStatus) => {
    const targetOrder = orders.find((o) => o.id === id);
    if (!targetOrder || updatingOrderIds.has(id)) return;

    let nextPaymentStatus = targetOrder.payment.status;
    if (next === "delivered") {
      nextPaymentStatus = "paid";
    } else if (next === "cancelled") {
      nextPaymentStatus = "refunded";
    }

    const orderRef = doc(db, "marketplace_orders", id);
    const statusPayload = {
      status: next,
      statusUpdatedAt: new Date().toISOString().replace("T", " ").substring(0, 16),
      statusUpdatedBy: displayName,
      payment: {
        method: targetOrder.payment.method,
        status: nextPaymentStatus,
      },
    };

    setUpdatingOrderIds((prev) => new Set(prev).add(id));

    try {
      const shouldRestock =
        next === "cancelled" && targetOrder.status !== "cancelled";

      if (shouldRestock) {
        const restockPlans: Array<{
          ref: ReturnType<typeof doc>;
          qty: number;
        }> = [];

        for (const item of targetOrder.items) {
          if (!item.sku) continue;
          const productQuery = query(
            collection(db, "marketplace_products"),
            where("sku", "==", item.sku),
          );
          const prodSnap = await getDocs(productQuery);
          if (!prodSnap.empty) {
            restockPlans.push({
              ref: prodSnap.docs[0].ref,
              qty: Number(item.qty || 0),
            });
          }
        }

        await runTransaction(db, async (transaction) => {
          const orderSnap = await transaction.get(orderRef);
          if (!orderSnap.exists()) {
            throw new Error("الطلب غير موجود");
          }
          const currentStatus = orderSnap.data()?.status as string | undefined;
          if (currentStatus === "cancelled") {
            return;
          }

          for (const plan of restockPlans) {
            const productSnap = await transaction.get(plan.ref);
            if (!productSnap.exists()) continue;
            const data = productSnap.data();
            const currentStock = Number(data?.stock || 0);
            const newStock = currentStock + plan.qty;
            const prevStatus = data?.status as string | undefined;
            transaction.update(plan.ref, {
              stock: newStock,
              status:
                newStock > 0 && prevStatus === "out_of_stock"
                  ? "active"
                  : prevStatus,
            });
          }

          transaction.update(orderRef, statusPayload);
        });
      } else {
        await updateDoc(orderRef, statusPayload);
      }
    } catch (err: unknown) {
      console.error("Firestore status transition error:", err);
      const message = err instanceof Error ? err.message : String(err);
      alert(`خطأ أثناء تغيير الحالة: ${message}`);
    } finally {
      setUpdatingOrderIds((prev) => {
        const nextSet = new Set(prev);
        nextSet.delete(id);
        return nextSet;
      });
    }
  };

  const counts = useMemo(() => {
    const base: Record<Filter, number> = {
      all: orders.length,
      pending: 0,
      confirmed: 0,
      shipped: 0,
      delivered: 0,
      cancelled: 0,
    };
    for (const o of orders) {
      if (base[o.status] !== undefined) {
        base[o.status]++;
      }
    }
    return base;
  }, [orders]);

  const revenue = useMemo(() => {
    const paid = orders.filter((o) => o.payment.status === "paid");
    const sum = paid.reduce((acc, o) => acc + o.total, 0);
    const avg = paid.length ? Math.round(sum / paid.length) : 0;
    const units = orders.reduce(
      (acc, o) => acc + o.items.reduce((s, i) => s + i.qty, 0),
      0,
    );
    return { sum, avg, units, paidCount: paid.length };
  }, [orders]);

  const filtered = useMemo(() => {
    return orders.filter((o) => {
      if (filter !== "all" && o.status !== filter) return false;
      if (payFilter !== "all" && o.payment.method !== payFilter) return false;
      if (queryStr) {
        const q = queryStr.toLowerCase().trim();
        if (
          !o.id.toLowerCase().includes(q) &&
          !o.customer.name.toLowerCase().includes(q) &&
          !o.items.some((i) => i.title.toLowerCase().includes(q))
        )
          return false;
      }
      return true;
    });
  }, [orders, filter, payFilter, queryStr]);

  const selected = orders.find((o) => o.id === selectedId) ?? null;

  // Reconstruct history trail dynamically (compliant with write rules)
  const displayHistory = useMemo(() => {
    if (!selected) return [];
    const list = [
      {
        status: "pending" as MarketplaceOrderStatus,
        at: selected.createdAt,
        by: tr("النظام"),
      },
    ];

    if (selected.statusUpdatedAt && selected.status !== "pending") {
      list.push({
        status: selected.status,
        at: selected.statusUpdatedAt,
        by: selected.statusUpdatedBy || tr("الأدمن"),
      });
    }
    return list;
  }, [selected, tr]);

  return (
    <AppShell>
      <div className="p-6 lg:p-10 space-y-8 max-w-[1600px] text-start" dir={dir}>
        {/* Header */}
        <header className="flex flex-wrap items-end justify-between gap-4">
          <div>
            <div className="text-xs font-bold uppercase tracking-[0.2em] text-cherry-600 mb-2 inline-flex items-center gap-2">
              <ShoppingBag className="size-3.5" /> {tr("متجر Luckymam")}
            </div>
            <h1 className="font-display font-extrabold text-3xl md:text-4xl tracking-tight">
              {tr("طلبات المتجر")}
            </h1>
            <p className="text-sm text-ink-muted mt-2 max-w-[56ch]">
              {tr("متابعة كل طلبات المنتجات من الأمهات، مع تفاصيل السلة، الشحن، الدفع، وسير التسليم.")}
            </p>
          </div>
        </header>

        {loading ? (
          <div className="text-center py-10 text-sm text-ink-muted">{tr("جاري تحميل البيانات...")}</div>
        ) : error ? (
          <div className="text-center py-6 text-sm text-rose-500 border border-rose-100 rounded-2xl bg-rose-50/50">{error}</div>
        ) : (
          <>
            {/* Revenue metrics */}
            <section className="grid grid-cols-1 md:grid-cols-4 gap-3">
              <RevenueCard
                label={tr("إجمالي المبيعات")}
                value={formatDZD(revenue.sum)}
                hint={`${revenue.paidCount} ${tr("طلب مدفوع")}`}
                icon={TrendingUp}
                hero
              />
              <RevenueCard
                label={tr("متوسط الطلب")}
                value={formatDZD(revenue.avg)}
                hint={tr("لكل طلب مدفوع")}
                icon={Wallet}
              />
              <RevenueCard
                label={tr("القطع المباعة")}
                value={String(revenue.units)}
                hint={tr("عبر كل الطلبات")}
                icon={ShoppingBag}
              />
              <RevenueCard
                label={tr("طلبات نشطة")}
                value={String(counts.pending + counts.confirmed)}
                hint={tr("بانتظار المعالجة أو التحضير")}
                icon={Clock}
              />
            </section>

            {/* Status filters */}
            <section className="grid grid-cols-2 md:grid-cols-6 gap-3">
              <StatTile
                active={filter === "all"}
                onClick={() => setFilter("all")}
                label={tr("إجمالي الطلبات")}
                value={counts.all}
                icon={Layers}
                tone="cherry"
              />
              <StatTile
                active={filter === "pending"}
                onClick={() => setFilter("pending")}
                label={tr("معلق")}
                value={counts.pending}
                icon={Clock}
                tone="amber"
              />
              <StatTile
                active={filter === "confirmed"}
                onClick={() => setFilter("confirmed")}
                label={tr("قيد التحضير")}
                value={counts.confirmed}
                icon={Printer}
                tone="sky"
              />
              <StatTile
                active={filter === "shipped"}
                onClick={() => setFilter("shipped")}
                label={tr("مشحون")}
                value={counts.shipped}
                icon={Truck}
                tone="violet"
              />
              <StatTile
                active={filter === "delivered"}
                onClick={() => setFilter("delivered")}
                label={tr("تم التسليم")}
                value={counts.delivered}
                icon={PackageCheck}
                tone="emerald"
              />
              <StatTile
                active={filter === "cancelled"}
                onClick={() => setFilter("cancelled")}
                label={tr("ملغي")}
                value={counts.cancelled}
                icon={XCircle}
                tone="cherry"
              />
            </section>

            {/* Toolbar */}
            <section className="flex flex-wrap items-center justify-between gap-3">
              <div className="flex flex-wrap items-center gap-2">
                {FILTERS.map((f) => {
                  const active = filter === f.key;
                  const Icon = f.icon;
                  return (
                    <button
                      key={f.key}
                      onClick={() => setFilter(f.key)}
                      className={cn(
                        "inline-flex items-center gap-1.5 rounded-full px-3.5 py-1.5 text-xs font-semibold transition-colors ring-1 cursor-pointer",
                        active
                          ? "bg-cherry-600 text-white ring-cherry-600 shadow-sm shadow-cherry-600/30"
                          : "bg-white text-ink-muted ring-border hover:text-cherry-600",
                      )}
                    >
                      <Icon className="size-3.5" />
                      {tr(f.label)}
                      <span
                        className={cn(
                          "rounded-full px-1.5 py-0 text-[10px] font-bold",
                          active ? "bg-white/20" : "bg-cherry-100 text-cherry-600",
                        )}
                      >
                        {counts[f.key]}
                      </span>
                    </button>
                  );
                })}
              </div>
              <div className="flex items-center gap-2">
                <div className="inline-flex items-center rounded-full bg-white ring-1 ring-border p-1 text-[11px] font-semibold">
                  <Wallet className="size-3.5 text-cherry-600 mx-2" />
                  <button
                    onClick={() => setPayFilter("all")}
                    className={cn(
                      "px-3 py-1 rounded-full transition-colors cursor-pointer",
                      payFilter === "all"
                        ? "bg-cherry-600 text-white"
                        : "text-ink-muted",
                    )}
                  >
                    {tr("كل الدفع")}
                  </button>
                  {(Object.keys(PAYMENT_META) as PaymentMethod[]).map((m) => (
                    <button
                      key={m}
                      onClick={() => setPayFilter(m)}
                      className={cn(
                        "px-3 py-1 rounded-full transition-colors cursor-pointer",
                        payFilter === m
                          ? "bg-cherry-600 text-white"
                          : "text-ink-muted",
                      )}
                    >
                      {tr(PAYMENT_META[m].label)}
                    </button>
                  ))}
                </div>
                <div className="relative">
                  <Search className="size-4 text-ink-muted absolute right-3 top-1/2 -translate-y-1/2" />
                  <Input
                    value={queryStr}
                    onChange={(e) => setQueryStr(e.target.value)}
                    placeholder={tr("بحث بالطلب، الاسم، أو المنتج…")}
                    className="w-72 rounded-full pr-9 bg-white border-border/70 focus-visible:ring-cherry-200"
                  />
                </div>
              </div>
            </section>

            <div className="flex items-center justify-between text-xs text-ink-muted -mt-4">
              <span>
                <span className="font-bold text-ink">{filtered.length}</span> {tr("طلب")} {tr("مطابق")}
              </span>
            </div>

            {/* Orders Table */}
            <section className="rounded-3xl bg-white ring-1 ring-border/70 overflow-hidden shadow-sm shadow-cherry-100/40">
              <div className="overflow-x-auto">
                <table className="w-full text-sm">
                  <thead>
                    <tr className="text-[11px] uppercase tracking-wider text-ink-muted bg-cherry-50/50">
                      <Th>{tr("الطلب")}</Th>
                      <Th>{tr("الزبونة")}</Th>
                      <Th>{tr("المنتجات")}</Th>
                      <Th>{tr("الإجمالي")}</Th>
                      <Th>{tr("الدفع")}</Th>
                      <Th>{tr("الولاية")}</Th>
                      <Th>{tr("التاريخ")}</Th>
                      <Th>{tr("الحالة")}</Th>
                      <Th className="text-start">{tr("تحديث")}</Th>
                    </tr>
                  </thead>
                  <tbody>
                    {filtered.map((o) => {
                      const PayIcon = PAY_ICON[o.payment.method];
                      const preview = o.items.slice(0, 3);
                      const more = o.items.length - preview.length;
                      return (
                        <tr
                          key={o.id}
                          onClick={() => {
                            setSelectedId(o.id);
                            setOpen(true);
                          }}
                          className="border-t border-border/60 hover:bg-cherry-50/40 cursor-pointer transition-colors"
                        >
                          <td className="px-5 py-4">
                            <div className="font-display font-bold text-cherry-600 text-sm">
                              {o.id.substring(0, 8).toUpperCase()}
                            </div>
                          </td>
                          <td className="px-5 py-4">
                            <div className="flex items-center gap-2.5">
                              <div className="size-8 rounded-xl bg-cherry-100 text-cherry-600 grid place-items-center text-[11px] font-bold">
                                {o.customer.initials}
                              </div>
                              <div>
                                <div className="font-semibold text-[13px]">
                                  {o.customer.name}
                                </div>
                                <div className="text-[11px] text-ink-muted">
                                  {o.customer.phone}
                                </div>
                              </div>
                            </div>
                          </td>
                          <td className="px-5 py-4">
                            <div className="flex items-center gap-1.5">
                              {preview.map((it) => (
                                <div
                                  key={it.sku}
                                  title={it.title}
                                  className="size-8 rounded-xl bg-cherry-50 ring-1 ring-cherry-100 grid place-items-center text-base"
                                >
                                  {it.imageUrl ? (
                                    <img src={it.imageUrl} alt={it.title} className="w-full h-full object-cover rounded-xl" />
                                  ) : (
                                    <span>{it.image || "📦"}</span>
                                  )}
                                </div>
                              ))}
                              {more > 0 && (
                                <div className="size-8 rounded-xl bg-white ring-1 ring-border grid place-items-center text-[10px] font-bold text-ink-muted">
                                  +{more}
                                </div>
                              )}
                            </div>
                            <div className="text-[11px] text-ink-muted mt-1">
                              {o.items.reduce((s, i) => s + i.qty, 0)} {tr("قطعة")}
                            </div>
                          </td>
                          <td className="px-5 py-4">
                            <div className="font-display font-bold text-sm">
                              {formatDZD(o.total)}
                            </div>
                            <div className="text-[10px] text-ink-muted">
                              {tr("شحن")} {formatDZD(o.shipping)}
                            </div>
                          </td>
                          <td className="px-5 py-4">
                            <div className="flex flex-col gap-1">
                              <span className="inline-flex items-center gap-1.5 text-[11px] font-medium text-ink">
                                <PayIcon className="size-3.5 text-cherry-600" />
                                {tr(PAYMENT_META[o.payment.method].label)}
                              </span>
                              <span
                                className={cn(
                                  "inline-flex items-center gap-1 rounded-full px-2 py-0.5 text-[10px] font-semibold ring-1 w-fit",
                                  PAY_STATUS_CHIP[o.payment.status],
                                )}
                              >
                                {tr(PAY_STATUS_LABEL[o.payment.status])}
                              </span>
                            </div>
                          </td>
                          <td className="px-5 py-4 text-xs text-ink-muted">
                            {o.customer.wilaya}
                          </td>
                          <td className="px-5 py-4 text-xs text-ink-muted whitespace-nowrap">
                            {o.createdAt}
                          </td>
                          <td className="px-5 py-4">
                            <MarketplaceStatusBadge status={o.status} />
                          </td>
                          <td
                            className="px-5 py-4"
                            onClick={(e) => e.stopPropagation()}
                          >
                            <MarketplaceStatusSelect
                              value={o.status}
                              onChange={(s) => updateStatus(o.id, s)}
                              disabled={updatingOrderIds.has(o.id)}
                            />
                          </td>
                        </tr>
                      );
                    })}
                    {filtered.length === 0 && (
                      <tr>
                        <td colSpan={9} className="px-5 py-16 text-center">
                          <div className="mx-auto size-12 rounded-2xl bg-cherry-100 grid place-items-center text-cherry-600 mb-3">
                            <ShoppingBag className="size-5" />
                          </div>
                          <div className="text-sm font-semibold">
                            {tr("لا توجد طلبات مطابقة")}
                          </div>
                          <div className="text-xs text-ink-muted mt-1">
                            {tr("جرّبي تعديل الفلاتر أو مصطلح البحث.")}
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

      {/* Dynamic Details Sidebar Sheet */}
      <Sheet open={open} onOpenChange={setOpen}>
        <SheetContent
          side="left"
          className="w-full sm:max-w-[600px] overflow-y-auto bg-cherry-50/60 p-0 text-start font-sans"
          dir={dir}
        >
          {selected && (
            <>
              <div className="p-6 border-b border-border bg-white">
                <SheetHeader className="p-0 text-start space-y-2">
                  <div className="flex items-center gap-2 text-[10px] font-bold tracking-[0.2em] uppercase text-cherry-600">
                    <ShoppingBag className="size-3" /> 
                    <span>{tr("طلب متجر")}</span>
                  </div>
                  <SheetTitle className="font-display text-2xl tracking-tight text-ink">
                    {selected.id.toUpperCase()}
                  </SheetTitle>
                  <SheetDescription className="flex items-center gap-2 text-xs">
                    <MarketplaceStatusBadge status={selected.status} />
                    <span
                      className={cn(
                        "inline-flex items-center gap-1 rounded-full px-2 py-0.5 text-[10px] font-semibold ring-1",
                        PAY_STATUS_CHIP[selected.payment.status],
                      )}
                    >
                      {tr(PAY_STATUS_LABEL[selected.payment.status])}
                    </span>
                  </SheetDescription>
                </SheetHeader>
              </div>

              <div className="p-6 space-y-6">
                {/* Client info */}
                <section className="rounded-2xl bg-white p-5 ring-1 ring-border/70">
                  <div className="flex items-center gap-3 mb-4">
                    <div className="size-11 rounded-2xl bg-cherry-100 text-cherry-600 grid place-items-center font-bold">
                      {selected.customer.initials}
                    </div>
                    <div className="flex-1">
                      <div className="font-semibold text-sm text-ink">
                        {selected.customer.name}
                      </div>
                      <div className="text-[11px] text-ink-muted">
                        {tr("الزبونة")}
                      </div>
                    </div>
                  </div>
                  <dl className="grid grid-cols-1 gap-2.5 text-xs">
                    <Row icon={Phone} label={tr("الهاتف")} value={selected.customer.phone} />
                    <Row icon={MapPin} label={tr("الولاية")} value={selected.customer.wilaya} />
                    <Row icon={MapPin} label={tr("العنوان")} value={selected.customer.address} />
                  </dl>
                </section>

                {/* Items in cart */}
                <section className="rounded-2xl bg-white p-5 ring-1 ring-border/70">
                  <div className="flex items-center justify-between mb-4">
                    <div className="flex items-center gap-2">
                      <ShoppingBag className="size-4 text-cherry-600" />
                      <h3 className="font-semibold text-sm text-ink">{tr("محتوى السلة")}</h3>
                    </div>
                    <span className="text-[10px] text-ink-muted">
                      {selected.items.length} {tr("منتج")}
                    </span>
                  </div>
                  <ul className="divide-y divide-border/60">
                    {selected.items.map((it) => (
                      <li key={it.sku} className="py-3 flex items-center gap-3">
                        <img
                          src={it.imageUrl || "/placeholder.jpg"}
                          alt={it.title}
                          className="size-12 rounded-xl object-cover ring-1 ring-border/80 bg-muted shrink-0"
                        />
                        <div className="flex-1 min-w-0 px-1">
                          <div className="text-[13px] font-semibold truncate text-ink">
                            {it.title}
                          </div>
                          <div className="text-[11px] text-ink-muted truncate">
                            {it.variant ? `${it.variant} · ` : ""}
                            {it.vendor}
                          </div>
                        </div>
                        <div className="text-left shrink-0 pl-1">
                          <div className="text-[12px] font-semibold text-ink">
                            {formatDZD(it.unitPrice * it.qty)}
                          </div>
                          <div className="text-[10px] text-ink-muted">
                            {it.qty} × {formatDZD(it.unitPrice)}
                          </div>
                        </div>
                      </li>
                    ))}
                  </ul>

                  <div className="mt-4 border-t border-border/60 pt-4 space-y-1.5 text-xs">
                    <div className="flex justify-between flex-row-reverse">
                      <span className="text-ink-muted">{tr("المجموع الفرعي")}</span>
                      <span className="font-medium text-ink">
                        {formatDZD(selected.subtotal)}
                      </span>
                    </div>
                    <div className="flex justify-between flex-row-reverse">
                      <span className="text-ink-muted">{tr("الشحن")}</span>
                      <span className="font-medium text-ink">
                        {formatDZD(selected.shipping)}
                      </span>
                    </div>
                    <div className="flex justify-between items-baseline pt-2 border-t border-dashed border-border/70 flex-row-reverse">
                      <span className="font-semibold text-ink">{tr("الإجمالي")}</span>
                      <span className="font-display font-extrabold text-lg text-cherry-600">
                        {formatDZD(selected.total)}
                      </span>
                    </div>
                  </div>
                </section>

                {/* Payment detail */}
                <section className="rounded-2xl bg-white p-5 ring-1 ring-border/70">
                  <div className="flex items-center gap-2 mb-3 flex-row-reverse justify-end">
                    <Wallet className="size-4 text-cherry-600" />
                    <h3 className="font-semibold text-sm text-ink">{tr("تفاصيل الدفع")}</h3>
                  </div>
                  <div className="space-y-2 text-xs">
                    <div className="flex justify-between flex-row-reverse">
                      <span className="text-ink-muted">{tr("طريقة الدفع")}</span>
                      <span className="font-medium text-ink">
                        {tr(PAYMENT_META[selected.payment.method].label)}
                      </span>
                    </div>
                    <div className="flex justify-between flex-row-reverse">
                      <span className="text-ink-muted">{tr("حالة الدفع")}</span>
                      <span
                        className={cn(
                          "inline-flex items-center rounded-full px-2 py-0.5 text-[10px] font-semibold ring-1",
                          PAY_STATUS_CHIP[selected.payment.status],
                        )}
                      >
                        {tr(PAY_STATUS_LABEL[selected.payment.status])}
                      </span>
                    </div>
                  </div>
                </section>

                {/* Status updates */}
                <section>
                  <h3 className="font-semibold text-sm mb-3 text-ink">{tr("تحديث الحالة")}</h3>
                  <div className="grid grid-cols-5 gap-2">
                    {(Object.keys(MARKETPLACE_STATUS_META) as MarketplaceOrderStatus[]).map((s, i) => {
                      const currentIdx = Object.keys(MARKETPLACE_STATUS_META).indexOf(selected.status);
                      const isCurrent = selected.status === s;
                      const done = i <= currentIdx;
                      return (
                        <button
                          key={s}
                          onClick={() => updateStatus(selected.id, s)}
                          className={cn(
                            "rounded-xl p-2 text-[10px] font-bold ring-1 transition-all text-center cursor-pointer",
                            isCurrent
                              ? "bg-cherry-600 text-white ring-cherry-600 shadow-sm shadow-cherry-600/30"
                              : done
                              ? "bg-cherry-50 text-cherry-600 ring-cherry-200"
                              : "bg-white text-ink-muted ring-border hover:ring-cherry-200 hover:text-cherry-600",
                          )}
                        >
                          {tr(MARKETPLACE_STATUS_META[s].label)}
                        </button>
                      );
                    })}
                  </div>
                </section>

                {/* Dynamic log path */}
                <section className="rounded-2xl bg-white p-5 ring-1 ring-border/70">
                  <h3 className="font-semibold text-sm mb-4 text-ink">{tr("سجل الحالة")}</h3>
                  <ol className="relative ltr:pl-4 ltr:border-l-2 rtl:pr-4 rtl:border-r-2 border-cherry-100 space-y-4 text-start">
                    {displayHistory.map((h, i) => (
                      <li key={i} className="relative">
                        <span className="absolute ltr:-left-[22px] rtl:-right-[22px] top-1 size-3 rounded-full bg-cherry-600 ring-4 ring-cherry-100" />
                        <div className="text-[12px] font-semibold">
                          <MarketplaceStatusBadge status={h.status} className="text-[10px]" />
                        </div>
                        <div className="text-[11px] text-ink-muted mt-1 font-mono">
                          {h.at} — {h.by}
                        </div>
                      </li>
                    ))}
                  </ol>
                </section>
              </div>
            </>
          )}
        </SheetContent>
      </Sheet>
    </AppShell>
  );
}

// Subcomponents

interface ThProps {
  children: React.ReactNode;
  className?: string;
}

function Th({ children, className }: ThProps) {
  return (
    <th className={cn("px-5 py-3 text-start font-semibold text-ink-muted", className)}>{children}</th>
  );
}

interface RowProps {
  icon: React.ElementType;
  label: string;
  value: string;
}

function Row({
  icon: Icon,
  label,
  value,
}: RowProps) {
  return (
    <div className="flex items-start gap-2.5 text-start">
      <Icon className="size-3.5 text-cherry-600 mt-0.5 shrink-0" />
      <div className="flex-1 px-1">
        <div className="text-[10px] uppercase tracking-wider text-ink-muted">
          {label}
        </div>
        <div className="text-[12px] font-semibold text-ink">{value}</div>
      </div>
    </div>
  );
}

const TONE: Record<string, { chip: string; text: string; ring: string }> = {
  cherry: { chip: "bg-cherry-100", text: "text-cherry-600", ring: "ring-cherry-200" },
  amber: { chip: "bg-amber-100", text: "text-amber-600", ring: "ring-amber-200" },
  sky: { chip: "bg-sky-100", text: "text-sky-600", ring: "ring-sky-200" },
  violet: { chip: "bg-violet-100", text: "text-violet-600", ring: "ring-violet-200" },
  emerald: { chip: "bg-emerald-100", text: "text-emerald-600", ring: "ring-emerald-200" },
};

interface StatTileProps {
  active: boolean;
  onClick: () => void;
  label: string;
  value: number;
  icon: React.ElementType;
  tone: keyof typeof TONE;
}

function StatTile({
  active,
  onClick,
  label,
  value,
  icon: Icon,
  tone,
}: StatTileProps) {
  const { tr } = useI18n();
  const t = TONE[tone] || TONE.cherry;
  return (
    <button
      onClick={onClick}
      className={cn(
        "text-start rounded-2xl bg-white p-4 ring-1 transition-all hover:-translate-y-0.5 cursor-pointer",
        active
          ? `${t.ring} shadow-sm shadow-cherry-100`
          : "ring-border/70 hover:ring-cherry-200",
      )}
    >
      <div className="flex items-center justify-between mb-3">
        <span
          className={cn(
            "size-9 rounded-xl grid place-items-center",
            t.chip,
            t.text,
          )}
        >
          <Icon className="size-4" />
        </span>
        {active && (
          <span className="text-[10px] font-bold text-cherry-600 uppercase tracking-wider">
            {tr("مُفعّل")}
          </span>
        )}
      </div>
      <div className="font-display font-extrabold text-2xl tracking-tight text-ink">
        {value}
      </div>
      <div className="mt-3 text-[11px] font-semibold text-ink-muted">{label}</div>
    </button>
  );
}

interface RevenueCardProps {
  label: string;
  value: string;
  hint: string;
  icon: React.ElementType;
  hero?: boolean;
}

function RevenueCard({
  label,
  value,
  hint,
  icon: Icon,
  hero,
}: RevenueCardProps) {
  const { dir } = useI18n();
  return (
    <div
      className={cn(
        "rounded-2xl p-5 ring-1 relative overflow-hidden text-start",
        hero
          ? "bg-gradient-to-bl from-cherry-600 to-cherry-500 text-white ring-cherry-600/40"
          : "bg-white ring-border/70",
      )}
      dir={dir}
    >
      <div className="flex items-center justify-between mb-3">
        <span
          className={cn(
            "size-9 rounded-xl grid place-items-center",
            hero
              ? "bg-white/15 text-white"
              : "bg-cherry-100 text-cherry-600",
          )}
        >
          <Icon className="size-4" />
        </span>
        {hero && <ArrowUpRight className="size-4 opacity-70" />}
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
