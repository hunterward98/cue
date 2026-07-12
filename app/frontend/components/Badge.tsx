import type { ReactNode } from 'react'

import { cn } from '@/lib/cn'

// neutral for states/labels; the coding hues are the color-coding set
// (docs/design/standards.md) — priorities, statuses, board identity.
export type BadgeVariant =
  'neutral' | 'scarlet' | 'ochre' | 'moss' | 'teal' | 'indigo' | 'plum'

interface Props {
  variant?: BadgeVariant
  children: ReactNode
}

const VARIANTS: Record<BadgeVariant, string> = {
  neutral: 'bg-surface text-ink-muted border border-border',
  scarlet: 'bg-coding-scarlet-surface text-coding-scarlet-ink',
  ochre: 'bg-coding-ochre-surface text-coding-ochre-ink',
  moss: 'bg-coding-moss-surface text-coding-moss-ink',
  teal: 'bg-coding-teal-surface text-coding-teal-ink',
  indigo: 'bg-coding-indigo-surface text-coding-indigo-ink',
  plum: 'bg-coding-plum-surface text-coding-plum-ink',
}

export default function Badge({ variant = 'neutral', children }: Props) {
  return (
    <span
      className={cn(
        'inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium',
        VARIANTS[variant],
      )}
    >
      {children}
    </span>
  )
}
