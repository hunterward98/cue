import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { describe, expect, it, vi } from 'vitest'

import ConfirmDialog from './ConfirmDialog'

describe('ConfirmDialog', () => {
  it('confirms through the destructive button', async () => {
    const onConfirm = vi.fn()
    render(
      <ConfirmDialog
        open
        onOpenChange={() => undefined}
        title="Delete this org?"
        confirmLabel="Delete forever"
        onConfirm={onConfirm}
      >
        There is no undo.
      </ConfirmDialog>,
    )

    await userEvent.click(
      screen.getByRole('button', { name: 'Delete forever' }),
    )
    expect(onConfirm).toHaveBeenCalled()
  })

  it('cancels without confirming', async () => {
    const onConfirm = vi.fn()
    const onOpenChange = vi.fn()
    render(
      <ConfirmDialog
        open
        onOpenChange={onOpenChange}
        title="Sure?"
        confirmLabel="Do it"
        onConfirm={onConfirm}
      >
        …
      </ConfirmDialog>,
    )

    await userEvent.click(screen.getByRole('button', { name: 'Cancel' }))
    expect(onOpenChange).toHaveBeenCalledWith(false)
    expect(onConfirm).not.toHaveBeenCalled()
  })

  it('holds the confirm button disabled until the caller says otherwise', () => {
    render(
      <ConfirmDialog
        open
        onOpenChange={() => undefined}
        title="Type the name"
        confirmLabel="Delete"
        onConfirm={() => undefined}
        confirmDisabled
      >
        …
      </ConfirmDialog>,
    )
    expect(screen.getByRole('button', { name: 'Delete' })).toBeDisabled()
  })
})
