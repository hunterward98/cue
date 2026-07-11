import { usePage } from '@inertiajs/react'
import type { ReactNode } from 'react'

interface Props {
  title: string
  subtitle?: string
  children: ReactNode
}

// Shell for every signed-out screen: centered card, title, flash banners.
export default function AuthCard({ title, subtitle, children }: Props) {
  const { flash } = usePage()

  return (
    <main className="mx-auto flex min-h-screen w-full max-w-md flex-col justify-center gap-6 px-4 py-10">
      <header className="flex flex-col gap-1">
        <h1 className="font-display text-3xl font-semibold tracking-tight text-ink">
          {title}
        </h1>
        {subtitle ? <p className="text-sm text-ink-muted">{subtitle}</p> : null}
      </header>
      {flash.notice ? (
        <p
          role="status"
          className="rounded-md border border-success-ink/25 bg-success-surface p-3 text-sm text-success-ink"
        >
          {flash.notice}
        </p>
      ) : null}
      {flash.alert ? (
        <p
          role="alert"
          className="rounded-md border border-danger-ink/25 bg-danger-surface p-3 text-sm text-danger-ink"
        >
          {flash.alert}
        </p>
      ) : null}
      <div className="rounded-lg border border-border bg-surface-raised p-6">
        {children}
      </div>
    </main>
  )
}
