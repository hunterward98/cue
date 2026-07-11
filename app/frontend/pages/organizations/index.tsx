import { Link } from '@inertiajs/react'

import AppShell from '@/components/AppShell'

interface OrganizationRow {
  name: string
  slug: string
  owner: boolean
  board_owner: boolean
}

interface Props {
  organizations: OrganizationRow[]
}

function roleLabel(row: OrganizationRow): string {
  if (row.owner && row.board_owner) return 'Owner · Board owner'
  if (row.owner) return 'Owner'
  if (row.board_owner) return 'Board owner'
  return 'Requester'
}

export default function OrganizationsIndex({ organizations }: Props) {
  return (
    <AppShell
      title="Your organizations"
      subtitle="Pick a workspace. Most people only need the one."
    >
      {organizations.length === 0 ? (
        <div className="rounded-lg border border-border bg-surface-raised p-6 text-sm text-ink-muted">
          <p>
            You don&apos;t belong to any organization yet. Create one, or ask
            whoever runs yours for an invitation.
          </p>
        </div>
      ) : (
        <ul className="flex flex-col gap-2">
          {organizations.map((organization) => (
            <li key={organization.slug}>
              <Link
                href={`/o/${organization.slug}`}
                className="flex items-baseline justify-between rounded-lg border border-border bg-surface-raised p-4 hover:border-border-strong"
              >
                <span className="font-medium text-ink">
                  {organization.name}
                </span>
                <span className="text-xs text-ink-muted">
                  {roleLabel(organization)}
                </span>
              </Link>
            </li>
          ))}
        </ul>
      )}
      <p>
        <Link
          href="/organizations/new"
          className="text-sm text-ink-muted underline underline-offset-2"
        >
          New organization
        </Link>
      </p>
    </AppShell>
  )
}
