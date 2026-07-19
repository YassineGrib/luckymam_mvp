import { OrderQueueScreen } from './OrderQueueScreen'
import { ALBUM_CLAIM_STATUSES } from '../../lib/enums'
import type { AlbumClaim } from '../../lib/orderTypes'

export function AlbumClaimsScreen() {
  return (
    <OrderQueueScreen<AlbumClaim>
      title="Albums imprimés VIP"
      collectionName="album_claims"
      statuses={ALBUM_CLAIM_STATUSES}
      summaryLine={(o) => `${o.childName} · ${o.dateRange}`}
      renderDetails={(o) => (
        <dl className="space-y-3 text-sm">
          <div className="flex justify-between gap-4">
            <dt className="text-gray-400">Enfant</dt>
            <dd className="text-gray-900">{o.childName}</dd>
          </div>
          <div className="flex justify-between gap-4">
            <dt className="text-gray-400">Période</dt>
            <dd className="text-gray-900">{o.dateRange}</dd>
          </div>
        </dl>
      )}
    />
  )
}
