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
    <AppShell title={organization.name} subtitle={roleLine(membership)}>
      <div className="rounded-lg border border-dashed border-stone-300 bg-white p-6 text-sm text-stone-600">
        <p>
          Nothing to see yet. When cues land, this is where they&apos;ll queue
          up — patiently.
        </p>
      </div>
    </AppShell>
  )
}
