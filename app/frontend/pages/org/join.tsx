import { router } from '@inertiajs/react'

import AuthCard from '@/components/AuthCard'
import Button from '@/components/Button'

interface Props {
  organization: {
    name: string
    slug: string
  }
  status: 'none' | 'pending_approval' | 'deactivated'
}

export default function JoinOrganization({ organization, status }: Props) {
  if (status === 'pending_approval') {
    return (
      <AuthCard title={`Request sent to ${organization.name}`}>
        <p className="text-sm text-ink-muted">
          An owner will review it. You&apos;ll have access as soon as they
          approve.
        </p>
      </AuthCard>
    )
  }

  if (status === 'deactivated') {
    return (
      <AuthCard title="You're not currently a member">
        <p className="text-sm text-ink-muted">
          Contact an owner at {organization.name} to be added back.
        </p>
      </AuthCard>
    )
  }

  return (
    <AuthCard
      title={`Join ${organization.name}`}
      subtitle="An owner will need to approve your request before you can see anything here."
    >
      <Button
        onClick={() => {
          router.post(`/join/${organization.slug}`)
        }}
      >
        Request to join
      </Button>
    </AuthCard>
  )
}
