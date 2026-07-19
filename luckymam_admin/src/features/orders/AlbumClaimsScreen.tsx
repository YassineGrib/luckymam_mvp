import { OrderQueueScreen } from './OrderQueueScreen'
import { ALBUM_CLAIM_STATUSES } from '../../lib/enums'
import type { AlbumClaim } from '../../lib/orderTypes'
import { useSettings } from '../../lib/SettingsContext'

export function AlbumClaimsScreen() {
  const { language } = useSettings()

  const t = {
    fr: {
      title: "Albums imprimés VIP",
      child: "Enfant",
      period: "Période",
      summaryLine: (o: AlbumClaim) => `${o.childName} · ${o.dateRange}`
    },
    en: {
      title: "VIP Printed Albums",
      child: "Child",
      period: "Period",
      summaryLine: (o: AlbumClaim) => `${o.childName} · ${o.dateRange}`
    }
  }[language]

  return (
    <OrderQueueScreen<AlbumClaim>
      title={t.title}
      collectionName="album_claims"
      statuses={ALBUM_CLAIM_STATUSES}
      summaryLine={t.summaryLine}
      renderDetails={(o) => (
        <dl className="space-y-3.5 text-xs font-semibold text-theme-text">
          <div className="flex justify-between gap-4 border-b border-theme-border pb-2.5">
            <dt className="text-theme-muted font-medium">{t.child}</dt>
            <dd className="font-bold">{o.childName}</dd>
          </div>
          <div className="flex justify-between gap-4">
            <dt className="text-theme-muted font-medium">{t.period}</dt>
            <dd className="font-bold">{o.dateRange}</dd>
          </div>
        </dl>
      )}
    />
  )
}

