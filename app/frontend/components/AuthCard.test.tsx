import { render, screen } from '@testing-library/react'
import { beforeEach, describe, expect, it } from 'vitest'

import { mockInertia, pageFlash, resetInertiaMock } from '@/test/inertia-mock'

import AuthCard from './AuthCard'

mockInertia()

describe('AuthCard', () => {
  beforeEach(resetInertiaMock)

  it('renders title, subtitle, and children', () => {
    render(
      <AuthCard title="Sign in" subtitle="Welcome back">
        <p>form goes here</p>
      </AuthCard>,
    )

    expect(screen.getByRole('heading', { name: 'Sign in' })).toBeInTheDocument()
    expect(screen.getByText('Welcome back')).toBeInTheDocument()
    expect(screen.getByText('form goes here')).toBeInTheDocument()
  })

  it('renders flash notice and alert banners when present', () => {
    pageFlash.notice = 'All good'
    pageFlash.alert = 'All bad'

    render(
      <AuthCard title="t">
        <span />
      </AuthCard>,
    )

    expect(screen.getByRole('status')).toHaveTextContent('All good')
    expect(screen.getByRole('alert')).toHaveTextContent('All bad')
  })

  it('fails to render banners or subtitle when absent', () => {
    render(
      <AuthCard title="t">
        <span />
      </AuthCard>,
    )

    expect(screen.queryByRole('status')).not.toBeInTheDocument()
    expect(screen.queryByRole('alert')).not.toBeInTheDocument()
  })
})
