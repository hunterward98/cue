import { render, screen } from '@testing-library/react'
import { beforeEach, describe, expect, it } from 'vitest'

import { mockInertia, pageFlash, resetInertiaMock } from '@/test/inertia-mock'

import AppShell from './AppShell'

mockInertia()

describe('AppShell', () => {
  beforeEach(resetInertiaMock)

  it('renders the wordmark link, title, subtitle, and children', () => {
    render(
      <AppShell title="Your organizations" subtitle="Pick one">
        <p>content</p>
      </AppShell>,
    )

    expect(screen.getByRole('link', { name: 'Cue home' })).toHaveAttribute(
      'href',
      '/organizations',
    )
    expect(
      screen.getByRole('heading', { name: 'Your organizations' }),
    ).toBeInTheDocument()
    expect(screen.getByText('Pick one')).toBeInTheDocument()
    expect(screen.getByText('content')).toBeInTheDocument()
  })

  it('renders flash banners when present', () => {
    pageFlash.notice = 'Saved'
    pageFlash.alert = 'Nope'

    render(
      <AppShell title="t">
        <span />
      </AppShell>,
    )

    expect(screen.getByRole('status')).toHaveTextContent('Saved')
    expect(screen.getByRole('alert')).toHaveTextContent('Nope')
  })

  it('fails to render banners or subtitle when absent', () => {
    render(
      <AppShell title="t">
        <span />
      </AppShell>,
    )

    expect(screen.queryByRole('status')).not.toBeInTheDocument()
    expect(screen.queryByRole('alert')).not.toBeInTheDocument()
  })
})
