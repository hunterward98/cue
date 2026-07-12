import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { describe, expect, it, vi } from 'vitest'

import Switch from './Switch'

describe('Switch', () => {
  it('exposes switch semantics and flips on click', async () => {
    const onChange = vi.fn()
    render(<Switch label="Join link" checked={false} onChange={onChange} />)

    const control = screen.getByRole('switch', { name: 'Join link' })
    expect(control).toHaveAttribute('aria-checked', 'false')

    await userEvent.click(control)
    expect(onChange).toHaveBeenCalledWith(true)
  })

  it('flips back from checked and can be disabled', async () => {
    const onChange = vi.fn()
    render(<Switch label="Join link" checked disabled onChange={onChange} />)

    const control = screen.getByRole('switch')
    expect(control).toHaveAttribute('aria-checked', 'true')
    await userEvent.click(control)
    expect(onChange).not.toHaveBeenCalled()
  })
})
