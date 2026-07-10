import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { beforeEach, describe, expect, it } from 'vitest'

import { mockInertia, resetInertiaMock, submitSpy } from '@/test/inertia-mock'

import ForgotPassword from './forgot_password'

mockInertia()

describe('auth/forgot_password', () => {
  beforeEach(resetInertiaMock)

  it('requests reset instructions', async () => {
    render(<ForgotPassword />)
    await userEvent.type(screen.getByLabelText('Email'), 'me@example.com')
    await userEvent.click(
      screen.getByRole('button', { name: 'Send reset instructions' }),
    )

    expect(submitSpy).toHaveBeenCalledWith(
      'post',
      '/passwords',
      expect.anything(),
    )
  })
})
