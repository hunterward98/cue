import { render, screen } from '@testing-library/react'
import { describe, expect, it } from 'vitest'

import Spinner from './Spinner'

describe('Spinner', () => {
  it('announces itself with a default label', () => {
    render(<Spinner />)
    expect(screen.getByRole('status')).toHaveAccessibleName('Loading')
  })

  it('accepts a custom label', () => {
    render(<Spinner label="Saving" />)
    expect(screen.getByRole('status')).toHaveAccessibleName('Saving')
  })
})
