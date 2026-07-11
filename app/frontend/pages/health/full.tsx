interface HealthCheck {
  label: string
  value: string
  ok: boolean
}

interface Props {
  checks: HealthCheck[]
  generated_at: string
}

// Colors here are plain Tailwind utilities for now; theming plan_3 owns the
// token system and will retrofit this page when tokens exist.
export default function Full({ checks, generated_at }: Props) {
  const allOk = checks.every((check) => check.ok)

  return (
    <main className="mx-auto flex min-h-screen max-w-xl flex-col justify-center gap-6 px-4 py-10">
      <h1 className="text-2xl font-semibold tracking-tight text-ink">
        Cue system health
      </h1>
      <p className={allOk ? 'text-success-ink' : 'text-destructive'}>
        {allOk
          ? 'Every layer is answering.'
          : 'Something is off — details below.'}
      </p>
      <ul className="divide-y divide-border rounded-lg border border-border bg-surface-raised">
        {checks.map((check) => (
          <li
            key={check.label}
            className="flex items-baseline justify-between gap-4 p-3"
          >
            <span className="shrink-0 font-medium text-ink">{check.label}</span>
            <span className="min-w-0 break-all text-right text-sm text-ink-muted">
              {check.value}
            </span>
            <span
              aria-label={check.ok ? 'ok' : 'failing'}
              className={check.ok ? 'text-success-ink' : 'text-destructive'}
            >
              {check.ok ? '✓' : '✗'}
            </span>
          </li>
        ))}
      </ul>
      <p className="text-xs text-ink-muted">
        Rendered through Rails → Inertia → React → Tailwind at {generated_at}.
        Normal people call this a status page; you can too.
      </p>
    </main>
  )
}
