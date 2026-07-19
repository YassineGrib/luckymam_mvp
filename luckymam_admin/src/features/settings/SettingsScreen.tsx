import { useSettings, type AccentColor } from '../../lib/SettingsContext'
import { Globe, Palette, Moon, Sun, Check, Laptop } from 'lucide-react'

export function SettingsScreen() {
  const { theme, setTheme, language, setLanguage, accentColor, setAccentColor } = useSettings()

  const t = {
    fr: {
      title: 'Paramètres du Portail',
      subtitle: 'Personnalisez la langue et l\'apparence de votre tableau de bord.',
      languageTitle: 'Langue du système',
      languageDesc: 'Sélectionnez la langue d\'affichage des menus et formulaires.',
      appearanceTitle: 'Mode d\'affichage',
      appearanceDesc: 'Basculez entre le mode clair et le mode sombre.',
      accentTitle: 'Couleur d\'accentuation',
      accentDesc: 'Choisissez la couleur principale pour les boutons, liens et focus.',
      lightMode: 'Mode Clair',
      darkMode: 'Mode Sombre',
      french: 'Français (FR)',
      english: 'English (EN)',
      accentMagenta: 'Magenta Pink',
      accentCoral: 'Coral Primary',
      accentBlue: 'Smalt Blue',
      saveNotice: 'Les préférences sont enregistrées automatiquement.',
    },
    en: {
      title: 'Portal Settings',
      subtitle: 'Customize the language and appearance of your dashboard.',
      languageTitle: 'System Language',
      languageDesc: 'Select the display language for menus and forms.',
      appearanceTitle: 'Appearance Mode',
      appearanceDesc: 'Toggle between light and dark themes.',
      accentTitle: 'Accent Color',
      accentDesc: 'Choose the primary color highlight for buttons, links, and focus states.',
      lightMode: 'Light Mode',
      darkMode: 'Dark Mode',
      french: 'French (FR)',
      english: 'English (EN)',
      accentMagenta: 'Magenta Pink',
      accentCoral: 'Coral Primary',
      accentBlue: 'Smalt Blue',
      saveNotice: 'Preferences are saved automatically.',
    },
  }[language]

  return (
    <div className="min-h-screen bg-theme-bg text-theme-text p-8 md:p-10 flex justify-center transition-colors duration-200">
      <div className="w-full max-w-2xl space-y-8">
        <div>
          <h1 className="text-2xl font-extrabold tracking-tight">{t.title}</h1>
          <p className="text-xs text-theme-muted mt-1.5 font-medium">{t.subtitle}</p>
        </div>

        <div className="space-y-6">
          {/* 1. Language Preferences */}
          <div className="bg-theme-card border border-theme-border rounded-3xl p-6 md:p-8 shadow-sm space-y-4 transition-colors duration-200">
            <div className="flex items-start gap-3.5">
              <div className="h-9 w-9 rounded-xl bg-brand-accent-light flex items-center justify-center text-brand-accent border border-brand-accent/20">
                <Globe className="h-4.5 w-4.5" />
              </div>
              <div>
                <h2 className="text-sm font-extrabold tracking-tight">{t.languageTitle}</h2>
                <p className="text-[11px] text-theme-muted mt-0.5">{t.languageDesc}</p>
              </div>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 pt-2">
              <button
                onClick={() => setLanguage('fr')}
                className={`flex items-center justify-between rounded-2xl border px-4 py-3.5 text-xs font-bold transition-all duration-200 cursor-pointer ${
                  language === 'fr'
                    ? 'border-brand-accent bg-brand-accent-light text-brand-accent'
                    : 'border-theme-border bg-theme-bg/50 hover:bg-theme-bg/85 text-theme-text'
                }`}
              >
                <span>{t.french}</span>
                {language === 'fr' && <Check className="h-4 w-4 shrink-0 text-brand-accent" />}
              </button>
              
              <button
                onClick={() => setLanguage('en')}
                className={`flex items-center justify-between rounded-2xl border px-4 py-3.5 text-xs font-bold transition-all duration-200 cursor-pointer ${
                  language === 'en'
                    ? 'border-brand-accent bg-brand-accent-light text-brand-accent'
                    : 'border-theme-border bg-theme-bg/50 hover:bg-theme-bg/85 text-theme-text'
                }`}
              >
                <span>{t.english}</span>
                {language === 'en' && <Check className="h-4 w-4 shrink-0 text-brand-accent" />}
              </button>
            </div>
          </div>

          {/* 2. Theme Customizer */}
          <div className="bg-theme-card border border-theme-border rounded-3xl p-6 md:p-8 shadow-sm space-y-4 transition-colors duration-200">
            <div className="flex items-start gap-3.5">
              <div className="h-9 w-9 rounded-xl bg-brand-accent-light flex items-center justify-center text-brand-accent border border-brand-accent/20">
                <Laptop className="h-4.5 w-4.5" />
              </div>
              <div>
                <h2 className="text-sm font-extrabold tracking-tight">{t.appearanceTitle}</h2>
                <p className="text-[11px] text-theme-muted mt-0.5">{t.appearanceDesc}</p>
              </div>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 pt-2">
              <button
                onClick={() => setTheme('light')}
                className={`flex items-center gap-3.5 rounded-2xl border px-5 py-4 text-xs font-bold transition-all duration-200 cursor-pointer group ${
                  theme === 'light'
                    ? 'border-brand-accent bg-brand-accent-light text-brand-accent'
                    : 'border-theme-border bg-theme-bg/50 hover:bg-theme-bg/85 text-theme-text'
                }`}
              >
                <div className={`h-8 w-8 rounded-lg flex items-center justify-center transition-colors ${
                  theme === 'light' ? 'bg-brand-accent/15 text-brand-accent' : 'bg-slate-100 dark:bg-slate-800 text-theme-muted'
                }`}>
                  <Sun className="h-4 w-4" />
                </div>
                <div className="text-left">
                  <span className="block font-bold">{t.lightMode}</span>
                </div>
                {theme === 'light' && <Check className="ml-auto h-4 w-4 shrink-0 text-brand-accent" />}
              </button>
              
              <button
                onClick={() => setTheme('dark')}
                className={`flex items-center gap-3.5 rounded-2xl border px-5 py-4 text-xs font-bold transition-all duration-200 cursor-pointer group ${
                  theme === 'dark'
                    ? 'border-brand-accent bg-brand-accent-light text-brand-accent'
                    : 'border-theme-border bg-theme-bg/50 hover:bg-theme-bg/85 text-theme-text'
                }`}
              >
                <div className={`h-8 w-8 rounded-lg flex items-center justify-center transition-colors ${
                  theme === 'dark' ? 'bg-brand-accent/15 text-brand-accent' : 'bg-slate-100 dark:bg-slate-800 text-theme-muted'
                }`}>
                  <Moon className="h-4 w-4" />
                </div>
                <div className="text-left">
                  <span className="block font-bold">{t.darkMode}</span>
                </div>
                {theme === 'dark' && <Check className="ml-auto h-4 w-4 shrink-0 text-brand-accent" />}
              </button>
            </div>
          </div>

          {/* 3. Accent Color Customizer */}
          <div className="bg-theme-card border border-theme-border rounded-3xl p-6 md:p-8 shadow-sm space-y-4 transition-colors duration-200">
            <div className="flex items-start gap-3.5">
              <div className="h-9 w-9 rounded-xl bg-brand-accent-light flex items-center justify-center text-brand-accent border border-brand-accent/20">
                <Palette className="h-4.5 w-4.5" />
              </div>
              <div>
                <h2 className="text-sm font-extrabold tracking-tight">{t.accentTitle}</h2>
                <p className="text-[11px] text-theme-muted mt-0.5">{t.accentDesc}</p>
              </div>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-3 gap-3 pt-2">
              <AccentButton
                color="magenta"
                label={t.accentMagenta}
                hex="#A7316E"
                active={accentColor === 'magenta'}
                onClick={() => setAccentColor('magenta')}
              />
              <AccentButton
                color="coral"
                label={t.accentCoral}
                hex="#E85A71"
                active={accentColor === 'coral'}
                onClick={() => setAccentColor('coral')}
              />
              <AccentButton
                color="blue"
                label={t.accentBlue}
                hex="#4F8289"
                active={accentColor === 'blue'}
                onClick={() => setAccentColor('blue')}
              />
            </div>
          </div>
        </div>

        <p className="text-center text-[10px] text-theme-muted font-medium mt-4">
          {t.saveNotice}
        </p>
      </div>
    </div>
  )
}

function AccentButton({
  label,
  hex,
  active,
  onClick,
}: {
  color: AccentColor
  label: string
  hex: string
  active: boolean
  onClick: () => void
}) {
  return (
    <button
      onClick={onClick}
      className={`flex items-center gap-3 rounded-2xl border px-4 py-3.5 text-xs font-bold transition-all duration-200 cursor-pointer ${
        active
          ? 'border-brand-accent bg-brand-accent-light text-brand-accent'
          : 'border-theme-border bg-theme-bg/50 hover:bg-theme-bg/85 text-theme-text'
      }`}
    >
      <span
        className="h-3.5 w-3.5 rounded-full shrink-0 shadow-sm border border-black/5"
        style={{ backgroundColor: hex }}
      />
      <span className="truncate">{label}</span>
      {active && <Check className="ml-auto h-4 w-4 shrink-0 text-brand-accent" />}
    </button>
  )
}
