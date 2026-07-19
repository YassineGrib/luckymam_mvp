import { BrowserRouter, Route, Routes } from 'react-router-dom'
import { RequireAdmin } from './features/auth/RequireAdmin'
import { AppShell } from './components/AppShell'
import { PrintOrdersScreen } from './features/orders/PrintOrdersScreen'
import { AlbumClaimsScreen } from './features/orders/AlbumClaimsScreen'
import { MarketplaceOrdersScreen } from './features/orders/MarketplaceOrdersScreen'

export function App() {
  return (
    <RequireAdmin>
      <BrowserRouter>
        <Routes>
          <Route element={<AppShell />}>
            <Route index element={<PrintOrdersScreen />} />
            <Route path="album-claims" element={<AlbumClaimsScreen />} />
            <Route path="marketplace-orders" element={<MarketplaceOrdersScreen />} />
          </Route>
        </Routes>
      </BrowserRouter>
    </RequireAdmin>
  )
}
