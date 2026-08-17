import {
  Area,
  AreaChart,
  CartesianGrid,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from "recharts";
import { TrendingUp } from "lucide-react";
import { revenueSeries, type RangeKey } from "@/data/overview.mock";
import { useI18n } from "@/i18n";

export function RevenueChart({ range }: { range: RangeKey }) {
  const { tr, lang, dir } = useI18n();
  const locale = lang === "ar" ? "ar-DZ" : lang === "fr" ? "fr-FR" : "en-US";
  const fmt = (n: number) => n.toLocaleString(locale);
  const data = revenueSeries[range].map((d) => ({ ...d, label: tr(d.label) }));

  return (
    <div className="rounded-3xl bg-white ring-1 ring-cherry-200/60 p-6 h-full flex flex-col">
      <div className="flex items-start justify-between mb-6">
        <div>
          <h3 className="font-display font-bold text-lg">{tr("تحليل الإيرادات")}</h3>
          <p className="text-xs text-ink-muted mt-1">
            {tr("بالدينار الجزائري • حسب الفترة المحددة")}
          </p>
        </div>
        <div className="inline-flex items-center gap-1.5 rounded-full bg-cherry-100 px-3 py-1.5 text-[11px] font-semibold text-cherry-600">
          <TrendingUp className="size-3" />
          {tr("نمو مستقر")}
        </div>
      </div>

      <div className="flex-1 min-h-[280px]">
        <ResponsiveContainer width="100%" height="100%">
          <AreaChart data={data} margin={{ top: 10, right: 8, left: 8, bottom: 0 }}>
            <defs>
              <linearGradient id="revFill" x1="0" y1="0" x2="0" y2="1">
                <stop offset="0%" stopColor="#c45c7c" stopOpacity={0.35} />
                <stop offset="100%" stopColor="#c45c7c" stopOpacity={0} />
              </linearGradient>
            </defs>
            <CartesianGrid strokeDasharray="3 6" stroke="#f3dde5" vertical={false} />
            <XAxis
              dataKey="label"
              tick={{ fontSize: 11, fill: "#6b5a62" }}
              axisLine={false}
              tickLine={false}
              reversed={dir === "rtl"}
            />
            <YAxis
              orientation={dir === "rtl" ? "right" : "left"}
              tick={{ fontSize: 11, fill: "#6b5a62" }}
              axisLine={false}
              tickLine={false}
              width={60}
              tickFormatter={(v) => `${(v / 1000).toLocaleString(locale)}${lang === "ar" ? "ك" : "k"}`}
            />
            <Tooltip
              cursor={{ stroke: "#e88aab", strokeWidth: 1, strokeDasharray: "4 4" }}
              contentStyle={{
                background: "#1a1618",
                border: "none",
                borderRadius: 12,
                padding: "8px 12px",
                color: "#fff",
                fontSize: 12,
                direction: dir,
              }}
              labelStyle={{ color: "#f8c8d8", fontWeight: 600, marginBottom: 2 }}
              formatter={(v: number) => [`${fmt(v)} ${tr("د.ج")}`, tr("الإيرادات")]}
            />
            <Area
              type="monotone"
              dataKey="value"
              stroke="#c45c7c"
              strokeWidth={2.5}
              fill="url(#revFill)"
              activeDot={{ r: 5, fill: "#c45c7c", stroke: "#fff", strokeWidth: 2 }}
            />
          </AreaChart>
        </ResponsiveContainer>
      </div>
    </div>
  );
}
