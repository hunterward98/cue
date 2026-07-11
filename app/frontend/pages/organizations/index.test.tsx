import { render, screen } from '@testing-library/react'
import { beforeEach, describe, expect, it } from 'vitest'

import { mockInertia, resetInertiaMock } from '@/test/inertia-mock'

import OrganizationsIndex from './index'

mockInertia()

const row = (
  overrides: Partial<
    Parameters<typeof OrganizationsIndex>[0]['organizations'][number]
  >,
) => ({
  name: 'Acme',
  slug: 'acme',
  owner: false,
  board_owner: false,
  ...overrides,
})

describe('organizations/index', () => {
  beforeEach(resetInertiaMock)

  it('shows the empty state when the user belongs nowhere', () => {
    render(<OrganizationsIndex organizations={[]} />)
    expect(
      screen.getByText(/don't belong to any organization yet/),
    ).toBeInTheDocument()
  })

  it('links each org to its home', () => {
    render(<OrganizationsIndex organizations={[row({})]} />)
    expect(screen.getByRole('link', { name: /Acme/ })).toHaveAttribute(
      'href',
      '/o/acme',
    )
  })

  it('labels every role combination', () => {
    render(
      <OrganizationsIndex
        organizations={[
          row({ slug: 'a', name: 'A', owner: true, board_owner: true }),
          row({ slug: 'b', name: 'B', owner: true }),
          row({ slug: 'c', name: 'C', board_owner: true }),
          row({ slug: 'd', name: 'D' }),
        ]}
      />,
    )

    expect(screen.getByText('Owner · Board owner')).toBeInTheDocument()
    expect(screen.getByText('Owner')).toBeInTheDocument()
    expect(screen.getByText('Board owner')).toBeInTheDocument()
    expect(screen.getByText('Requester')).toBeInTheDocument()
  })

  it('always offers the create door', () => {
    render(<OrganizationsIndex organizations={[]} />)
    expect(
      screen.getByRole('link', { name: 'New organization' }),
    ).toHaveAttribute('href', '/organizations/new')
  })
})
