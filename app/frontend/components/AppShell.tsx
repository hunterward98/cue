import { Link, usePage } from '@inertiajs/react'
import type { ReactNode } from 'react'

import PageHeader from '@/components/PageHeader'
import ThemeToggle from '@/components/ThemeToggle'
import Wordmark from '@/components/Wordmark'

interface Props {
  title: string
  subtitle?: string | undefined
  actions?: ReactNode
  children: ReactNode
}

// Shell for signed-in screens: wordmark, page header, flash banners.
export default function AppShell({
  title,
  subtitle,
  actions,
  children,
}: Props) {
  const { flash } = usePage()

  return (
    <main className="mx-auto flex min-h-screen w-full max-w-3xl flex-col gap-6 px-4 py-8">
      <div className="flex items-center justify-between">
        <Link href="/organizations" aria-label="Cue home">
          <Wordmark />
        </Link>
        <ThemeToggle />
      </div>
      <PageHeader title={title} subtitle={subtitle} actions={actions} />
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
