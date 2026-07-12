import { render, screen } from '@testing-library/react'
import { describe, expect, it } from 'vitest'

import PageHeader from './PageHeader'

describe('PageHeader', () => {
  it('renders title, subtitle, and actions', () => {
    render(
      <PageHeader
        title="Members"
        subtitle="Everyone in the org"
        actions={<button type="button">Invite</button>}
      />,
    )
    expect(screen.getByRole('heading', { name: 'Members' })).toBeInTheDocument()
    expect(screen.getByText('Everyone in the org')).toBeInTheDocument()
    expect(screen.getByRole('button', { name: 'Invite' })).toBeInTheDocument()
  })

  it('renders bare titles without empty slots', () => {
    render(<PageHeader title="Members" />)
    expect(screen.queryByRole('button')).not.toBeInTheDocument()
  })
})
