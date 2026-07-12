import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { beforeEach, describe, expect, it } from 'vitest'

import { mockInertia, resetInertiaMock, submitSpy } from '@/test/inertia-mock'

import SwitchAccount from './switch_account'

mockInertia()

describe('auth/switch_account', () => {
  beforeEach(resetInertiaMock)

  it('explains the mismatch and offers to sign out and continue', async () => {
    render(
      <SwitchAccount
        organization_name="Riverside Dental"
        current_email="wrong@example.com"
        invited_email="right@example.com"
        token="abc123"
      />,
    )

    expect(
      screen.getByText(/Riverside Dental was sent to right@example.com/),
    ).toBeInTheDocument()

    await userEvent.click(
      screen.getByRole('button', { name: 'Sign out and continue' }),
    )

    expect(submitSpy).toHaveBeenCalledWith(
      'delete',
      '/invitations/abc123/session',
    )
  })
})
