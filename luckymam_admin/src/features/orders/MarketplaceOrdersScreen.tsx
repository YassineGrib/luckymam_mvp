import { OrderQueueScreen } from './OrderQueueScreen'
import { MARKETPLACE_ORDER_STATUSES } from '../../lib/enums'
import type { MarketplaceOrder } from '../../lib/orderTypes'
import { useSettings } from '../../lib/SettingsContext'

function formatDZD(amount: number) {
  return `${amount.toLocaleString('fr-FR')} DZD`
}

export function MarketplaceOrdersScreen() {
  const { language } = useSettings()

  const t = {
    fr: {
      title: "Commandes Marketplace",
      itemsLabel: "Articles",
      total: "Total",
      summaryLine: (o: MarketplaceOrder) => `${o.lines.length} article(s) · ${formatDZD(o.totalDZD)}`
    },
    en: {
      title: "Marketplace Orders",
      itemsLabel: "Items",
      total: "Total",
      summaryLine: (o: MarketplaceOrder) => `${o.lines.length} item(s) · ${formatDZD(o.totalDZD)}`
    }
  }[language]

  return (
    <OrderQueueScreen<MarketplaceOrder>
      title={t.title}
      collectionName="marketplace_orders"
      statuses={MARKETPLACE_ORDER_STATUSES}
      summaryLine={t.summaryLine}
      renderDetails={(o) => (
        <div>
          <p className="text-xs font-bold uppercase tracking-wider text-theme-muted mb-2">{t.itemsLabel}</p>
          <div className="space-y-3 mb-4">
            {o.lines.map((line) => (
              <div key={line.productId} className="flex justify-between text-xs font-semibold text-theme-text border-b border-theme-border/60 pb-2">
                <span className="font-medium text-theme-text">
                  {line.productName} <span className="text-brand-accent font-bold">×{line.quantity}</span>
                </span>
                <span className="text-theme-muted">{formatDZD(line.lineTotalDZD)}</span>
              </div>
            ))}
          </div>
          <div className="flex justify-between text-xs font-bold border-t border-theme-border pt-3">
            <span>{t.total}</span>
            <span className="text-brand-accent">{formatDZD(o.totalDZD)}</span>
          </div>
        </div>
      )}
    />
  )
}

