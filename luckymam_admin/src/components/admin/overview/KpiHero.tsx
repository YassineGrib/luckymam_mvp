import { TrendingUp } from "lucide-react";
import { kpis } from "@/data/overview.mock";
import { useI18n } from "@/i18n";

export function KpiHero({ showDelta }: { showDelta: boolean }) {
  const { tr, lang } = useI18n();
  const { revenue } = kpis;
  const bars = [40, 62, 55, 70, 48, 82, 66, 90, 74, 100];
  const locale = lang === "ar" ? "ar-DZ" : lang === "fr" ? "fr-FR" : "en-US";
  const fmt = (n: number) => n.toLocaleString(locale, { maximumFractionDigits: 0 });
  return (
    <div className="relative overflow-hidden rounded-3xl bg-white ring-1 ring-cherry-200/60 p-8 group hover:shadow-xl hover:shadow-cherry-600/5 transition-all">
      <div className="absolute -top-16 -left-16 size-64 rounded-full bg-cherry-100 blur-3xl opacity-70" />
      <div className="relative flex flex-col h-full min-h-[240px]">
        <div className="flex items-start justify-between">
          <div>
            <div className="text-xs font-bold uppercase tracking-[0.14em] text-ink-muted">
              {tr("الإيرادات المتوقعة")}
            </div>
            {showDelta && (
              <div className="mt-2 inline-flex items-center gap-1.5 rounded-full bg-emerald-50 px-2.5 py-1 text-[11px] font-semibold text-emerald-700">
                <TrendingUp className="size-3" />
                <span>+{revenue.delta}% {tr("مقارنة بالفترة السابقة")}</span>
              </div>
            )}
          </div>
          <div className="size-10 rounded-2xl bg-cherry-100 grid place-items-center text-cherry-600">
            <TrendingUp className="size-5" />
          </div>
        </div>

        <div className="mt-8 flex items-baseline gap-3">
          <span className="font-display font-extrabold text-6xl md:text-7xl tracking-tighter leading-none">
            {fmt(revenue.value)}
          </span>
          <span className="font-display font-bold text-xl text-cherry-400">
            {tr("د.ج")}
          </span>
        </div>

        <p className="mt-3 text-sm text-ink-muted">{tr(revenue.sub)}</p>

        <div className="mt-auto pt-6 flex items-end gap-1.5 h-14">
          {bars.map((h, i) => (
            <div
              key={i}
              className={
                "flex-1 rounded-t-md transition-all group-hover:opacity-90 " +
                (i === bars.length - 1
                  ? "bg-cherry-600"
                  : "bg-cherry-200/70")
              }
              style={{ height: `${h}%` }}
            />
          ))}
        </div>
      </div>
    </div>
  );
}
