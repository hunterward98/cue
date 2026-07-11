import { Link, usePage } from '@inertiajs/react'
import type { ReactNode } from 'react'

import ThemeToggle from '@/components/ThemeToggle'

interface Props {
  title: string
  subtitle?: string
  children: ReactNode
}

// Shell for signed-in screens: wordmark, title, flash banners. The real
// chrome (nav, org switcher menu) arrives with theming plan_3.
export default function AppShell({ title, subtitle, children }: Props) {
  const { flash } = usePage()

  return (
    <main className="mx-auto flex min-h-screen w-full max-w-3xl flex-col gap-6 px-4 py-8">
      <div className="flex items-center justify-between">
        <Link
          href="/organizations"
          className="font-display text-lg font-semibold italic tracking-tight text-ink"
        >
          Cue
        </Link>
        <ThemeToggle />
      </div>
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
      {children}
    </main>
  )
}
