import { Dialog } from '@base-ui/react/dialog'
import type { ReactNode } from 'react'

// Base UI owns focus trap / escape / aria (ADR 0014); we own the skin.
// Product code renders Modal, never Dialog directly.
interface Props {
  open: boolean
  onOpenChange: (open: boolean) => void
  title: string
  children: ReactNode
}

export default function Modal({ open, onOpenChange, title, children }: Props) {
  return (
    <Dialog.Root open={open} onOpenChange={onOpenChange}>
      <Dialog.Portal>
        <Dialog.Backdrop className="fixed inset-0 bg-ink opacity-30" />
        <Dialog.Popup className="fixed top-1/2 left-1/2 w-full max-w-md -translate-x-1/2 -translate-y-1/2 rounded-lg border border-border bg-surface-raised p-6">
          <Dialog.Title className="mb-3 font-display text-xl font-semibold text-ink">
            {title}
          </Dialog.Title>
          {children}
        </Dialog.Popup>
      </Dialog.Portal>
    </Dialog.Root>
  )
}
