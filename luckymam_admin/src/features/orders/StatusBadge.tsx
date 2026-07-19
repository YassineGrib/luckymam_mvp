import { STATUS_COLORS, STATUS_LABELS_FR } from '../../lib/enums'

export function StatusBadge({ status }: { status: string }) {
  const color = STATUS_COLORS[status] ?? '#8B8794'
  const label = STATUS_LABELS_FR[status] ?? status
  return (
    <span
      className="inline-flex items-center rounded-full px-2.5 py-1 text-xs font-semibold"
      style={{ backgroundColor: `${color}1F`, color }}
    >
      {label}
    </span>
  )
}
