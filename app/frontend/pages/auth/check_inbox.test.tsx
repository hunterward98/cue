import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { beforeEach, describe, expect, it } from 'vitest'

import { mockInertia, resetInertiaMock, submitSpy } from '@/test/inertia-mock'

import CheckInbox from './check_inbox'

mockInertia()

describe('auth/check_inbox', () => {
  beforeEach(resetInertiaMock)

  it('shows which inbox to check', () => {
    render(<CheckInbox email="who@example.com" />)
    expect(screen.getByText(/who@example.com/)).toBeInTheDocument()
  })

  it('submits the code', async () => {
    render(<CheckInbox email="who@example.com" />)
    await userEvent.type(screen.getByLabelText('Verification code'), '123456')
    await userEvent.click(screen.getByRole('button', { name: 'Verify' }))

    expect(submitSpy).toHaveBeenCalledWith(
      'patch',
      '/email_verification',
      expect.anything(),
    )
  })

  it('requests a fresh code', async () => {
    render(<CheckInbox email="who@example.com" />)
    await userEvent.click(
      screen.getByRole('button', { name: 'Send a fresh code' }),
    )

    expect(submitSpy).toHaveBeenCalledWith(
      'post',
      '/email_verification/resend',
      expect.objectContaining({ preserveState: true }),
    )
  })
})
