import { render, screen } from '@testing-library/react'
import { describe, expect, it } from 'vitest'

import Wordmark from './Wordmark'

describe('Wordmark', () => {
  it('is an accessible image reading "Cue"', () => {
    render(<Wordmark />)
    expect(screen.getByRole('img', { name: 'Cue' })).toBeInTheDocument()
  })

  it('scales from the size prop', () => {
    render(<Wordmark size={40} />)
    const mark = screen.getByRole('img', { name: 'Cue' })
    expect(mark).toHaveAttribute('height', '40')
    expect(mark).toHaveAttribute('width', '100')
  })
})
