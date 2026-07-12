import { render, screen } from '@testing-library/react'
import { describe, expect, it } from 'vitest'

import Badge from './Badge'

describe('Badge', () => {
  it('defaults to neutral', () => {
    render(<Badge>Pending</Badge>)
    expect(screen.getByText('Pending')).toHaveClass('bg-surface')
  })

  it('wears each coding hue', () => {
    render(
      <>
        <Badge variant="scarlet">P1</Badge>
        <Badge variant="ochre">P2</Badge>
        <Badge variant="moss">P3</Badge>
        <Badge variant="teal">T</Badge>
        <Badge variant="indigo">I</Badge>
        <Badge variant="plum">Pl</Badge>
      </>,
    )
    expect(screen.getByText('P1')).toHaveClass('bg-coding-scarlet-surface')
    expect(screen.getByText('Pl')).toHaveClass('bg-coding-plum-surface')
  })
})
