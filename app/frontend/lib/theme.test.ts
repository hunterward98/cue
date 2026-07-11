import { afterEach, describe, expect, it, vi } from 'vitest'

import { applyTheme, isThemePreference } from './theme'

function stubSystemDark(matches: boolean) {
  vi.stubGlobal('matchMedia', vi.fn().mockReturnValue({ matches }))
}

describe('isThemePreference', () => {
  it('accepts the three preferences and rejects everything else', () => {
    expect(isThemePreference('system')).toBe(true)
    expect(isThemePreference('light')).toBe(true)
    expect(isThemePreference('dark')).toBe(true)
    expect(isThemePreference('papyrus')).toBe(false)
    expect(isThemePreference(null)).toBe(false)
  })
})

describe('applyTheme', () => {
  afterEach(() => {
    vi.unstubAllGlobals()
    delete document.documentElement.dataset.theme
  })

  it('stamps explicit preferences directly', () => {
    stubSystemDark(true)
    applyTheme('light')
    expect(document.documentElement.dataset.theme).toBe('light')

    applyTheme('dark')
    expect(document.documentElement.dataset.theme).toBe('dark')
  })

  it('resolves system through the OS preference', () => {
    stubSystemDark(true)
    applyTheme('system')
    expect(document.documentElement.dataset.theme).toBe('dark')

    stubSystemDark(false)
    applyTheme('system')
    expect(document.documentElement.dataset.theme).toBe('light')
  })
})
