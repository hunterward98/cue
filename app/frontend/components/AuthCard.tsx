import { usePage } from '@inertiajs/react'
import type { ReactNode } from 'react'

interface Props {
  title: string
  subtitle?: string
  children: ReactNode
}

// Shell for every signed-out screen: centered card, title, flash
// banners. Colors are plain Tailwind until theming plan_3 lands tokens.
export default function AuthCard({ title, subtitle, children }: Props) {
  const { flash } = usePage()

  return (
    <main className="mx-auto flex min-h-screen w-full max-w-md flex-col justify-center gap-6 px-4 py-10">
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
      <div className="rounded-lg border border-stone-200 bg-white p-6">
        {children}
      </div>
    </main>
  )
}
