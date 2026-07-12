import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { describe, expect, it, vi } from 'vitest'

import Drawer from './Drawer'

describe('Drawer', () => {
  it('stays out of the DOM while closed', () => {
    render(
      <Drawer open={false} onOpenChange={() => undefined} title="Menu">
        nav
      </Drawer>,
    )
    expect(screen.queryByRole('dialog')).not.toBeInTheDocument()
  })

  it('opens as a dialog and closes on Escape', async () => {
    const onOpenChange = vi.fn()
    render(
      <Drawer open onOpenChange={onOpenChange} title="Menu">
        nav
      </Drawer>,
    )

    expect(screen.getByRole('dialog', { name: 'Menu' })).toBeInTheDocument()
    await userEvent.keyboard('{Escape}')
    expect(onOpenChange).toHaveBeenCalledWith(false, expect.anything())
  })
})
