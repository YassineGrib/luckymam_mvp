import { createContext, useContext, useEffect, useState, type ReactNode } from 'react'

export type Theme = 'light' | 'dark'
export type Language = 'fr' | 'en'
export type AccentColor = 'magenta' | 'coral' | 'blue'

interface SettingsContextType {
  theme: Theme
  setTheme: (theme: Theme) => void
  language: Language
  setLanguage: (lang: Language) => void
  accentColor: AccentColor
  setAccentColor: (color: AccentColor) => void
}

const SettingsContext = createContext<SettingsContextType | undefined>(undefined)

const ACCENT_MAP = {
  magenta: {
    primary: '#A7316E',
    hover: '#8E255B',
    light: 'rgba(167, 49, 110, 0.08)',
  },
  coral: {
    primary: '#E85A71',
    hover: '#D6465D',
    light: 'rgba(232, 90, 113, 0.08)',
  },
  blue: {
    primary: '#4F8289',
    hover: '#406D73',
    light: 'rgba(79, 130, 137, 0.08)',
  },
}

export function SettingsProvider({ children }: { children: ReactNode }) {
  const [theme, setThemeState] = useState<Theme>(() => {
    const saved = localStorage.getItem('lm-theme')
    return (saved as Theme) || 'light'
  })
  
  const [language, setLanguageState] = useState<Language>(() => {
    const saved = localStorage.getItem('lm-lang')
    return (saved as Language) || 'fr'
  })

  const [accentColor, setAccentColorState] = useState<AccentColor>(() => {
    const saved = localStorage.getItem('lm-accent')
    return (saved as AccentColor) || 'magenta'
  })

  useEffect(() => {
    localStorage.setItem('lm-theme', theme)
    const root = document.documentElement
    if (theme === 'dark') {
      root.classList.add('dark')
      root.style.setProperty('--color-theme-bg', '#090D16')
      root.style.setProperty('--color-theme-card', '#111827')
      root.style.setProperty('--color-theme-border', '#1F2937')
      root.style.setProperty('--color-theme-text', '#F3F4F6')
      root.style.setProperty('--color-theme-muted', '#9CA3AF')
    } else {
      root.classList.remove('dark')
      root.style.setProperty('--color-theme-bg', '#F8FAFC')
      root.style.setProperty('--color-theme-card', '#FFFFFF')
      root.style.setProperty('--color-theme-border', '#F1F5F9')
      root.style.setProperty('--color-theme-text', '#0F172A')
      root.style.setProperty('--color-theme-muted', '#64748B')
    }
  }, [theme])

  useEffect(() => {
    localStorage.setItem('lm-lang', language)
  }, [language])

  useEffect(() => {
    localStorage.setItem('lm-accent', accentColor)
    const colors = ACCENT_MAP[accentColor]
    const root = document.documentElement
    root.style.setProperty('--color-brand-accent', colors.primary)
    root.style.setProperty('--color-brand-accent-hover', colors.hover)
    root.style.setProperty('--color-brand-accent-light', colors.light)
  }, [accentColor])

  function setTheme(t: Theme) {
    setThemeState(t)
  }

  function setLanguage(l: Language) {
    setLanguageState(l)
  }

  function setAccentColor(a: AccentColor) {
    setAccentColorState(a)
  }

  return (
    <SettingsContext.Provider value={{ theme, setTheme, language, setLanguage, accentColor, setAccentColor }}>
      {children}
    </SettingsContext.Provider>
  )
}

export function useSettings() {
  const context = useContext(SettingsContext)
  if (!context) {
    throw new Error('useSettings must be used within a SettingsProvider')
  }
  return context
}
