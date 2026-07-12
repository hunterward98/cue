import type { ReactNode } from 'react'

interface Props {
  title: string
  // On-voice copy slot — see docs/design/voice.md once plan_5 lands.
  children: ReactNode
  // Illustration slot (kept small and content-free per the ratified
  // charcoal-texturing rule).
  illustration?: ReactNode
  action?: ReactNode
}

export default function EmptyState({
  title,
  children,
  illustration,
  action,
}: Props) {
  return (
    <div className="flex flex-col items-center gap-3 rounded-lg border border-dashed border-border bg-surface-raised p-8 text-center">
      {illustration}
      <h2 className="font-display text-xl font-semibold text-ink">{title}</h2>
      <div className="text-sm text-ink-muted">{children}</div>
      {action}
    </div>
  )
}
