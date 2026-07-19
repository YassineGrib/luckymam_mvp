import { BrowserRouter, Route, Routes } from 'react-router-dom'
import { RequireAdmin } from './features/auth/RequireAdmin'
import { AppShell } from './components/AppShell'
import { PrintOrdersScreen } from './features/orders/PrintOrdersScreen'
import { AlbumClaimsScreen } from './features/orders/AlbumClaimsScreen'
import { MarketplaceOrdersScreen } from './features/orders/MarketplaceOrdersScreen'
import { SettingsScreen } from './features/settings/SettingsScreen'
import { UserManagementScreen } from './features/users/UserManagementScreen'
import { MarketplaceCatalogueScreen } from './features/marketplace/MarketplaceCatalogueScreen'
import { SettingsProvider } from './lib/SettingsContext'

export function App() {
  return (
    <SettingsProvider>
      <RequireAdmin>
        <BrowserRouter>
          <Routes>
            <Route element={<AppShell />}>
              <Route index element={<PrintOrdersScreen />} />
              <Route path="album-claims" element={<AlbumClaimsScreen />} />
              <Route path="marketplace-orders" element={<MarketplaceOrdersScreen />} />
              <Route path="settings" element={<SettingsScreen />} />
              <Route path="users" element={<UserManagementScreen />} />
              <Route path="marketplace-catalog" element={<MarketplaceCatalogueScreen />} />
            </Route>
          </Routes>
        </BrowserRouter>
      </RequireAdmin>
    </SettingsProvider>
  )
}

