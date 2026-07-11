import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'

import {
  mockInertia,
  pageProps,
  resetInertiaMock,
  submitSpy,
} from '@/test/inertia-mock'

import ThemeToggle from './ThemeToggle'

mockInertia()

describe('ThemeToggle', () => {
  beforeEach(() => {
    resetInertiaMock()
    vi.stubGlobal('matchMedia', vi.fn().mockReturnValue({ matches: false }))
  })

  afterEach(() => {
    vi.unstubAllGlobals()
    localStorage.clear()
    delete document.documentElement.dataset.theme
  })

  it('starts from the account preference when one is shared', () => {
    pageProps.theme = 'dark'
    render(<ThemeToggle />)
    expect(
      screen.getByRole('button', { name: 'Theme: dark' }),
    ).toBeInTheDocument()
  })

  it('falls back to system for junk or missing preferences', () => {
    pageProps.theme = 'mauve'
    render(<ThemeToggle />)
    expect(
      screen.getByRole('button', { name: 'Theme: system' }),
    ).toBeInTheDocument()
  })

  it('cycles system → light → dark → system, applying and persisting each hop', async () => {
    render(<ThemeToggle />)
    const button = screen.getByRole('button', { name: 'Theme: system' })

    await userEvent.click(button)
    expect(button).toHaveAccessibleName('Theme: light')
    expect(document.documentElement.dataset.theme).toBe('light')
    expect(localStorage.getItem('cue-theme')).toBe('light')
    expect(submitSpy).toHaveBeenCalledWith('patch', '/theme_preference', {
      theme: 'light',
    })

    await userEvent.click(button)
    expect(button).toHaveAccessibleName('Theme: dark')
    expect(document.documentElement.dataset.theme).toBe('dark')

    await userEvent.click(button)
    expect(button).toHaveAccessibleName('Theme: system')
    expect(document.documentElement.dataset.theme).toBe('light') // OS says light
  })
})
