import { createFileRoute } from "@tanstack/react-router";
import { useMemo, useState, useEffect } from "react";
import {
  Search,
  Printer,
  Clock,
  Truck,
  PackageCheck,
  Layers,
  Crown,
  Download,
  CalendarRange,
  ShoppingBag,
} from "lucide-react";

import { AppShell } from "@/components/admin/AppShell";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { cn } from "@/lib/utils";
import {
  STATUS_META,
  type PrintOrder,
  type PrintStatus,
} from "@/data/print-orders.mock";
import { StatusBadge } from "@/components/admin/print-orders/StatusBadge";
import { StatusSelect } from "@/components/admin/print-orders/StatusSelect";
import { OrderDetailsSheet } from "@/components/admin/print-orders/OrderDetailsSheet";
import { useI18n } from "@/i18n";
import { useAdminProfile } from "@/hooks/useAdminProfile";
import "@/i18n/pages/print-orders";

// Firebase imports
import { 
  collection, 
  onSnapshot, 
  query, 
  doc, 
  updateDoc 
} from "firebase/firestore";
import { db } from "@/lib/firebase";

export const Route = createFileRoute("/print-orders")({
  head: () => ({
    meta: [
      { title: "طلبات الطباعة — Luckymam Admin" },
      { name: "description", content: "إدارة ومتابعة طلبات طباعة ألبومات صور الأطفال." },
    ],
  }),
  component: PrintOrdersPage,
});

type Filter = "all" | PrintStatus;
type TypeFilter = "all" | "vip" | "paid";

const FILTERS: { key: Filter; label: string; icon: React.ElementType }[] = [
  { key: "all", label: "الكل", icon: Layers },
  { key: "pending", label: "معلق", icon: Clock },
  { key: "processing", label: "قيد المعالجة", icon: Printer },
  { key: "shipped", label: "مشحون", icon: Truck },
  { key: "delivered", label: "تم التسليم", icon: PackageCheck },
];

function PrintOrdersPage() {
  const { tr, dir } = useI18n();
  const { displayName } = useAdminProfile();

  // Firestore collections states
  const [printOrders, setPrintOrders] = useState<PrintOrder[]>([]);
  const [albumClaims, setAlbumClaims] = useState<PrintOrder[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // Filters and selection states
  const [filter, setFilter] = useState<Filter>("all");
  const [typeFilter, setTypeFilter] = useState<TypeFilter>("all");
  const [queryStr, setQueryStr] = useState("");
  const [selectedId, setSelectedId] = useState<string | null>(null);
  const [sheetOpen, setSheetOpen] = useState(false);

  // Listen to print_orders
  useEffect(() => {
    const q = query(collection(db, "print_orders"));
    const unsubscribe = onSnapshot(
      q,
      (snapshot) => {
        const list = snapshot.docs.map((d) => {
          const data = d.data();
          const customerRaw = data.customer || {};
          const albumRaw = data.album || {};

          return {
            id: d.id,
            isVipFree: false,
            childName: data.childName || "",
            createdAt: data.createdAt || new Date().toISOString().split("T")[0],
            status: (data.status || "pending") as PrintStatus,
            statusUpdatedAt: data.statusUpdatedAt || "",
            statusUpdatedBy: data.statusUpdatedBy || "",
            customer: {
              name: customerRaw.name || tr("زبونة غير معروفة"),
              initials: customerRaw.initials || "أم",
              phone: customerRaw.phone || "",
              wilaya: customerRaw.wilaya || "",
              address: customerRaw.address || "",
            },
            album: {
              title: albumRaw.title || tr("ألبوم صور"),
              type: albumRaw.type || "custom",
              pages: Number(albumRaw.pages || 24),
            },
            history: [],
          } as PrintOrder;
        });
        setPrintOrders(list);
      },
      (err) => {
        console.error("Error fetching print_orders:", err);
        setError(err.message);
      }
    );
    return unsubscribe;
  }, [tr]);

  // Listen to album_claims (VIP claims)
  useEffect(() => {
    const q = query(collection(db, "album_claims"));
    const unsubscribe = onSnapshot(
      q,
      (snapshot) => {
        const list = snapshot.docs.map((d) => {
          const data = d.data();
          const customerRaw = data.customer || {};
          const albumRaw = data.album || {};

          return {
            id: d.id,
            isVipFree: true,
            childName: data.childName || "",
            createdAt: data.createdAt || new Date().toISOString().split("T")[0],
            status: (data.status || "pending") as PrintStatus,
            statusUpdatedAt: data.statusUpdatedAt || "",
            statusUpdatedBy: data.statusUpdatedBy || "",
            customer: {
              name: customerRaw.name || tr("زبونة غير معروفة"),
              initials: customerRaw.initials || "أم",
              phone: customerRaw.phone || "",
              wilaya: customerRaw.wilaya || "",
              address: customerRaw.address || "",
            },
            album: {
              title: albumRaw.title || tr("ألبوم صور VIP"),
              type: albumRaw.type || "predefined",
              pages: Number(albumRaw.pages || 32),
            },
            history: [],
          } as PrintOrder;
        });
        setAlbumClaims(list);
        setLoading(false);
      },
      (err) => {
        console.error("Error fetching album_claims:", err);
        setError(err.message);
        setLoading(false);
      }
    );
    return unsubscribe;
  }, [tr]);

  // Merge lists in dynamic order
  const orders = useMemo(() => {
    const combined = [...printOrders, ...albumClaims];
    return combined.sort((a, b) => (b.createdAt || "").localeCompare(a.createdAt || ""));
  }, [printOrders, albumClaims]);

  // Update order/claim status
  const updateStatus = async (id: string, next: PrintStatus) => {
    const foundOrder = orders.find((o) => o.id === id);
    if (!foundOrder) return;

    const targetCollection = foundOrder.isVipFree ? "album_claims" : "print_orders";

    try {
      const docRef = doc(db, targetCollection, id);
      await updateDoc(docRef, {
        status: next,
        statusUpdatedAt: new Date().toISOString().replace("T", " ").substring(0, 16),
        statusUpdatedBy: displayName,
      });
    } catch (err: any) {
      console.error(`Error updating status for ${id} in ${targetCollection}:`, err);
      alert(`خطأ أثناء تحديث الحالة: ${err.message}`);
    }
  };

  const counts = useMemo(() => {
    const base: Record<Filter, number> = {
      all: orders.length,
      pending: 0,
      processing: 0,
      shipped: 0,
      delivered: 0,
    };
    for (const o of orders) {
      if (base[o.status] !== undefined) {
        base[o.status]++;
      }
    }
    return base;
  }, [orders]);

  const filtered = useMemo(() => {
    return orders.filter((o) => {
      // PrintStatus filter
      if (filter !== "all" && o.status !== filter) return false;
      // Type filter (VIP vs Paid)
      if (typeFilter === "vip" && !o.isVipFree) return false;
      if (typeFilter === "paid" && o.isVipFree) return false;
      // Search text query
      if (queryStr) {
        const q = queryStr.toLowerCase().trim();
        if (
          !o.id.toLowerCase().includes(q) &&
          !o.customer.name.toLowerCase().includes(q) &&
          !(o.childName || "").toLowerCase().includes(q) &&
          !(o.album.title || "").toLowerCase().includes(q)
        )
          return false;
      }
      return true;
    });
  }, [orders, filter, typeFilter, queryStr]);

  const selected = orders.find((o) => o.id === selectedId) ?? null;

  // Reconstruct history dynamically before passing to Details Sheet
  const selectedWithDynamicHistory = useMemo(() => {
    if (!selected) return null;
    const historyLog = [
      {
        status: "pending" as PrintStatus,
        at: selected.createdAt,
        by: tr("النظام"),
      },
    ];

    if (selected.statusUpdatedAt && selected.status !== "pending") {
      historyLog.push({
        status: selected.status as PrintStatus,
        at: selected.statusUpdatedAt,
        by: selected.statusUpdatedBy || tr("الأدمن"),
      });
    }

    return {
      ...selected,
      history: historyLog,
    } as PrintOrder;
  }, [selected, tr]);

  const vipCount = orders.filter((o) => o.isVipFree).length;

  return (
    <AppShell>
      <div className="p-6 lg:p-10 space-y-8 max-w-[1600px] text-start font-sans" dir={dir}>
        {/* Header */}
        <header className="flex flex-wrap items-end justify-between gap-4">
          <div>
            <div className="text-xs font-bold uppercase tracking-[0.2em] text-cherry-600 mb-2">
              {tr("الطباعة والتوصيل")}
            </div>
            <h1 className="font-display font-extrabold text-3xl md:text-4xl tracking-tight">
              {tr("طلبات طباعة الألبومات")}
            </h1>
            <p className="text-sm text-ink-muted mt-2 max-w-[56ch]">
              {tr(
                "تابعي حالة كل طلب من الاستلام حتى التسليم، وحدّثي المراحل بسرعة من الجدول أو من لوحة التفاصيل.",
              )}
            </p>
          </div>
        </header>

        {loading ? (
          <div className="text-center py-6 text-sm text-ink-muted">{tr("جاري تحميل البيانات...")}</div>
        ) : error ? (
          <div className="text-center py-6 text-sm text-rose-500 border border-rose-100 rounded-2xl bg-rose-50/50">{error}</div>
        ) : (
          <>
            {/* Stats strip */}
            <section className="grid grid-cols-2 md:grid-cols-5 gap-3">
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
                active={filter === "processing"}
                onClick={() => setFilter("processing")}
                label={tr("قيد المعالجة")}
                value={counts.processing}
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
            </section>

            {/* Toolbar */}
            <section className="flex flex-wrap items-center justify-between gap-3">
              <div className="flex flex-wrap items-center gap-2">
                <div className="inline-flex items-center rounded-full bg-white ring-1 ring-border p-1 text-[11px] font-semibold">
                  <Crown className="size-3.5 text-cherry-600 mx-2" />
                  <button
                    onClick={() => setTypeFilter("all")}
                    className={cn(
                      "px-3 py-1 rounded-full transition-colors cursor-pointer",
                      typeFilter === "all" ? "bg-cherry-600 text-white" : "text-ink-muted",
                    )}
                  >
                    {tr("كل الطلبات")}
                  </button>
                  <button
                    onClick={() => setTypeFilter("vip")}
                    className={cn(
                      "px-3 py-1 rounded-full transition-colors cursor-pointer",
                      typeFilter === "vip" ? "bg-cherry-600 text-white" : "text-ink-muted",
                    )}
                  >
                    {tr("VIP مجاني")}
                  </button>
                  <button
                    onClick={() => setTypeFilter("paid")}
                    className={cn(
                      "px-3 py-1 rounded-full transition-colors cursor-pointer",
                      typeFilter === "paid" ? "bg-cherry-600 text-white" : "text-ink-muted",
                    )}
                  >
                    {tr("طلبات مدفوعة")}
                  </button>
                </div>

                <div className="h-6 w-px bg-border mx-1" />

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
                      <span>{tr(f.label)}</span>
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
              <div className="relative">
                <Search className="size-4 text-ink-muted absolute right-3 top-1/2 -translate-y-1/2" />
                <Input
                  value={queryStr}
                  onChange={(e) => setQueryStr(e.target.value)}
                  placeholder={tr("بحث بالاسم أو رقم الطلب…")}
                  className="w-72 rounded-full pr-9 bg-white border-border/70 focus-visible:ring-cherry-200"
                />
              </div>
            </section>

            {/* Results meta */}
            <div className="flex items-center justify-between text-xs text-ink-muted -mt-4 flex-row-reverse">
              <span>
                <span className="font-bold text-ink">{filtered.length}</span> {tr("طلب مطابق")}
              </span>
              <span>
                <Crown className="size-3.5 text-amber-500 inline ml-1" />
                <span className="font-bold text-ink">{vipCount}</span> {tr("طلب VIP مجاني")}
              </span>
            </div>

            {/* Table */}
            <section className="rounded-3xl bg-white ring-1 ring-border/70 overflow-hidden shadow-sm shadow-cherry-100/40">
              <div className="overflow-x-auto">
                <table className="w-full text-sm">
                  <thead>
                    <tr className="text-[11px] uppercase tracking-wider text-ink-muted bg-cherry-50/50">
                      <Th>{tr("الطلب")}</Th>
                      <Th>{tr("صاحبة الطلب")}</Th>
                      <Th>{tr("الولاية")}</Th>
                      <Th>{tr("الألبوم")}</Th>
                      <Th>{tr("الصفحات")}</Th>
                      <Th>{tr("النوع")}</Th>
                      <Th>{tr("التاريخ")}</Th>
                      <Th>{tr("الحالة")}</Th>
                      <Th className="text-left">{tr("تحديث")}</Th>
                    </tr>
                  </thead>
                  <tbody>
                    {filtered.map((o) => (
                      <tr
                        key={o.id}
                        onClick={() => {
                          setSelectedId(o.id);
                          setSheetOpen(true);
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
                                {tr("طفل: ")}{o.childName}
                              </div>
                            </div>
                          </div>
                        </td>
                        <td className="px-5 py-4 text-xs text-ink-muted">
                          {o.customer.wilaya}
                        </td>
                        <td className="px-5 py-4">
                          <div className="text-[13px] font-medium">{o.album.title}</div>
                          <div className="text-[11px] text-ink-muted">
                            {o.album.type === "custom" ? tr("مخصص") : tr("معد مسبقاً")}
                          </div>
                        </td>
                        <td className="px-5 py-4 text-xs">{o.album.pages}</td>
                        <td className="px-5 py-4">
                          {o.isVipFree ? (
                            <span className="inline-flex items-center gap-1 rounded-full bg-cherry-100 px-2 py-0.5 text-[10px] font-bold text-cherry-600 ring-1 ring-cherry-200">
                              <Crown className="size-3" /> {tr("مجاني VIP")}
                            </span>
                          ) : (
                            <span className="text-[11px] text-ink-muted">{tr("مدفوع")}</span>
                          )}
                        </td>
                        <td className="px-5 py-4 text-xs text-ink-muted whitespace-nowrap">
                          {o.createdAt}
                        </td>
                        <td className="px-5 py-4">
                          <StatusBadge status={o.status} />
                        </td>
                        <td className="px-5 py-4" onClick={(e) => e.stopPropagation()}>
                          <StatusSelect
                            value={o.status}
                            onChange={(s) => updateStatus(o.id, s)}
                          />
                        </td>
                      </tr>
                    ))}
                    {filtered.length === 0 && (
                      <tr>
                        <td colSpan={9} className="px-5 py-16 text-center">
                          <div className="mx-auto size-12 rounded-2xl bg-cherry-100 grid place-items-center text-cherry-600 mb-3">
                            <Printer className="size-5" />
                          </div>
                          <div className="text-sm font-semibold">{tr("لا توجد طلبات مطابقة")}</div>
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

      <OrderDetailsSheet
        order={selectedWithDynamicHistory}
        open={sheetOpen}
        onOpenChange={setSheetOpen}
        onStatusChange={(id, s) => {
          updateStatus(id, s);
        }}
      />
    </AppShell>
  );
}

// Subcomponents

function Th({ children, className }: { children: React.ReactNode; className?: string }) {
  return (
    <th className={cn("text-right font-semibold px-5 py-3.5 text-ink-muted", className)}>{children}</th>
  );
}

const TONES = {
  cherry: { bg: "bg-cherry-100", text: "text-cherry-600", ring: "ring-cherry-200" },
  amber: { bg: "bg-amber-100", text: "text-amber-700", ring: "ring-amber-200" },
  sky: { bg: "bg-sky-100", text: "text-sky-700", ring: "ring-sky-200" },
  violet: { bg: "bg-violet-100", text: "text-violet-700", ring: "ring-violet-200" },
  emerald: { bg: "bg-emerald-100", text: "text-emerald-700", ring: "ring-emerald-200" },
} as const;

function StatTile({
  label,
  value,
  icon: Icon,
  tone,
  active,
  onClick,
}: {
  label: string;
  value: number;
  icon: React.ElementType;
  tone: keyof typeof TONES;
  active?: boolean;
  onClick?: () => void;
}) {
  const { tr } = useI18n();
  const t = TONES[tone];
  return (
    <button
      onClick={onClick}
      className={cn(
        "text-start rounded-2xl bg-white p-4 ring-1 transition-all group cursor-pointer",
        active
          ? "ring-cherry-600 shadow-md shadow-cherry-200/60 -translate-y-0.5"
          : "ring-border/70 hover:ring-cherry-200 hover:-translate-y-0.5",
      )}
    >
      <div className="flex items-center justify-between mb-3">
        <div className={cn("size-9 rounded-xl grid place-items-center ring-1", t.bg, t.text, t.ring)}>
          <Icon className="size-4" />
        </div>
        {active && (
          <span className="text-[10px] font-bold text-cherry-600 uppercase tracking-wider">
            {tr("مُفعّل")}
          </span>
        )}
      </div>
      <div className="font-display font-extrabold text-2xl tracking-tight text-ink">{value}</div>
      <div className="text-[11px] text-ink-muted mt-2">{label}</div>
    </button>
  );
}
