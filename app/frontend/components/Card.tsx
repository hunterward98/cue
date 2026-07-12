import type { ReactNode } from 'react'

import { cn } from '@/lib/cn'

interface Props {
  title?: string
  children: ReactNode
  // Layout-only pass-through (docs/design/standards.md).
  className?: string
}

export default function Card({ title, children, className }: Props) {
  return (
    <section
      className={cn(
        'rounded-lg border border-border bg-surface-raised p-6',
        className,
      )}
    >
      {title ? (
        <h2 className="mb-3 font-display text-xl font-semibold text-ink">
          {title}
        </h2>
      ) : null}
      {children}
    </section>
  )
}
