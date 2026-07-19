import { OrderQueueScreen } from './OrderQueueScreen'
import { PRINT_ORDER_STATUSES } from '../../lib/enums'
import type { PrintOrder } from '../../lib/orderTypes'

export function PrintOrdersScreen() {
  return (
    <OrderQueueScreen<PrintOrder>
      title="Commandes d'impression"
      collectionName="print_orders"
      statuses={PRINT_ORDER_STATUSES}
      summaryLine={(o) => `${o.albumTitle} · ${o.pageCount} pages`}
      renderDetails={(o) => (
        <dl className="space-y-3 text-sm">
          <div className="flex justify-between gap-4">
            <dt className="text-gray-400">Enfant</dt>
            <dd className="text-gray-900">{o.childName}</dd>
          </div>
          <div className="flex justify-between gap-4">
            <dt className="text-gray-400">Album</dt>
            <dd className="text-gray-900 text-right">
              {o.albumTitle} ({o.albumType === 'predefined' ? 'prédéfini' : 'libre'})
            </dd>
          </div>
          <div className="flex justify-between gap-4">
            <dt className="text-gray-400">Pages</dt>
            <dd className="text-gray-900">{o.pageCount}</dd>
          </div>
          <div className="flex justify-between gap-4">
            <dt className="text-gray-400">Offert VIP</dt>
            <dd className="text-gray-900">{o.isVipFree ? 'Oui' : 'Non'}</dd>
          </div>
        </dl>
      )}
    />
  )
}
