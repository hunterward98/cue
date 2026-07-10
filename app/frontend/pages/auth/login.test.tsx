import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { beforeEach, describe, expect, it } from 'vitest'

import { mockInertia, resetInertiaMock, submitSpy } from '@/test/inertia-mock'

import Login from './login'

mockInertia()

describe('auth/login', () => {
  beforeEach(resetInertiaMock)

  it('signs in with a password', async () => {
    render(<Login />)
    await userEvent.type(screen.getByLabelText('Email'), 'me@example.com')
    await userEvent.type(
      screen.getByLabelText('Password'),
      'a-long-enough-password',
    )
    await userEvent.click(screen.getByRole('button', { name: 'Sign in' }))

    expect(submitSpy).toHaveBeenCalledWith(
      'post',
      '/session',
      expect.anything(),
    )
  })

  it('requests an emailed code instead', async () => {
    render(<Login />)
    await userEvent.type(screen.getByLabelText('Email'), 'me@example.com')
    await userEvent.click(
      screen.getByRole('button', { name: /sign-in code instead/ }),
    )

    expect(submitSpy).toHaveBeenCalledWith(
      'post',
      '/login_code',
      expect.anything(),
    )
  })

  it('switches to code entry after a code was sent', async () => {
    render(<Login code_sent="me@example.com" />)

    expect(screen.queryByLabelText('Password')).not.toBeInTheDocument()
    await userEvent.type(screen.getByLabelText('Sign-in code'), '123456')
    await userEvent.click(screen.getByRole('button', { name: 'Sign in' }))

    expect(submitSpy).toHaveBeenCalledWith(
      'post',
      '/session',
      expect.anything(),
    )
  })

  it('links to reset and registration', () => {
    render(<Login />)
    expect(
      screen.getByRole('link', { name: 'Forgot your password?' }),
    ).toHaveAttribute('href', '/passwords/new')
    expect(
      screen.getByRole('link', { name: 'Create an account' }),
    ).toHaveAttribute('href', '/registration/new')
  })
})
