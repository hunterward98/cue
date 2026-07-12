import { render, screen } from '@testing-library/react'
import { beforeEach, describe, expect, it } from 'vitest'

import { mockInertia, resetInertiaMock } from '@/test/inertia-mock'

import OrgHome from './home'

mockInertia()

const props = (owner: boolean, board_owner: boolean) => ({
  organization: { name: 'Acme', slug: 'acme' },
  membership: { owner, board_owner },
})

describe('org/home', () => {
  beforeEach(resetInertiaMock)

  it('shows the org name and the placeholder empty state', () => {
    render(<OrgHome {...props(false, false)} />)
    expect(screen.getByRole('heading', { name: 'Acme' })).toBeInTheDocument()
    expect(screen.getByText(/Nothing to see yet/)).toBeInTheDocument()
    expect(
      screen.queryByRole('link', { name: 'Members' }),
    ).not.toBeInTheDocument()
  })

  it('links owners to member management', () => {
    render(<OrgHome {...props(true, false)} />)
    expect(screen.getByRole('link', { name: 'Members' })).toHaveAttribute(
      'href',
      '/o/acme/members',
    )
  })

  it('describes every role combination', () => {
    const { rerender } = render(<OrgHome {...props(true, true)} />)
    expect(
      screen.getByText('You own this org and run a board.'),
    ).toBeInTheDocument()

    rerender(<OrgHome {...props(true, false)} />)
    expect(screen.getByText('You own this org.')).toBeInTheDocument()

    rerender(<OrgHome {...props(false, true)} />)
    expect(screen.getByText('You run a board here.')).toBeInTheDocument()

    rerender(<OrgHome {...props(false, false)} />)
    expect(screen.getByText('You can raise cues here.')).toBeInTheDocument()
  })
})
