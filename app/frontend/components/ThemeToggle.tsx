import { router, usePage } from '@inertiajs/react'
import { useState } from 'react'

import {
  applyTheme,
  isThemePreference,
  type ThemePreference,
} from '@/lib/theme'

const NEXT: Record<ThemePreference, ThemePreference> = {
  system: 'light',
  light: 'dark',
  dark: 'system',
}

// Cycles system → light → dark. Applies instantly, remembers on the
// device (pre-login screens), and persists to the account.
export default function ThemeToggle() {
  const { theme } = usePage().props
  const [preference, setPreference] = useState<ThemePreference>(
    isThemePreference(theme) ? theme : 'system',
  )

  const cycle = () => {
    const next = NEXT[preference]
    setPreference(next)
    applyTheme(next)
    localStorage.setItem('cue-theme', next)
    router.patch(
      '/theme_preference',
      { theme: next },
      { preserveState: true, preserveScroll: true },
    )
  }

  return (
    <button
      type="button"
      onClick={cycle}
      className="text-xs text-ink-muted hover:text-ink focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-focus"
    >
      Theme: {preference}
    </button>
  )
}
