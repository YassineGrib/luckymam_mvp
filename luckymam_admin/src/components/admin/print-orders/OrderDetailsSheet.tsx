import {
  Sheet,
  SheetContent,
  SheetHeader,
  SheetTitle,
  SheetDescription,
} from "@/components/ui/sheet";
import { Button } from "@/components/ui/button";
import {
  STATUS_META,
  STATUS_ORDER,
  type PrintOrder,
  type PrintStatus,
} from "@/data/print-orders.mock";
import { StatusBadge } from "./StatusBadge";
import {
  Phone,
  MapPin,
  Baby,
  BookOpen,
  Crown,
  Check,
  ArrowLeft,
} from "lucide-react";
import { cn } from "@/lib/utils";
import { useI18n } from "@/i18n";

export function OrderDetailsSheet({
  order,
  open,
  onOpenChange,
  onStatusChange,
}: {
  order: PrintOrder | null;
  open: boolean;
  onOpenChange: (o: boolean) => void;
  onStatusChange: (id: string, s: PrintStatus) => void;
}) {
  const { tr } = useI18n();
  if (!order) return null;

  const currentIdx = STATUS_ORDER.indexOf(order.status);

  return (
    <Sheet open={open} onOpenChange={onOpenChange}>
      <SheetContent
        side="left"
        className="w-full sm:max-w-[540px] overflow-y-auto bg-cherry-50/60 p-0"
      >
        <div className="p-6 border-b border-border bg-white">
          <SheetHeader className="p-0 text-right space-y-2">
            <div className="flex items-center gap-2 text-[10px] font-bold tracking-[0.2em] uppercase text-cherry-600">
              {tr("تفاصيل الطلب")}
            </div>
            <SheetTitle className="font-display text-2xl tracking-tight">
              {order.id}
            </SheetTitle>
            <SheetDescription className="flex items-center gap-2 text-xs">
              <StatusBadge status={order.status} />
              {order.isVipFree && (
                <span className="inline-flex items-center gap-1 rounded-full bg-cherry-100 px-2 py-0.5 text-[10px] font-bold text-cherry-600 ring-1 ring-cherry-200">
                  <Crown className="size-3" /> {tr("مجاني VIP")}
                </span>
              )}
            </SheetDescription>
          </SheetHeader>
        </div>

        <div className="p-6 space-y-6">
          {/* Customer */}
          <section className="rounded-2xl bg-white p-5 ring-1 ring-border/70">
            <div className="flex items-center gap-3 mb-4">
              <div className="size-11 rounded-2xl bg-cherry-100 text-cherry-600 grid place-items-center font-bold">
                {order.customer.initials}
              </div>
              <div>
                <div className="font-semibold text-sm">{order.customer.name}</div>
                <div className="text-[11px] text-ink-muted">{tr("صاحبة الطلب")}</div>
              </div>
            </div>
            <dl className="grid grid-cols-1 gap-2.5 text-xs">
              <Row icon={Phone} label={tr("الهاتف")} value={order.customer.phone} />
              <Row icon={MapPin} label={tr("الولاية")} value={order.customer.wilaya} />
              <Row icon={MapPin} label={tr("العنوان")} value={order.customer.address} />
              <Row icon={Baby} label={tr("اسم الطفل")} value={order.childName} />
            </dl>
          </section>

          {/* Album */}
          <section className="rounded-2xl bg-white p-5 ring-1 ring-border/70">
            <div className="flex items-center gap-2 mb-3">
              <BookOpen className="size-4 text-cherry-600" />
              <h3 className="font-semibold text-sm">{tr("تفاصيل الألبوم")}</h3>
            </div>
            <div className="space-y-2 text-xs">
              <div className="flex justify-between">
                <span className="text-ink-muted">{tr("العنوان")}</span>
                <span className="font-medium">{order.album.title}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-ink-muted">{tr("النوع")}</span>
                <span className="font-medium">
                  {order.album.type === "custom" ? tr("مخصص") : tr("معد مسبقاً")}
                </span>
              </div>
              <div className="flex justify-between">
                <span className="text-ink-muted">{tr("عدد الصفحات")}</span>
                <span className="font-medium">{order.album.pages} {tr("صفحة")}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-ink-muted">{tr("مجاني VIP؟")}</span>
                <span className="font-medium">{order.isVipFree ? tr("نعم") : tr("لا")}</span>
              </div>
            </div>
          </section>

          {/* Action buttons — progression */}
          <section>
            <h3 className="font-semibold text-sm mb-3">{tr("تحديث الحالة")}</h3>
            <div className="grid grid-cols-4 gap-2">
              {STATUS_ORDER.map((s, i) => {
                const done = i <= currentIdx;
                const isCurrent = i === currentIdx;
                return (
                  <button
                    key={s}
                    onClick={() => onStatusChange(order.id, s)}
                    className={cn(
                      "rounded-xl p-2.5 text-[11px] font-semibold ring-1 transition-all text-center",
                      isCurrent
                        ? "bg-cherry-600 text-white ring-cherry-600 shadow-sm shadow-cherry-600/30"
                        : done
                          ? "bg-white text-ink ring-border"
                          : "bg-white/50 text-ink-muted ring-border/60 hover:bg-white",
                    )}
                  >
                    <div className="grid place-items-center mb-1">
                      <span
                        className={cn(
                          "size-5 rounded-full grid place-items-center",
                          isCurrent
                            ? "bg-white/25"
                            : done
                              ? STATUS_META[s].dot + " text-white"
                              : "bg-cherry-100 text-cherry-600",
                        )}
                      >
                        {done ? <Check className="size-3" /> : i + 1}
                      </span>
                    </div>
                    {tr(STATUS_META[s].label)}
                  </button>
                );
              })}
            </div>
          </section>

          {/* Timeline */}
          <section className="rounded-2xl bg-white p-5 ring-1 ring-border/70">
            <h3 className="font-semibold text-sm mb-4">{tr("سجل التحديثات")}</h3>
            <ol className="relative space-y-4">
              {order.history
                .slice()
                .reverse()
                .map((h, i) => (
                  <li key={i} className="flex gap-3">
                    <div className="flex flex-col items-center">
                      <span
                        className={cn("size-2.5 rounded-full mt-1.5", STATUS_META[h.status].dot)}
                      />
                      {i < order.history.length - 1 && (
                        <span className="w-px flex-1 bg-border mt-1" />
                      )}
                    </div>
                    <div className="pb-1">
                      <div className="text-xs font-semibold">
                        {tr(STATUS_META[h.status].label)}
                      </div>
                      <div className="text-[11px] text-ink-muted mt-0.5">
                        {h.at} • {tr("بواسطة ")}{h.by}
                      </div>
                    </div>
                  </li>
                ))}
            </ol>
          </section>

          <Button
            variant="ghost"
            className="w-full text-ink-muted"
            onClick={() => onOpenChange(false)}
          >
            <ArrowLeft className="size-4 ml-1" /> {tr("إغلاق")}
          </Button>
        </div>
      </SheetContent>
    </Sheet>
  );
}

function Row({
  icon: Icon,
  label,
  value,
}: {
  icon: React.ElementType;
  label: string;
  value: string;
}) {
  return (
    <div className="flex items-start gap-2.5">
      <Icon className="size-3.5 text-cherry-600 mt-0.5 shrink-0" />
      <div className="flex-1 flex justify-between gap-3">
        <span className="text-ink-muted">{label}</span>
        <span className="font-medium text-right">{value}</span>
      </div>
    </div>
  );
}
