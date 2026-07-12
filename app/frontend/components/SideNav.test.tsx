import { render, screen } from '@testing-library/react'
import { beforeEach, describe, expect, it } from 'vitest'

import { mockInertia, resetInertiaMock } from '@/test/inertia-mock'

import SideNav from './SideNav'

mockInertia()

const items = [
  { label: 'Profile', href: '/o/acme/settings', current: true },
  { label: 'Members', href: '/o/acme/settings/members' },
]

describe('SideNav', () => {
  beforeEach(resetInertiaMock)

  it('marks the current item for assistive tech', () => {
    render(<SideNav label="Settings" items={items} />)

    const current = screen.getAllByRole('link', { name: 'Profile' })
    expect(current.length).toBeGreaterThan(0)
    for (const link of current) {
      expect(link).toHaveAttribute('aria-current', 'page')
    }
    for (const link of screen.getAllByRole('link', { name: 'Members' })) {
      expect(link).not.toHaveAttribute('aria-current')
    }
  })

  it('offers the accordion summary for mobile', () => {
    render(<SideNav label="Settings" items={items} />)
    expect(screen.getByText('Settings', { selector: 'summary' })).toBeVisible()
  })
})
