import { cn } from "@/lib/utils";
import type { RangeKey } from "@/data/overview.mock";
import { useI18n } from "@/i18n";

const options: { key: RangeKey; label: string }[] = [
  { key: "7d", label: "٧ أيام" },
  { key: "30d", label: "٣٠ يوم" },
  { key: "all", label: "كل الوقت" },
];

export function TimeRangeTabs({
  value,
  onChange,
}: {
  value: RangeKey;
  onChange: (v: RangeKey) => void;
}) {
  const { tr } = useI18n();
  return (
    <div className="inline-flex items-center gap-1 rounded-full bg-white p-1 ring-1 ring-border shadow-sm">
      {options.map((opt) => (
        <button
          key={opt.key}
          onClick={() => onChange(opt.key)}
          className={cn(
            "px-4 py-1.5 rounded-full text-xs font-semibold transition-all",
            value === opt.key
              ? "bg-cherry-600 text-white shadow-sm shadow-cherry-600/30"
              : "text-ink-muted hover:text-cherry-600",
          )}
        >
          {tr(opt.label)}
        </button>
      ))}
    </div>
  );
}

