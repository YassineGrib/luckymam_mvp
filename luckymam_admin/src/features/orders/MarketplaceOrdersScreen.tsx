import { OrderQueueScreen } from './OrderQueueScreen'
import { MARKETPLACE_ORDER_STATUSES } from '../../lib/enums'
import type { MarketplaceOrder } from '../../lib/orderTypes'

function formatDZD(amount: number) {
  return `${amount.toLocaleString('fr-FR')} DZD`
}

export function MarketplaceOrdersScreen() {
  return (
    <OrderQueueScreen<MarketplaceOrder>
      title="Commandes Marketplace"
      collectionName="marketplace_orders"
      statuses={MARKETPLACE_ORDER_STATUSES}
      summaryLine={(o) => `${o.lines.length} article(s) · ${formatDZD(o.totalDZD)}`}
      renderDetails={(o) => (
        <div>
          <p className="text-xs font-medium text-gray-500 mb-2">Articles</p>
          <div className="space-y-2 mb-4">
            {o.lines.map((line) => (
              <div key={line.productId} className="flex justify-between text-sm">
                <span className="text-gray-900">
                  {line.productName} ×{line.quantity}
                </span>
                <span className="text-gray-500">{formatDZD(line.lineTotalDZD)}</span>
              </div>
            ))}
          </div>
          <div className="flex justify-between text-sm font-semibold border-t border-gray-100 pt-2">
            <span>Total</span>
            <span>{formatDZD(o.totalDZD)}</span>
          </div>
        </div>
      )}
    />
  )
}
