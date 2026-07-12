import { Dialog } from '@base-ui/react/dialog'
import type { ReactNode } from 'react'

// The mobile nav pattern: a left-sliding panel on Base UI's dialog
// machinery (focus trap, escape, backdrop dismissal — ADR 0014).
interface Props {
  open: boolean
  onOpenChange: (open: boolean) => void
  title: string
  children: ReactNode
}

export default function Drawer({ open, onOpenChange, title, children }: Props) {
  return (
    <Dialog.Root open={open} onOpenChange={onOpenChange}>
      <Dialog.Portal>
        <Dialog.Backdrop className="fixed inset-0 bg-ink opacity-30" />
        <Dialog.Popup className="fixed inset-y-0 left-0 w-72 max-w-[80vw] border-r border-border bg-surface-raised p-4">
          <Dialog.Title className="mb-3 font-display text-lg font-semibold text-ink">
            {title}
          </Dialog.Title>
          {children}
        </Dialog.Popup>
      </Dialog.Portal>
    </Dialog.Root>
  )
}
