import { render, screen } from '@testing-library/react'
import { describe, expect, it } from 'vitest'

import Button from './Button'

describe('Button', () => {
  it('renders the primary variant by default', () => {
    render(<Button>Go</Button>)
    expect(screen.getByRole('button', { name: 'Go' })).toHaveClass('bg-accent')
  })

  it('renders the ghost variant', () => {
    render(<Button variant="ghost">Never mind</Button>)
    expect(screen.getByRole('button', { name: 'Never mind' })).not.toHaveClass(
      'bg-accent',
    )
  })
})
