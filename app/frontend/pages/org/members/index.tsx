import { router, useForm } from '@inertiajs/react'

import AppShell from '@/components/AppShell'
import Badge from '@/components/Badge'
import Button from '@/components/Button'
import Card from '@/components/Card'
import Checkbox from '@/components/Checkbox'
import EmptyState from '@/components/EmptyState'
import TextField from '@/components/TextField'

interface Member {
  id: string
  email: string
  state: 'active' | 'pending_approval' | 'deactivated'
  owner: boolean
  board_owner: boolean
  is_you: boolean
}

interface PendingInvitation {
  id: string
  email: string
  owner: boolean
  board_owner: boolean
  invited_by: string
  expires_at: string
  live: boolean
}

interface Props {
  org_slug: string
  members: Member[]
  invitations: PendingInvitation[]
  seat_limit: number | null
  board_owner_limit: number | null
}

function roleLabel(member: Pick<Member, 'owner' | 'board_owner'>): string {
  if (member.owner && member.board_owner) return 'Owner, board owner'
  if (member.owner) return 'Owner'
  if (member.board_owner) return 'Board owner'
  return 'Requester'
}

function seatSummary(
  reservedSeats: number,
  seatLimit: number | null,
  boardOwnerLimit: number | null,
): string | undefined {
  if (seatLimit == null) return undefined

  const boardOwnerNote =
    boardOwnerLimit == null
      ? ''
      : ` · ${String(boardOwnerLimit)} board owners allowed`
  return `${String(reservedSeats)} of ${String(seatLimit)} seats used or reserved${boardOwnerNote}`
}

function InviteForm({ orgSlug }: { orgSlug: string }) {
  const form = useForm({
    email: '',
    owner: false,
    board_owner: false,
  })

  return (
    <Card title="Invite someone">
      <form
        onSubmit={(event) => {
          event.preventDefault()
          form.post(`/o/${orgSlug}/invitations`, {
            onSuccess: () => {
              form.reset()
            },
          })
        }}
        className="flex flex-col gap-4"
      >
        <TextField
          label="Email"
          name="email"
          type="email"
          required
          value={form.data.email}
          onChange={(e) => {
            form.setData('email', e.target.value)
          }}
        />
        <div className="flex gap-4">
          <Checkbox
            label="Owner"
            checked={form.data.owner}
            onChange={(e) => {
              form.setData('owner', e.target.checked)
            }}
          />
          <Checkbox
            label="Board owner"
            checked={form.data.board_owner}
            onChange={(e) => {
              form.setData('board_owner', e.target.checked)
            }}
          />
        </div>
        <div>
          <Button type="submit" disabled={form.processing}>
            Send invitation
          </Button>
        </div>
      </form>
    </Card>
  )
}

function InvitationsSection({
  orgSlug,
  invitations,
}: {
  orgSlug: string
  invitations: PendingInvitation[]
}) {
  if (invitations.length === 0) return null

  return (
    <Card title="Pending invitations">
      <ul className="flex flex-col gap-3">
        {invitations.map((invitation) => (
          <li
            key={invitation.id}
            className="flex flex-wrap items-center justify-between gap-2 border-b border-border pb-3 last:border-0 last:pb-0"
          >
            <div className="text-sm">
              <p className="font-medium text-ink">
                {invitation.email}{' '}
                <span className="text-ink-muted">
                  ({roleLabel(invitation)})
                </span>
              </p>
              <p className="text-xs text-ink-muted">
                Invited by {invitation.invited_by}
                {invitation.live ? '' : ' — expired'}
              </p>
            </div>
            <div className="flex gap-2">
              <Button
                variant="ghost"
                onClick={() => {
                  router.post(
                    `/o/${orgSlug}/invitations/${invitation.id}/resend`,
                  )
                }}
              >
                Resend
              </Button>
              <Button
                variant="ghost"
                onClick={() => {
                  router.delete(`/o/${orgSlug}/invitations/${invitation.id}`)
                }}
              >
                Revoke
              </Button>
            </div>
          </li>
        ))}
      </ul>
    </Card>
  )
}

function JoinRequestsSection({
  orgSlug,
  requests,
}: {
  orgSlug: string
  requests: Member[]
}) {
  if (requests.length === 0) return null

  return (
    <Card title="Join requests">
      <ul className="flex flex-col gap-3">
        {requests.map((request) => (
          <li
            key={request.id}
            className="flex flex-wrap items-center justify-between gap-2 border-b border-border pb-3 last:border-0 last:pb-0"
          >
            <p className="text-sm font-medium text-ink">{request.email}</p>
            <div className="flex gap-2">
              <Button
                onClick={() => {
                  router.patch(`/o/${orgSlug}/members/${request.id}/activate`)
                }}
              >
                Approve
              </Button>
              <Button
                variant="ghost"
                onClick={() => {
                  router.delete(`/o/${orgSlug}/members/${request.id}`)
                }}
              >
                Deny
              </Button>
            </div>
          </li>
        ))}
      </ul>
    </Card>
  )
}

function RosterSection({
  orgSlug,
  members,
}: {
  orgSlug: string
  members: Member[]
}) {
  if (members.length === 0) {
    return <EmptyState title="No members yet">Invite someone above.</EmptyState>
  }

  return (
    <Card title="Members">
      <ul className="flex flex-col gap-3">
        {members.map((member) => (
          <li
            key={member.id}
            className="flex flex-wrap items-center justify-between gap-3 border-b border-border pb-3 last:border-0 last:pb-0"
          >
            <div className="flex min-w-0 flex-col gap-1">
              <p className="text-sm font-medium text-ink">
                {member.email}
                {member.is_you ? ' (you)' : ''}
              </p>
              <div className="flex flex-wrap gap-3">
                <Checkbox
                  label="Owner"
                  checked={member.owner}
                  disabled={member.state !== 'active'}
                  onChange={(e) => {
                    router.patch(`/o/${orgSlug}/members/${member.id}`, {
                      owner: e.target.checked,
                      board_owner: member.board_owner,
                    })
                  }}
                />
                <Checkbox
                  label="Board owner"
                  checked={member.board_owner}
                  disabled={member.state !== 'active'}
                  onChange={(e) => {
                    router.patch(`/o/${orgSlug}/members/${member.id}`, {
                      owner: member.owner,
                      board_owner: e.target.checked,
                    })
                  }}
                />
              </div>
            </div>
            <div className="flex items-center gap-2">
              <Badge variant={member.state === 'active' ? 'moss' : 'ochre'}>
                {member.state === 'active' ? 'Active' : 'Deactivated'}
              </Badge>
              {member.state === 'active' ? (
                <Button
                  variant="ghost"
                  onClick={() => {
                    router.patch(
                      `/o/${orgSlug}/members/${member.id}/deactivate`,
                    )
                  }}
                >
                  Deactivate
                </Button>
              ) : (
                <Button
                  variant="ghost"
                  onClick={() => {
                    router.patch(`/o/${orgSlug}/members/${member.id}/activate`)
                  }}
                >
                  Reactivate
                </Button>
              )}
            </div>
          </li>
        ))}
      </ul>
    </Card>
  )
}

export default function MembersIndex({
  org_slug: orgSlug,
  members,
  invitations,
  seat_limit,
  board_owner_limit,
}: Props) {
  const joinRequests = members.filter(
    (member) => member.state === 'pending_approval',
  )
  const roster = members.filter((member) => member.state !== 'pending_approval')
  const reservedSeats =
    roster.filter((m) => m.state === 'active').length + invitations.length

  return (
    <AppShell
      title="Members"
      subtitle={seatSummary(reservedSeats, seat_limit, board_owner_limit)}
    >
      <div className="flex flex-col gap-6">
        <InviteForm orgSlug={orgSlug} />
        <JoinRequestsSection orgSlug={orgSlug} requests={joinRequests} />
        <InvitationsSection orgSlug={orgSlug} invitations={invitations} />
        <RosterSection orgSlug={orgSlug} members={roster} />
      </div>
    </AppShell>
  )
}
