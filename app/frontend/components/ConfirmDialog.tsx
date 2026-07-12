import type { ReactNode } from 'react'

import Button from '@/components/Button'
import Modal from '@/components/Modal'

// Destructive confirmations are dead serious — no snark in here, ever
// (voice rule). The destructive variant is the default because that's
// what confirmations are for.
interface Props {
  open: boolean
  onOpenChange: (open: boolean) => void
  title: string
  confirmLabel: string
  onConfirm: () => void
  confirmDisabled?: boolean
  children: ReactNode
}

export default function ConfirmDialog({
  open,
  onOpenChange,
  title,
  confirmLabel,
  onConfirm,
  confirmDisabled,
  children,
}: Props) {
  return (
    <Modal open={open} onOpenChange={onOpenChange} title={title}>
      <div className="flex flex-col gap-4">
        <div className="text-sm text-ink-muted">{children}</div>
        <div className="flex justify-end gap-2">
          <Button
            variant="ghost"
            onClick={() => {
              onOpenChange(false)
            }}
          >
            Cancel
          </Button>
          <Button
            variant="destructive"
            disabled={confirmDisabled}
            onClick={onConfirm}
          >
            {confirmLabel}
          </Button>
        </div>
      </div>
    </Modal>
  )
}
