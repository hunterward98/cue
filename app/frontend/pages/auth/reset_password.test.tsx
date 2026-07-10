import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { beforeEach, describe, expect, it } from 'vitest'

import {
  formErrors,
  mockInertia,
  resetInertiaMock,
  submitSpy,
} from '@/test/inertia-mock'

import ResetPassword from './reset_password'

mockInertia()

describe('auth/reset_password', () => {
  beforeEach(resetInertiaMock)

  it('patches the new password to the tokened URL', async () => {
    render(<ResetPassword token="tok-123" />)
    await userEvent.type(
      screen.getByLabelText(/New password/),
      'a-long-enough-password',
    )
    await userEvent.click(
      screen.getByRole('button', { name: 'Reset password' }),
    )

    expect(submitSpy).toHaveBeenCalledWith(
      'patch',
      '/passwords/tok-123',
      expect.anything(),
    )
  })

  it('surfaces server-side errors', () => {
    formErrors.password = ['is too short (minimum is 12 characters)']
    render(<ResetPassword token="tok-123" />)
    expect(screen.getByRole('alert')).toHaveTextContent('too short')
  })
})
