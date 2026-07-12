import { render, screen } from '@testing-library/react'
import { describe, expect, it } from 'vitest'

import EmptyState from './EmptyState'

describe('EmptyState', () => {
  it('renders title and copy', () => {
    render(<EmptyState title="No cues yet">They will come.</EmptyState>)
    expect(
      screen.getByRole('heading', { name: 'No cues yet' }),
    ).toBeInTheDocument()
    expect(screen.getByText('They will come.')).toBeInTheDocument()
  })

  it('renders optional illustration and action slots', () => {
    render(
      <EmptyState
        title="t"
        illustration={<svg data-testid="art" />}
        action={<button type="button">Make one</button>}
      >
        copy
      </EmptyState>,
    )
    expect(screen.getByTestId('art')).toBeInTheDocument()
    expect(screen.getByRole('button', { name: 'Make one' })).toBeInTheDocument()
  })
})
