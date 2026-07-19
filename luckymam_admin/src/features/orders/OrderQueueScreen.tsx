import { useMemo, useState, type ReactNode } from 'react'
import { useOrderQueue } from './useOrderQueue'
import { updateOrderStatus } from './updateOrderStatus'
import { StatusBadge } from './StatusBadge'
import { STATUS_LABELS_FR, STATUS_COLORS } from '../../lib/enums'
import type { BaseOrder } from '../../lib/orderTypes'
import { auth } from '../../lib/firebase'
import { useSettings } from '../../lib/SettingsContext'
import { 
  Phone, 
  MapPin, 
  Map, 
  Clock, 
  Check, 
  Inbox, 
  User, 
  Search, 
  ArrowUpDown, 
  TrendingUp,
  PanelLeftClose,
  PanelLeftOpen
} from 'lucide-react'

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
  const { language } = useSettings()
  const [statusFilter, setStatusFilter] = useState<string | null>(null)
  const [searchQuery, setSearchQuery] = useState('')
  const [sortAscending, setSortAscending] = useState(false) // false = newest first, true = oldest first
  const [selectedId, setSelectedId] = useState<string | null>(null)
  const [updating, setUpdating] = useState(false)
  const [isLeftPanelCollapsed, setIsLeftPanelCollapsed] = useState(false)

  // Translations
  const t = {
    fr: {
      filteredOrders: 'commandes filtrées',
      filteredOrder: 'commande filtrée',
      total: 'Total',
      searchPlaceholder: 'Rechercher nom, tel, adresse...',
      loading: 'Chargement des commandes…',
      error: 'Erreur lors du chargement',
      noOrders: 'Aucune commande trouvée',
      noOrdersDesc: 'Aucun élément ne correspond aux filtres.',
      deliveryInfo: 'Informations de livraison',
      phone: 'Téléphone',
      wilaya: 'Wilaya',
      address: 'Adresse complète',
      itemsTitle: 'Détails des articles',
      statusActionTitle: 'Traitement du statut',
      auditLabel: 'Statut mis à jour le',
      auditBy: 'par',
      auditYou: 'Vous',
      auditAdmin: 'Admin',
      emptyDashboardTitle: 'Vue d\'ensemble',
      emptyDashboardSubtitle: 'Sélectionnez un élément pour le traiter ou consultez les statistiques ci-dessous.',
      cardTotal: 'Total Commandes',
      cardPending: 'En attente',
      cardProcessing: 'En cours',
      cardCompleted: 'Livrées / Terminées',
      dashboardTip: 'Conseil de traitement',
      dashboardTipDesc: 'Utilisez le bouton de tri chronologique (trier par le plus ancien) pour traiter les commandes dans l\'ordre de leur soumission.',
      showList: 'Afficher la liste',
      filterAll: 'Toutes',
    },
    en: {
      filteredOrders: 'filtered orders',
      filteredOrder: 'filtered order',
      total: 'Total',
      searchPlaceholder: 'Search name, phone, address...',
      loading: 'Loading orders...',
      error: 'Error loading orders',
      noOrders: 'No orders found',
      noOrdersDesc: 'No items match the current filters.',
      deliveryInfo: 'Delivery Information',
      phone: 'Phone',
      wilaya: 'Wilaya',
      address: 'Full Address',
      itemsTitle: 'Item Details',
      statusActionTitle: 'Status Management',
      auditLabel: 'Status updated on',
      auditBy: 'by',
      auditYou: 'You',
      auditAdmin: 'Admin',
      emptyDashboardTitle: 'Overview Dashboard',
      emptyDashboardSubtitle: 'Select a item to process or view statistics below.',
      cardTotal: 'Total Orders',
      cardPending: 'Pending',
      cardProcessing: 'Processing',
      cardCompleted: 'Delivered / Completed',
      dashboardTip: 'Processing Tip',
      dashboardTipDesc: 'Use the chronological sorting button (sort by oldest) to process orders in the order they were submitted.',
      showList: 'Show List',
      filterAll: 'All',
    }
  }[language]

  // 1. Filter by status and search query
  const searchedAndFiltered = useMemo(() => {
    let result = orders
    if (statusFilter) {
      result = result.filter((o) => o.status === statusFilter)
    }
    if (searchQuery.trim()) {
      const q = searchQuery.toLowerCase().trim()
      result = result.filter(
        (o) =>
          o.fullName.toLowerCase().includes(q) ||
          o.phone.toLowerCase().includes(q) ||
          o.address.toLowerCase().includes(q) ||
          o.id.toLowerCase().includes(q) ||
          summaryLine(o).toLowerCase().includes(q),
      )
    }
    return result
  }, [orders, statusFilter, searchQuery, summaryLine])

  // 2. Sort chronologically
  const sorted = useMemo(() => {
    const result = [...searchedAndFiltered]
    result.sort((a, b) => {
      const timeA = new Date(a.createdAt).getTime()
      const timeB = new Date(b.createdAt).getTime()
      return sortAscending ? timeA - timeB : timeB - timeA
    })
    return result
  }, [searchedAndFiltered, sortAscending])

  const selected = sorted.find((o) => o.id === selectedId) ?? sorted[0] ?? null

  // Calculate status counts for the stats dashboard overview
  const stats = useMemo(() => {
    const total = orders.length
    const pending = orders.filter((o) => o.status === 'pending').length
    const processing = orders.filter((o) => o.status === 'processing' || o.status === 'confirmed').length
    const shipped = orders.filter((o) => o.status === 'shipped').length
    const completed = orders.filter((o) => o.status === 'delivered').length
    return { total, pending, processing, shipped, completed }
  }, [orders])

  const getStatusCount = (status: string | null) => {
    if (status === null) return orders.length
    return orders.filter((o) => o.status === status).length
  }

  async function handleStatusChange(newStatus: string) {
    if (!selected) return
    setUpdating(true)
    try {
      await updateOrderStatus(collectionName, selected.id, newStatus)
    } finally {
      setUpdating(false)
    }
  }

  // Format the status update audit log timestamp
  const auditDateString = useMemo(() => {
    if (!selected?.statusUpdatedAt?.seconds) return null
    const date = new Date(selected.statusUpdatedAt.seconds * 1000)
    return date.toLocaleString(language === 'fr' ? 'fr-FR' : 'en-US', {
      day: 'numeric',
      month: 'short',
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
    })
  }, [selected?.statusUpdatedAt, language])

  const auditAdminName = useMemo(() => {
    if (!selected?.statusUpdatedBy) return null
    return selected.statusUpdatedBy === auth.currentUser?.uid
      ? t.auditYou
      : `${t.auditAdmin} (${selected.statusUpdatedBy.slice(0, 6)})`
  }, [selected?.statusUpdatedBy, t])

  return (
    <div className="flex h-screen overflow-hidden bg-theme-bg text-theme-text transition-colors duration-200">
      <div 
        className={`shrink-0 border-r border-theme-border bg-theme-card flex flex-col shadow-sm transition-all duration-300 ${
          isLeftPanelCollapsed ? 'w-0 overflow-hidden border-r-0' : 'w-96'
        }`}
      >
        {/* Title Header */}
        <div className="px-6 py-5 border-b border-theme-border flex items-center justify-between">
          <div>
            <h1 className="text-base font-extrabold text-theme-text tracking-tight">{title}</h1>
            <p className="text-xs text-theme-muted font-medium mt-0.5">
              {sorted.length} {sorted.length > 1 ? t.filteredOrders : t.filteredOrder}
            </p>
          </div>
          <div className="flex items-center gap-2">
            <span className="inline-flex items-center rounded-full bg-slate-100 dark:bg-slate-800 px-2.5 py-0.5 text-xs font-bold text-theme-muted">
              {t.total} {orders.length}
            </span>
            <button
              onClick={() => setIsLeftPanelCollapsed(true)}
              className="p-1.5 rounded-lg hover:bg-slate-100 dark:hover:bg-slate-800 text-theme-muted hover:text-theme-text transition-colors cursor-pointer"
            >
              <PanelLeftClose className="h-4.5 w-4.5" />
            </button>
          </div>
        </div>

        {/* Filters */}
        <div className="px-5 py-3.5 flex flex-wrap gap-2 border-b border-theme-border bg-theme-bg/30">
          <FilterChip
            label={t.filterAll}
            active={statusFilter === null}
            count={getStatusCount(null)}
            status={null}
            onClick={() => setStatusFilter(null)}
          />
          {statuses.map((s) => (
            <FilterChip
              key={s}
              label={STATUS_LABELS_FR[s] ?? s}
              active={statusFilter === s}
              count={getStatusCount(s)}
              status={s}
              onClick={() => setStatusFilter(s)}
            />
          ))}
        </div>

        {/* Search and Sort Toolbar */}
        <div className="px-5 py-3 flex gap-2 border-b border-theme-border bg-theme-card items-center">
          <div className="relative flex-1">
            <Search className="absolute left-3 top-2.5 h-4 w-4 text-theme-muted" />
            <input
              type="text"
              placeholder={t.searchPlaceholder}
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full rounded-xl border border-theme-border bg-theme-bg/50 pl-9 pr-3 py-2 text-xs text-theme-text placeholder-slate-400 outline-none focus:border-brand-accent focus:bg-theme-card transition-all duration-150"
            />
          </div>
          <button
            onClick={() => setSortAscending((prev) => !prev)}
            title={sortAscending ? 'Trier par plus récent' : 'Trier par plus ancien'}
            className={`p-2 rounded-xl border flex items-center justify-center transition-all cursor-pointer ${
              sortAscending 
                ? 'bg-brand-accent-light border-brand-accent/30 text-brand-accent' 
                : 'bg-theme-card border-theme-border text-theme-muted hover:bg-slate-100 dark:hover:bg-slate-800'
            }`}
          >
            <ArrowUpDown className="h-4 w-4" />
          </button>
        </div>

        {/* List Content */}
        <div className="flex-1 overflow-y-auto divide-y divide-theme-border px-3 py-3 space-y-1 bg-theme-bg/10">
          {loading && (
            <div className="p-8 text-center">
              <div className="inline-block h-5 w-5 animate-spin rounded-full border-2 border-brand-accent border-t-transparent mb-2"></div>
              <p className="text-xs text-theme-muted font-medium">{t.loading}</p>
            </div>
          )}
          {error && (
            <div className="p-6 text-center bg-red-50/50 dark:bg-red-950/20 rounded-2xl m-3 border border-red-100 dark:border-red-900/30">
              <p className="text-xs font-semibold text-red-700 dark:text-red-400">{t.error}</p>
              <p className="text-[11px] text-red-600 dark:text-red-500 mt-1">{error}</p>
            </div>
          )}
          {!loading && sorted.length === 0 && (
            <div className="p-12 text-center">
              <Inbox className="h-8 w-8 text-theme-muted mx-auto mb-2.5" />
              <p className="text-xs text-theme-text font-semibold">{t.noOrders}</p>
              <p className="text-[10px] text-theme-muted mt-0.5">{t.noOrdersDesc}</p>
            </div>
          )}
          
          {sorted.map((order) => {
            const isSelected = selected?.id === order.id
            return (
              <button
                key={order.id}
                onClick={() => setSelectedId(order.id)}
                className={`w-full text-left rounded-2xl px-4 py-3.5 transition-all duration-200 cursor-pointer border relative group ${
                  isSelected 
                    ? 'bg-brand-accent-light border-brand-accent/20 shadow-sm' 
                    : 'bg-theme-card border-transparent hover:bg-slate-100 dark:hover:bg-slate-800/40 hover:border-theme-border'
                }`}
              >
                {/* Active Indicator Strip */}
                {isSelected && (
                  <div className="absolute left-0 top-3.5 bottom-3.5 w-1 rounded-r bg-brand-accent" />
                )}
                
                <div className="flex items-start justify-between gap-3 mb-1">
                  <span className="text-sm font-bold text-theme-text truncate">
                    {order.fullName}
                  </span>
                  <StatusBadge status={order.status} />
                </div>
                
                <p className="text-xs text-theme-muted font-medium truncate mb-2">{summaryLine(order)}</p>
                
                <div className="flex items-center gap-1.5 text-[10px] text-theme-muted font-medium">
                  <Clock className="h-3 w-3 shrink-0" />
                  <span>
                    {new Date(order.createdAt).toLocaleDateString(language === 'fr' ? 'fr-FR' : 'en-US', {
                      day: 'numeric',
                      month: 'short',
                      hour: '2-digit',
                      minute: '2-digit',
                    })}
                  </span>
                </div>
              </button>
            )
          })}
        </div>
      </div>

      {/* Detail / Dashboard Pane */}
      <div className="flex-1 overflow-y-auto bg-theme-bg/60 p-8 md:p-10 flex flex-col items-center">
        {/* Collapse floating toggle button when collapsed */}
        {isLeftPanelCollapsed && (
          <div className="w-full max-w-2xl mb-4 flex justify-start">
            <button
              onClick={() => setIsLeftPanelCollapsed(false)}
              className="flex items-center gap-1.5 rounded-xl border border-theme-border bg-theme-card px-3.5 py-2 text-xs font-bold text-theme-text hover:bg-slate-100 dark:hover:bg-slate-800 transition-all shadow-sm cursor-pointer"
            >
              <PanelLeftOpen className="h-4.5 w-4.5 text-brand-accent" />
              <span>{t.showList}</span>
            </button>
          </div>
        )}

        {!selected ? (
          /* Empty state: Visual Stats Dashboard Overview */
          <div className="w-full max-w-3xl my-auto space-y-8 py-10">
            <div className="text-center">
              <TrendingUp className="h-10 w-10 text-brand-accent mx-auto mb-3" />
              <h2 className="text-xl font-extrabold text-theme-text tracking-tight">{t.emptyDashboardTitle} — {title}</h2>
              <p className="text-xs text-theme-muted mt-1">{t.emptyDashboardSubtitle}</p>
            </div>

            {/* Dashboard metrics grid */}
            <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
              <DashboardCard label={t.cardTotal} value={stats.total} color="var(--color-theme-text)" />
              <DashboardCard label={t.cardPending} value={stats.pending} color={STATUS_COLORS.pending} />
              <DashboardCard label={t.cardProcessing} value={stats.processing} color={STATUS_COLORS.processing} />
              <DashboardCard label={t.cardCompleted} value={stats.completed} color={STATUS_COLORS.delivered} />
            </div>
            
            <div className="bg-theme-card rounded-3xl p-6 border border-theme-border text-center shadow-sm">
              <p className="text-xs text-theme-text font-bold">{t.dashboardTip}</p>
              <p className="text-[11px] text-theme-muted mt-1 max-w-md mx-auto">
                {t.dashboardTipDesc}
              </p>
            </div>
          </div>
        ) : (
          /* Detail panel */
          <div className="w-full max-w-2xl bg-theme-card border border-theme-border shadow-sm rounded-3xl p-6 md:p-8">
            {/* Header info */}
            <div className="flex flex-wrap items-center justify-between gap-4 border-b border-theme-border pb-5 mb-6">
              <div className="flex items-center gap-3">
                <div className="h-10 w-10 rounded-xl bg-brand-accent-light flex items-center justify-center text-brand-accent border border-brand-accent/20">
                  <User className="h-5 w-5" />
                </div>
                <div>
                  <h2 className="text-lg font-extrabold text-theme-text tracking-tight">{selected.fullName}</h2>
                  <p className="text-[10px] text-theme-muted font-mono">ID: {selected.id}</p>
                </div>
              </div>
              <StatusBadge status={selected.status} />
            </div>

            {/* General Metadata */}
            <h3 className="text-xs font-bold uppercase tracking-wider text-theme-muted mb-3">{t.deliveryInfo}</h3>
            <div className="bg-theme-bg border border-theme-border rounded-2xl p-5 mb-6 space-y-4">
              <dl className="grid grid-cols-1 sm:grid-cols-2 gap-4 text-xs font-semibold">
                <Row icon={Phone} label={t.phone} value={selected.phone} />
                <Row icon={Map} label={t.wilaya} value={selected.wilaya} />
                <div className="sm:col-span-2">
                  <Row icon={MapPin} label={t.address} value={selected.address} />
                </div>
              </dl>
            </div>

            {/* Type Specific details */}
            <h3 className="text-xs font-bold uppercase tracking-wider text-theme-muted mb-3">{t.itemsTitle}</h3>
            <div className="bg-theme-card border border-theme-border rounded-2xl p-5 mb-8 shadow-sm">
              {renderDetails(selected)}
            </div>

            {/* Actions workflow */}
            <div className="border-t border-theme-border pt-6">
              <p className="text-xs font-bold uppercase tracking-wider text-theme-muted mb-3 flex items-center gap-1.5">
                <span>{t.statusActionTitle}</span>
                {updating && (
                  <span className="h-3.5 w-3.5 animate-spin rounded-full border-2 border-brand-accent border-t-transparent" />
                )}
              </p>
              
              <div className="flex flex-wrap gap-2 mb-6">
                {statuses.map((s) => {
                  const isActive = s === selected.status
                  return (
                    <button
                      key={s}
                      disabled={updating || isActive}
                      onClick={() => handleStatusChange(s)}
                      className={`flex items-center gap-1.5 rounded-xl border px-4 py-2 text-xs font-semibold transition-all duration-200 cursor-pointer ${
                        isActive
                          ? 'bg-slate-100 dark:bg-slate-800 border-theme-border text-slate-400 dark:text-slate-500'
                          : 'bg-theme-card border-theme-border text-theme-text hover:bg-slate-50 dark:hover:bg-slate-800 hover:-translate-y-[1px] active:scale-[0.98] disabled:opacity-40 disabled:pointer-events-none'
                      }`}
                    >
                      {isActive && <Check className="h-3.5 w-3.5 shrink-0 text-emerald-600 dark:text-emerald-500" />}
                      <span>{STATUS_LABELS_FR[s] ?? s}</span>
                    </button>
                  )
                })}
              </div>

              {/* Status Audit logs */}
              {auditDateString && auditAdminName && (
                <div className="bg-theme-bg border border-theme-border rounded-2xl p-4 flex items-start gap-2.5 text-theme-muted">
                  <Clock className="h-4 w-4 shrink-0 text-theme-muted mt-0.5" />
                  <div className="text-[11px] font-semibold">
                    <span>{t.auditLabel} </span>
                    <span className="text-theme-text">{auditDateString}</span>
                    <span> {t.auditBy} </span>
                    <span className="text-brand-accent">{auditAdminName}</span>
                  </div>
                </div>
              )}
            </div>
          </div>
        )}
      </div>
    </div>
  )
}

function Row({ 
  icon: Icon, 
  label, 
  value 
}: { 
  icon: any, 
  label: string, 
  value: ReactNode 
}) {
  return (
    <div className="flex flex-col gap-1">
      <dt className="text-theme-muted flex items-center gap-1.5">
        <Icon className="h-3.5 w-3.5 shrink-0 text-theme-muted" />
        <span>{label}</span>
      </dt>
      <dd className="text-theme-text font-bold">{value}</dd>
    </div>
  )
}

function FilterChip({
  label,
  active,
  count,
  status,
  onClick,
}: {
  label: string
  active: boolean
  count: number
  status: string | null
  onClick: () => void
}) {
  const color = status ? (STATUS_COLORS[status] ?? '#64748B') : 'var(--color-brand-accent)'

  return (
    <button
      onClick={onClick}
      className={`rounded-full px-3.5 py-1.5 text-xs font-bold transition-all duration-200 hover:-translate-y-[0.5px] active:scale-[0.98] cursor-pointer flex items-center gap-2 border ${
        active
          ? 'shadow-sm'
          : 'bg-theme-card border-theme-border text-theme-muted hover:bg-slate-50 dark:hover:bg-slate-800'
      }`}
      style={
        active
          ? {
              backgroundColor: `${color}1A`,
              color: color,
              borderColor: `${color}40`,
            }
          : undefined
      }
    >
      <span>{label}</span>
      <span
        className={`inline-flex items-center justify-center rounded-full px-1.5 py-0.5 text-[9px] font-extrabold leading-none transition-colors duration-200 ${
          active
            ? 'text-white'
            : 'bg-slate-100 dark:bg-slate-800 text-theme-muted'
        }`}
        style={active ? { backgroundColor: color } : undefined}
      >
        {count}
      </span>
    </button>
  )
}

function DashboardCard({ 
  label, 
  value, 
  color 
}: { 
  label: string
  value: number
  color: string 
}) {
  return (
    <div 
      className="bg-theme-card border border-theme-border rounded-3xl p-5 shadow-sm transition-transform duration-200 hover:-translate-y-0.5"
    >
      <p className="text-[10px] font-bold uppercase tracking-wider text-theme-muted">{label}</p>
      <p 
        className="text-3xl font-extrabold mt-2 leading-none"
        style={{ color }}
      >
        {value}
      </p>
    </div>
  )
}
