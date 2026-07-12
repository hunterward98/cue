import { router } from '@inertiajs/react'

import AuthCard from '@/components/AuthCard'
import Button from '@/components/Button'

interface Props {
  organization_name: string
  current_email: string
  invited_email: string
  token: string
}

export default function SwitchAccount({
  organization_name,
  current_email,
  invited_email,
  token,
}: Props) {
  return (
    <AuthCard
      title="Wrong account?"
      subtitle={`This invitation to ${organization_name} was sent to ${invited_email}, but you're signed in as ${current_email}.`}
    >
      <div className="flex flex-col gap-4">
        <p className="text-sm text-ink-muted">
          Sign out to continue as {invited_email}, or ask whoever invited you to
          send it to {current_email} instead.
        </p>
        <Button
          onClick={() => {
            router.delete(`/invitations/${token}/session`)
          }}
        >
          Sign out and continue
        </Button>
      </div>
    </AuthCard>
  )
}
