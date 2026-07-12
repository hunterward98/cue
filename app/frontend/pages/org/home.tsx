import { Link } from '@inertiajs/react'

import AppShell from '@/components/AppShell'

interface Props {
  organization: {
    name: string
    slug: string
  }
  membership: {
    owner: boolean
    board_owner: boolean
  }
}

function roleLine({ owner, board_owner }: Props['membership']): string {
  if (owner && board_owner) return 'You own this org and run a board.'
  if (owner) return 'You own this org.'
  if (board_owner) return 'You run a board here.'
  return 'You can raise cues here.'
}

// Placeholder landing surface until cues land (org plan_2 proves the
// tenancy wiring end-to-end; cues plan_2 replaces the empty state).
export default function OrgHome({ organization, membership }: Props) {
  return (
    <AppShell
      title={organization.name}
      subtitle={roleLine(membership)}
      actions={
        membership.owner ? (
          <Link
            href={`/o/${organization.slug}/members`}
            className="rounded-md border border-border-strong bg-surface-raised px-4 py-2 text-sm font-medium text-ink hover:border-ink focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-focus"
          >
            Members
          </Link>
        ) : undefined
      }
    >
      <div className="rounded-lg border border-dashed border-border bg-surface-raised p-6 text-sm text-ink-muted">
        <p>
          Nothing to see yet. When cues land, this is where they&apos;ll queue
          up — patiently.
        </p>
      </div>
    </AppShell>
  )
}
