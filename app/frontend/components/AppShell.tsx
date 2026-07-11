import { Link, usePage } from '@inertiajs/react'
import type { ReactNode } from 'react'

interface Props {
  title: string
  subtitle?: string
  children: ReactNode
}

// Shell for signed-in screens: wordmark, title, flash banners. The real
// chrome (nav, org switcher menu) arrives with theming plan_3; colors are
// plain Tailwind until the token system lands.
export default function AppShell({ title, subtitle, children }: Props) {
  const { flash } = usePage()

  return (
    <main className="mx-auto flex min-h-screen w-full max-w-3xl flex-col gap-6 px-4 py-8">
      <Link
        href="/organizations"
        className="text-sm font-semibold tracking-tight text-stone-900"
      >
        Cue
      </Link>
      <header className="flex flex-col gap-1">
        <h1 className="text-2xl font-semibold tracking-tight text-stone-900">
          {title}
        </h1>
        {subtitle ? <p className="text-sm text-stone-600">{subtitle}</p> : null}
      </header>
      {flash.notice ? (
        <p
          role="status"
          className="rounded-md border border-green-200 bg-green-50 p-3 text-sm text-green-800"
        >
          {flash.notice}
        </p>
      ) : null}
      {flash.alert ? (
        <p
          role="alert"
          className="rounded-md border border-red-200 bg-red-50 p-3 text-sm text-red-800"
        >
          {flash.alert}
        </p>
      ) : null}
      {children}
    </main>
  )
}
