import { router } from '@inertiajs/react'

import AuthCard from '@/components/AuthCard'
import Button from '@/components/Button'

interface SessionItem {
  id: string
  current: boolean
  ip_address: string | null
  user_agent: string | null
  last_active_at: string
}

interface Props {
  sessions: SessionItem[]
}

export default function SessionsIndex({ sessions }: Props) {
  return (
    <AuthCard
      title="Your sessions"
      subtitle="Every device signed in as you. Evict anything you don't recognize."
    >
      <ul className="divide-y divide-border">
        {sessions.map((session) => (
          <li
            key={session.id}
            className="flex items-center justify-between gap-4 py-3"
          >
            <div className="min-w-0 text-sm">
              <p className="font-medium text-ink">
                {session.user_agent ?? 'Unknown device'}
                {session.current ? ' — this device' : ''}
              </p>
              <p className="text-ink-muted">
                {session.ip_address ?? 'unknown address'} · active{' '}
                {session.last_active_at}
              </p>
            </div>
            <Button
              variant="ghost"
              onClick={() => {
                router.delete(`/sessions/${session.id}`)
              }}
            >
              {session.current ? 'Sign out' : 'Revoke'}
            </Button>
          </li>
        ))}
      </ul>
    </AuthCard>
  )
}
