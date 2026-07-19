import { OrderQueueScreen } from './OrderQueueScreen'
import { PRINT_ORDER_STATUSES } from '../../lib/enums'
import type { PrintOrder } from '../../lib/orderTypes'
import { useSettings } from '../../lib/SettingsContext'

export function PrintOrdersScreen() {
  const { language } = useSettings()

  const t = {
    fr: {
      title: "Commandes d'impression",
      child: "Enfant",
      album: "Album",
      albumPredefined: "prédéfini",
      albumStandard: "libre",
      pages: "Pages",
      vipFree: "Offert VIP",
      yes: "Oui",
      no: "Non",
      summaryLine: (o: PrintOrder) => `${o.albumTitle} · ${o.pageCount} pages`
    },
    en: {
      title: "Print Orders",
      child: "Child",
      album: "Album",
      albumPredefined: "predefined",
      albumStandard: "free",
      pages: "Pages",
      vipFree: "VIP Free",
      yes: "Yes",
      no: "No",
      summaryLine: (o: PrintOrder) => `${o.albumTitle} · ${o.pageCount} pages`
    }
  }[language]

  return (
    <OrderQueueScreen<PrintOrder>
      title={t.title}
      collectionName="print_orders"
      statuses={PRINT_ORDER_STATUSES}
      summaryLine={t.summaryLine}
      renderDetails={(o) => (
        <dl className="space-y-3.5 text-xs font-semibold text-theme-text">
          <div className="flex justify-between gap-4 border-b border-theme-border pb-2.5">
            <dt className="text-theme-muted font-medium">{t.child}</dt>
            <dd className="font-bold">{o.childName}</dd>
          </div>
          <div className="flex justify-between gap-4 border-b border-theme-border pb-2.5">
            <dt className="text-theme-muted font-medium">{t.album}</dt>
            <dd className="font-bold text-right">
              {o.albumTitle} ({o.albumType === 'predefined' ? t.albumPredefined : t.albumStandard})
            </dd>
          </div>
          <div className="flex justify-between gap-4 border-b border-theme-border pb-2.5">
            <dt className="text-theme-muted font-medium">{t.pages}</dt>
            <dd className="font-bold">{o.pageCount}</dd>
          </div>
          <div className="flex justify-between gap-4">
            <dt className="text-theme-muted font-medium">{t.vipFree}</dt>
            <dd className="font-bold">{o.isVipFree ? t.yes : t.no}</dd>
          </div>
        </dl>
      )}
    />
  )
}

