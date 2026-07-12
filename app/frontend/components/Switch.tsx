import { useId } from 'react'

import { cn } from '@/lib/cn'

interface Props {
  label: string
  checked: boolean
  onChange: (checked: boolean) => void
  disabled?: boolean
}

// A real switch (role, aria-checked, space/enter via button semantics),
// hand-rolled — this one isn't hard enough for Base UI (ADR 0014). The
// label is a plain <span> wired via aria-labelledby, not a wrapping
// <label>: "labelable" HTML elements don't include role="switch"
// buttons, so wrapping wouldn't reliably announce in every AT.
export default function Switch({ label, checked, onChange, disabled }: Props) {
  const labelId = useId()
  return (
    <span className="flex items-center gap-2 text-sm text-ink">
      <button
        type="button"
        role="switch"
        aria-checked={checked}
        aria-labelledby={labelId}
        disabled={disabled}
        onClick={() => {
          onChange(!checked)
        }}
        className={cn(
          'relative h-5 w-9 rounded-full transition-colors focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-focus disabled:opacity-50',
          checked ? 'bg-accent' : 'bg-border-strong',
        )}
      >
        <span
          className={cn(
            'absolute top-0.5 size-4 rounded-full bg-surface-raised transition-transform',
            checked ? 'translate-x-4.5' : 'translate-x-0.5',
          )}
        />
      </button>
      <span id={labelId}>{label}</span>
    </span>
  )
}
