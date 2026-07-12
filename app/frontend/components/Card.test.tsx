import { render, screen } from '@testing-library/react'
import { describe, expect, it } from 'vitest'

import Card from './Card'

describe('Card', () => {
  it('renders children with an optional title', () => {
    render(<Card title="Members">body</Card>)
    expect(screen.getByRole('heading', { name: 'Members' })).toBeInTheDocument()
    expect(screen.getByText('body')).toBeInTheDocument()
  })

  it('skips the heading when untitled and accepts layout classes', () => {
    render(<Card className="mt-4">just body</Card>)
    expect(screen.queryByRole('heading')).not.toBeInTheDocument()
    expect(screen.getByText('just body').closest('section')).toHaveClass('mt-4')
  })
})
