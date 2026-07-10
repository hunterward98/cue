import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { beforeEach, describe, expect, it } from 'vitest'

import { mockInertia, resetInertiaMock, submitSpy } from '@/test/inertia-mock'

import SessionsIndex from './index'

mockInertia()

const sessions = [
  {
    id: 'aaa',
    current: true,
    ip_address: '203.0.113.7',
    user_agent: 'Firefox on Linux',
    last_active_at: '2026-07-10T12:00:00Z',
  },
  {
    id: 'bbb',
    current: false,
    ip_address: null,
    user_agent: null,
    last_active_at: '2026-07-09T12:00:00Z',
  },
]

describe('sessions/index', () => {
  beforeEach(resetInertiaMock)

  it('lists devices, marking the current one and tolerating unknowns', () => {
    render(<SessionsIndex sessions={sessions} />)

    expect(
      screen.getByText(/Firefox on Linux — this device/),
    ).toBeInTheDocument()
    expect(screen.getByText('Unknown device')).toBeInTheDocument()
    expect(screen.getByText(/unknown address/)).toBeInTheDocument()
  })

  it('revokes a session', async () => {
    render(<SessionsIndex sessions={sessions} />)
    await userEvent.click(screen.getByRole('button', { name: 'Revoke' }))

    expect(submitSpy).toHaveBeenCalledWith('delete', '/sessions/bbb')
  })
})
