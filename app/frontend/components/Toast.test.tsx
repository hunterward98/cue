import { act, fireEvent, render, screen } from '@testing-library/react'
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'

import Button from './Button'
import { ToastProvider, useToast } from './Toast'

function Trigger() {
  const { toast } = useToast()
  return (
    <>
      <Button
        onClick={() => {
          toast('success', 'Link copied.')
        }}
      >
        Copy
      </Button>
      <Button
        onClick={() => {
          toast('danger', 'That did not work.')
        }}
      >
        Break
      </Button>
    </>
  )
}

describe('Toast', () => {
  beforeEach(() => {
    vi.useFakeTimers()
  })

  afterEach(() => {
    vi.useRealTimers()
  })

  it('shows success and danger toasts politely, then dismisses them', () => {
    render(
      <ToastProvider dismissAfterMs={1000}>
        <Trigger />
      </ToastProvider>,
    )

    // fireEvent, not userEvent: userEvent's internal waits fight fake
    // timers; the click itself is synchronous.
    fireEvent.click(screen.getByRole('button', { name: 'Copy' }))
    fireEvent.click(screen.getByRole('button', { name: 'Break' }))

    expect(screen.getByText('Link copied.')).toBeInTheDocument()
    expect(screen.getByText('That did not work.')).toBeInTheDocument()

    act(() => {
      vi.advanceTimersByTime(1500)
    })
    expect(screen.queryByText('Link copied.')).not.toBeInTheDocument()
    expect(screen.queryByText('That did not work.')).not.toBeInTheDocument()
  })

  it('refuses to run outside a provider', () => {
    expect(() => render(<Trigger />)).toThrow(/ToastProvider/)
  })
})
