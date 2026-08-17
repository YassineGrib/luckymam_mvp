import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { STATUS_META, STATUS_ORDER, type PrintStatus } from "@/data/print-orders.mock";
import { cn } from "@/lib/utils";
import { useI18n } from "@/i18n";

export function StatusSelect({
  value,
  onChange,
}: {
  value: PrintStatus;
  onChange: (v: PrintStatus) => void;
}) {
  const { tr } = useI18n();
  return (
    <Select value={value} onValueChange={(v) => onChange(v as PrintStatus)}>
      <SelectTrigger
        className="h-8 w-[140px] rounded-full border-border/70 bg-white text-xs font-semibold shadow-none focus:ring-cherry-200"
        onClick={(e) => e.stopPropagation()}
      >
        <SelectValue />
      </SelectTrigger>
      <SelectContent align="end">
        {STATUS_ORDER.map((s) => (
          <SelectItem key={s} value={s} className="text-xs">
            <span className="flex items-center gap-2">
              <span className={cn("size-1.5 rounded-full", STATUS_META[s].dot)} />
              {tr(STATUS_META[s].label)}
            </span>
          </SelectItem>
        ))}
      </SelectContent>
    </Select>
  );
}
