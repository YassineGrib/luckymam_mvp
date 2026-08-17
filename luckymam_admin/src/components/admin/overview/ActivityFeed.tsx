import { Printer, ShoppingBag, ArrowLeft, ArrowRight } from "lucide-react";
import { activities, type Activity } from "@/data/overview.mock";
import { cn } from "@/lib/utils";
import { useI18n } from "@/i18n";

const statusMap: Record<
  Activity["status"],
  { label: string; className: string }
> = {
  pending: { label: "معلق", className: "bg-amber-50 text-amber-700" },
  processing: { label: "قيد المعالجة", className: "bg-blue-50 text-blue-700" },
  shipped: { label: "مشحون", className: "bg-cherry-100 text-cherry-600" },
  delivered: { label: "تم التسليم", className: "bg-emerald-50 text-emerald-700" },
};

export function ActivityFeed() {
  const { tr, dir } = useI18n();
  const Arrow = dir === "rtl" ? ArrowLeft : ArrowRight;
  return (
    <div className="rounded-3xl bg-white ring-1 ring-cherry-200/60 overflow-hidden h-full flex flex-col">
      <div className="p-6 pb-3 flex items-center justify-between">
        <div>
          <h3 className="font-display font-bold text-lg">{tr("آخر النشاطات")}</h3>
          <p className="text-xs text-ink-muted mt-1">
            {tr("طلبات الطباعة والمتجر مجمعة زمنياً")}
          </p>
        </div>
        <button className="inline-flex items-center gap-1 text-xs font-bold text-cherry-600 hover:gap-2 transition-all">
          {tr("عرض الكل")}
          <Arrow className="size-3.5" />
        </button>
      </div>

      <ul className="divide-y divide-border flex-1">
        {activities.map((a) => {
          const Icon = a.type === "print" ? Printer : ShoppingBag;
          const s = statusMap[a.status];
          return (
            <li
              key={a.id}
              className="p-4 px-6 flex items-center gap-4 hover:bg-cherry-100/30 transition-colors"
            >
              <div
                className={cn(
                  "size-11 rounded-2xl grid place-items-center shrink-0",
                  a.type === "print"
                    ? "bg-cherry-100 text-cherry-600"
                    : "bg-emerald-50 text-emerald-600",
                )}
              >
                <Icon className="size-[18px]" />
              </div>
              <div className="flex-1 min-w-0">
                <div className="flex items-center gap-2 mb-0.5">
                  <span className="text-sm font-semibold truncate">
                    {tr(a.user)}
                  </span>
                  <span className="text-[10px] px-1.5 py-0.5 bg-cherry-100/70 rounded-full text-ink-muted font-medium">
                    {tr(a.type === "print" ? "طباعة" : "متجر")}
                  </span>
                  <span className="text-[10px] text-ink-muted font-mono">
                    #{a.id}
                  </span>
                </div>
                <p className="text-xs text-ink-muted truncate">{tr(a.detail)}</p>
              </div>
              <div className="text-left shrink-0 space-y-1">
                <div className="text-[10px] text-ink-muted">{tr(a.time)}</div>
                <span
                  className={cn(
                    "inline-block text-[10px] font-bold px-2 py-0.5 rounded-full",
                    s.className,
                  )}
                >
                  {tr(s.label)}
                </span>
              </div>
            </li>
          );
        })}
      </ul>
    </div>
  );
}
