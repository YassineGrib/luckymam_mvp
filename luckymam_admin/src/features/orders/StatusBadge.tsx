import { STATUS_COLORS, STATUS_LABELS_FR } from '../../lib/enums'
import { useSettings } from '../../lib/SettingsContext'

const STATUS_LABELS_EN: Record<string, string> = {
  pending: 'Pending',
  processing: 'Processing',
  confirmed: 'Confirmed',
  shipped: 'Shipped',
  delivered: 'Delivered',
  cancelled: 'Cancelled',
}

export function StatusBadge({ status }: { status: string }) {
  const { language } = useSettings()
  const color = STATUS_COLORS[status] ?? '#8B8794'
  
  const labelMap = language === 'en' ? STATUS_LABELS_EN : STATUS_LABELS_FR
  const label = labelMap[status] ?? status

  return (
    <span
      className="inline-flex items-center gap-1.5 rounded-full px-2.5 py-1 text-[10px] font-extrabold uppercase tracking-wide border transition-all duration-200"
      style={{ 
        backgroundColor: `${color}12`, 
        color: color, 
        borderColor: `${color}30` 
      }}
    >
      <span className="h-1.5 w-1.5 rounded-full" style={{ backgroundColor: color }} />
      <span>{label}</span>
    </span>
  )
}


