import { useMemo, useState, type ReactNode } from 'react'
import { useOrderQueue } from './useOrderQueue'
import { updateOrderStatus } from './updateOrderStatus'
import { StatusBadge } from './StatusBadge'
import { STATUS_LABELS_FR } from '../../lib/enums'
import type { BaseOrder } from '../../lib/orderTypes'

interface OrderQueueScreenProps<T extends BaseOrder> {
  title: string
  collectionName: string
  statuses: readonly string[]
  /** Short secondary line shown in the list row, e.g. album title or item count. */
  summaryLine: (order: T) => string
  /** Type-specific fields rendered in the detail panel. */
  renderDetails: (order: T) => ReactNode
}

export function OrderQueueScreen<T extends BaseOrder>({
  title,
  collectionName,
  statuses,
  summaryLine,
  renderDetails,
}: OrderQueueScreenProps<T>) {
  const { orders, loading, error } = useOrderQueue<T>(collectionName)
  const [statusFilter, setStatusFilter] = useState<string | null>(null)
  const [selectedId, setSelectedId] = useState<string | null>(null)
  const [updating, setUpdating] = useState(false)

  const filtered = useMemo(
    () => (statusFilter ? orders.filter((o) => o.status === statusFilter) : orders),
    [orders, statusFilter],
  )
  const selected = filtered.find((o) => o.id === selectedId) ?? filtered[0] ?? null

  async function handleStatusChange(newStatus: string) {
    if (!selected) return
    setUpdating(true)
    try {
      await updateOrderStatus(collectionName, selected.id, newStatus)
    } finally {
      setUpdating(false)
    }
  }

  return (
    <div className="flex h-screen">
      <div className="w-96 shrink-0 border-r border-gray-100 bg-white flex flex-col">
        <div className="px-5 py-4 border-b border-gray-100">
          <h1 className="font-semibold text-gray-900">{title}</h1>
          <p className="text-xs text-gray-400 mt-0.5">{orders.length} commande(s)</p>
        </div>

        <div className="px-4 py-3 flex flex-wrap gap-1.5 border-b border-gray-100">
          <FilterChip
            label="Toutes"
            active={statusFilter === null}
            onClick={() => setStatusFilter(null)}
          />
          {statuses.map((s) => (
            <FilterChip
              key={s}
              label={STATUS_LABELS_FR[s] ?? s}
              active={statusFilter === s}
              onClick={() => setStatusFilter(s)}
            />
          ))}
        </div>

        <div className="flex-1 overflow-y-auto">
          {loading && <p className="p-4 text-sm text-gray-400">Chargement…</p>}
          {error && <p className="p-4 text-sm text-error">{error}</p>}
          {!loading && filtered.length === 0 && (
            <p className="p-4 text-sm text-gray-400">Aucune commande.</p>
          )}
          {filtered.map((order) => (
            <button
              key={order.id}
              onClick={() => setSelectedId(order.id)}
              className={`w-full text-left px-4 py-3 border-b border-gray-50 hover:bg-gray-50 ${
                selected?.id === order.id ? 'bg-magenta-pink/5' : ''
              }`}
            >
              <div className="flex items-center justify-between mb-1">
                <span className="text-sm font-medium text-gray-900 truncate">
                  {order.fullName}
                </span>
                <StatusBadge status={order.status} />
              </div>
              <p className="text-xs text-gray-500 truncate">{summaryLine(order)}</p>
              <p className="text-xs text-gray-400 mt-0.5">
                {new Date(order.createdAt).toLocaleDateString('fr-FR', {
                  day: 'numeric',
                  month: 'short',
                  hour: '2-digit',
                  minute: '2-digit',
                })}
              </p>
            </button>
          ))}
        </div>
      </div>

      <div className="flex-1 overflow-y-auto p-8">
        {!selected ? (
          <p className="text-sm text-gray-400">Sélectionnez une commande.</p>
        ) : (
          <div className="max-w-xl">
            <div className="flex items-center justify-between mb-6">
              <h2 className="text-lg font-semibold text-gray-900">{selected.fullName}</h2>
              <StatusBadge status={selected.status} />
            </div>

            <dl className="space-y-3 text-sm mb-6">
              <Row label="Téléphone" value={selected.phone} />
              <Row label="Wilaya" value={selected.wilaya} />
              <Row label="Adresse" value={selected.address} />
            </dl>

            <div className="border-t border-gray-100 pt-6 mb-6">{renderDetails(selected)}</div>

            <div className="border-t border-gray-100 pt-6">
              <p className="text-xs font-medium text-gray-500 mb-2">Changer le statut</p>
              <div className="flex flex-wrap gap-2">
                {statuses.map((s) => (
                  <button
                    key={s}
                    disabled={updating || s === selected.status}
                    onClick={() => handleStatusChange(s)}
                    className="rounded-xl border border-gray-200 px-3 py-1.5 text-xs font-medium text-gray-700 hover:bg-gray-50 disabled:opacity-40"
                  >
                    {STATUS_LABELS_FR[s] ?? s}
                  </button>
                ))}
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  )
}

function Row({ label, value }: { label: string; value: ReactNode }) {
  return (
    <div className="flex justify-between gap-4">
      <dt className="text-gray-400">{label}</dt>
      <dd className="text-gray-900 text-right">{value}</dd>
    </div>
  )
}

function FilterChip({
  label,
  active,
  onClick,
}: {
  label: string
  active: boolean
  onClick: () => void
}) {
  return (
    <button
      onClick={onClick}
      className={`rounded-full px-3 py-1 text-xs font-medium transition ${
        active ? 'bg-magenta-pink text-white' : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
      }`}
    >
      {label}
    </button>
  )
}
