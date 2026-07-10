import { render, screen } from '@testing-library/react'
import { describe, expect, it } from 'vitest'

import Full from './full'

const greenChecks = [
  { label: 'Rails', value: '8.1.3', ok: true },
  { label: 'Postgres 18.4', value: 'uuidv7() → 0198-fake', ok: true },
]

describe('health/full', () => {
  it('renders every check with its value when all layers answer', () => {
    render(<Full checks={greenChecks} generated_at="2026-07-09T12:00:00Z" />)

    expect(
      screen.getByRole('heading', { name: 'Cue system health' }),
    ).toBeInTheDocument()
    expect(screen.getByText('Every layer is answering.')).toBeInTheDocument()
    expect(screen.getByText('8.1.3')).toBeInTheDocument()
    expect(screen.getByText('uuidv7() → 0198-fake')).toBeInTheDocument()
    expect(screen.getAllByLabelText('ok')).toHaveLength(2)
    expect(screen.getByText(/2026-07-09T12:00:00Z/)).toBeInTheDocument()
  })

  it('fails loudly when any check reports not-ok', () => {
    render(
      <Full
        checks={[
          ...greenChecks,
          { label: 'Postgres', value: 'PG::ConnectionBad', ok: false },
        ]}
        generated_at="2026-07-09T12:00:00Z"
      />,
    )

    expect(
      screen.getByText('Something is off — details below.'),
    ).toBeInTheDocument()
    expect(screen.getByLabelText('failing')).toHaveTextContent('✗')
    expect(screen.getAllByLabelText('ok')).toHaveLength(2)
  })
})
