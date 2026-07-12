import type { ButtonHTMLAttributes } from 'react'

import { cn } from '@/lib/cn'

type Variant = 'primary' | 'secondary' | 'destructive' | 'ghost'

interface Props extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: Variant
}

const VARIANTS: Record<Variant, string> = {
  primary: 'bg-accent text-accent-ink hover:bg-accent-hover',
  secondary:
    'border border-border-strong bg-surface-raised text-ink hover:border-ink',
  // Red means "gone" — reserve for actions that destroy something.
  destructive: 'bg-destructive text-destructive-ink hover:bg-destructive-hover',
  ghost: 'text-ink-muted underline-offset-2 hover:underline',
}

export default function Button({ variant = 'primary', ...button }: Props) {
  return (
    <button
      type="button"
      className={cn(
        'rounded-md px-4 py-2 text-sm font-medium focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-focus disabled:opacity-50',
        VARIANTS[variant],
      )}
      {...button}
    />
  )
}
