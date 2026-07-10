import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { beforeEach, describe, expect, it } from 'vitest'

import {
  formErrors,
  mockInertia,
  resetInertiaMock,
  submitSpy,
} from '@/test/inertia-mock'

import Register from './register'

mockInertia()

describe('auth/register', () => {
  beforeEach(resetInertiaMock)

  it('defaults to password mode with a password field', () => {
    render(<Register />)
    expect(
      screen.getByLabelText('Password (12+ characters)'),
    ).toBeInTheDocument()
  })

  it('hides the password field in email-code mode', async () => {
    render(<Register />)
    await userEvent.click(screen.getByRole('radio', { name: /Email codes/ }))
    expect(
      screen.queryByLabelText('Password (12+ characters)'),
    ).not.toBeInTheDocument()

    await userEvent.click(screen.getByRole('radio', { name: /^Password/ }))
    expect(
      screen.getByLabelText('Password (12+ characters)'),
    ).toBeInTheDocument()
  })

  it('posts the registration', async () => {
    render(<Register />)
    await userEvent.type(screen.getByLabelText('Email'), 'new@example.com')
    await userEvent.type(
      screen.getByLabelText('Password (12+ characters)'),
      'a-long-enough-password',
    )
    await userEvent.click(
      screen.getByRole('button', { name: 'Create account' }),
    )

    expect(submitSpy).toHaveBeenCalledWith(
      'post',
      '/registration',
      expect.anything(),
    )
  })

  it('surfaces server-side errors', () => {
    formErrors.email_address = ['has already been taken']
    render(<Register />)
    expect(screen.getByRole('alert')).toHaveTextContent(
      'has already been taken',
    )
  })
})
