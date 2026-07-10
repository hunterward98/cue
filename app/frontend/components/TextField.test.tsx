import { render, screen } from '@testing-library/react'
import { describe, expect, it } from 'vitest'

import TextField from './TextField'

describe('TextField', () => {
  it('labels its input', () => {
    render(<TextField label="Email" name="email" />)
    expect(screen.getByLabelText('Email')).toBeInTheDocument()
  })

  it('shows a single error message and flags the input invalid', () => {
    render(<TextField label="Email" name="email" errors="is bad" />)
    expect(screen.getByRole('alert')).toHaveTextContent('is bad')
    expect(screen.getByLabelText(/Email/)).toHaveAttribute(
      'aria-invalid',
      'true',
    )
  })

  it('joins array errors', () => {
    render(
      <TextField label="Email" name="email" errors={['is bad', 'is worse']} />,
    )
    expect(screen.getByRole('alert')).toHaveTextContent('is bad, is worse')
  })

  it('fails to mark clean inputs invalid', () => {
    render(<TextField label="Email" name="email" />)
    expect(screen.getByLabelText('Email')).not.toHaveAttribute('aria-invalid')
    expect(screen.queryByRole('alert')).not.toBeInTheDocument()
  })
})
