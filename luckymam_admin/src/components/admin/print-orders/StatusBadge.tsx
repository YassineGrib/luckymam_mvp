import { cn } from "@/lib/utils";
import { STATUS_META, type PrintStatus } from "@/data/print-orders.mock";
import { useI18n } from "@/i18n";

export function StatusBadge({ status, className }: { status: PrintStatus; className?: string }) {
  const { tr } = useI18n();
  const meta = STATUS_META[status];
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
