import { render, screen, within } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { beforeEach, describe, expect, it } from 'vitest'

import { mockInertia, resetInertiaMock, submitSpy } from '@/test/inertia-mock'

import MembersIndex from './index'

mockInertia()

const baseProps = {
  org_slug: 'riverside',
  seat_limit: 15 as number | null,
  board_owner_limit: 2 as number | null,
}

function rowFor(email: string) {
  const li = screen.getByText(email).closest('li')
  if (!li) throw new Error(`no <li> ancestor for ${email}`)
  return within(li)
}

describe('org/members/index', () => {
  beforeEach(resetInertiaMock)

  it('shows the seat summary and sends an invite', async () => {
    render(
      <MembersIndex
        {...baseProps}
        members={[
          {
            id: 'm1',
            email: 'owner@example.com',
            state: 'active',
            owner: true,
            board_owner: false,
            is_you: true,
          },
        ]}
        invitations={[]}
      />,
    )

    expect(
      screen.getByText(/1 of 15 seats used or reserved/),
    ).toBeInTheDocument()
    expect(screen.getByText(/2 board owners allowed/)).toBeInTheDocument()

    const emailField = screen.getByLabelText('Email')
    const form = emailField.closest('form')
    if (!form) throw new Error('no <form> ancestor for the email field')
    const inviteForm = within(form)

    await userEvent.type(emailField, 'new@example.com')
    await userEvent.click(inviteForm.getByRole('checkbox', { name: 'Owner' }))
    await userEvent.click(
      inviteForm.getByRole('checkbox', { name: 'Board owner' }),
    )
    await userEvent.click(
      screen.getByRole('button', { name: 'Send invitation' }),
    )

    expect(submitSpy).toHaveBeenCalledWith(
      'post',
      '/o/riverside/invitations',
      expect.objectContaining({}),
    )
    // The onSuccess handler (fired by the mock) resets the form.
    expect(emailField).toHaveValue('')
  })

  it('omits the seat summary when the tier is unlimited', () => {
    render(
      <MembersIndex
        {...baseProps}
        seat_limit={null}
        board_owner_limit={null}
        members={[]}
        invitations={[]}
      />,
    )
    expect(screen.queryByText(/seats used or reserved/)).not.toBeInTheDocument()
  })

  it('omits the board-owner note when only that limit is unlimited', () => {
    render(
      <MembersIndex
        {...baseProps}
        board_owner_limit={null}
        members={[]}
        invitations={[]}
      />,
    )
    expect(
      screen.getByText(/0 of 15 seats used or reserved/),
    ).toBeInTheDocument()
    expect(screen.queryByText(/board owners allowed/)).not.toBeInTheDocument()
  })

  it('shows the empty state with no members', () => {
    render(<MembersIndex {...baseProps} members={[]} invitations={[]} />)
    expect(screen.getByText('No members yet')).toBeInTheDocument()
  })

  it('resends and revokes a pending invitation, labeling every role combination', async () => {
    render(
      <MembersIndex
        {...baseProps}
        members={[]}
        invitations={[
          {
            id: 'i1',
            email: 'pending@example.com',
            owner: false,
            board_owner: true,
            invited_by: 'owner@example.com',
            expires_at: '2026-08-01T00:00:00Z',
            live: true,
          },
          {
            id: 'i3',
            email: 'future-owner@example.com',
            owner: true,
            board_owner: false,
            invited_by: 'owner@example.com',
            expires_at: '2026-08-01T00:00:00Z',
            live: true,
          },
          {
            id: 'i4',
            email: 'both-roles@example.com',
            owner: true,
            board_owner: true,
            invited_by: 'owner@example.com',
            expires_at: '2026-08-01T00:00:00Z',
            live: true,
          },
        ]}
      />,
    )

    const row = rowFor('pending@example.com')
    expect(row.getByText(/\(Board owner\)/)).toBeInTheDocument()
    expect(
      rowFor('future-owner@example.com').getByText(/\(Owner\)/),
    ).toBeInTheDocument()
    expect(
      rowFor('both-roles@example.com').getByText(/\(Owner, board owner\)/),
    ).toBeInTheDocument()

    await userEvent.click(row.getByRole('button', { name: 'Resend' }))
    expect(submitSpy).toHaveBeenCalledWith(
      'post',
      '/o/riverside/invitations/i1/resend',
    )

    await userEvent.click(row.getByRole('button', { name: 'Revoke' }))
    expect(submitSpy).toHaveBeenCalledWith(
      'delete',
      '/o/riverside/invitations/i1',
    )
  })

  it('flags an expired invitation', () => {
    render(
      <MembersIndex
        {...baseProps}
        members={[]}
        invitations={[
          {
            id: 'i2',
            email: 'stale@example.com',
            owner: false,
            board_owner: false,
            invited_by: 'owner@example.com',
            expires_at: '2020-01-01T00:00:00Z',
            live: false,
          },
        ]}
      />,
    )
    expect(screen.getByText(/— expired/)).toBeInTheDocument()
  })

  it('approves and denies a join request', async () => {
    render(
      <MembersIndex
        {...baseProps}
        members={[
          {
            id: 'm2',
            email: 'requester@example.com',
            state: 'pending_approval',
            owner: false,
            board_owner: false,
            is_you: false,
          },
        ]}
        invitations={[]}
      />,
    )

    const row = rowFor('requester@example.com')
    await userEvent.click(row.getByRole('button', { name: 'Approve' }))
    expect(submitSpy).toHaveBeenCalledWith(
      'patch',
      '/o/riverside/members/m2/activate',
    )

    await userEvent.click(row.getByRole('button', { name: 'Deny' }))
    expect(submitSpy).toHaveBeenCalledWith('delete', '/o/riverside/members/m2')
  })

  it('toggles roles and deactivates an active member', async () => {
    render(
      <MembersIndex
        {...baseProps}
        members={[
          {
            id: 'm3',
            email: 'member@example.com',
            state: 'active',
            owner: false,
            board_owner: false,
            is_you: false,
          },
        ]}
        invitations={[]}
      />,
    )

    const row = rowFor('member@example.com')
    await userEvent.click(row.getByRole('checkbox', { name: 'Owner' }))
    expect(submitSpy).toHaveBeenCalledWith('patch', '/o/riverside/members/m3', {
      owner: true,
      board_owner: false,
    })

    await userEvent.click(row.getByRole('checkbox', { name: 'Board owner' }))
    expect(submitSpy).toHaveBeenCalledWith('patch', '/o/riverside/members/m3', {
      owner: false,
      board_owner: true,
    })

    await userEvent.click(row.getByRole('button', { name: 'Deactivate' }))
    expect(submitSpy).toHaveBeenCalledWith(
      'patch',
      '/o/riverside/members/m3/deactivate',
    )
  })

  it('reactivates a deactivated member with role checkboxes disabled', () => {
    render(
      <MembersIndex
        {...baseProps}
        members={[
          {
            id: 'm4',
            email: 'gone@example.com',
            state: 'deactivated',
            owner: false,
            board_owner: false,
            is_you: false,
          },
        ]}
        invitations={[]}
      />,
    )

    const row = rowFor('gone@example.com')
    expect(row.getByRole('checkbox', { name: 'Owner' })).toBeDisabled()
    expect(row.getByText('Deactivated')).toBeInTheDocument()
  })

  it('reactivates via the button', async () => {
    render(
      <MembersIndex
        {...baseProps}
        members={[
          {
            id: 'm5',
            email: 'gone@example.com',
            state: 'deactivated',
            owner: false,
            board_owner: false,
            is_you: false,
          },
        ]}
        invitations={[]}
      />,
    )

    const row = rowFor('gone@example.com')
    await userEvent.click(row.getByRole('button', { name: 'Reactivate' }))
    expect(submitSpy).toHaveBeenCalledWith(
      'patch',
      '/o/riverside/members/m5/activate',
    )
  })
})
