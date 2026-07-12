import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { beforeEach, describe, expect, it } from 'vitest'

import { mockInertia, resetInertiaMock, submitSpy } from '@/test/inertia-mock'

import JoinOrganization from './join'

mockInertia()

const organization = { name: 'Riverside Dental', slug: 'riverside' }

describe('org/join', () => {
  beforeEach(resetInertiaMock)

  it('offers to request access when not yet a member', async () => {
    render(<JoinOrganization organization={organization} status="none" />)

    await userEvent.click(
      screen.getByRole('button', { name: 'Request to join' }),
    )

    expect(submitSpy).toHaveBeenCalledWith('post', '/join/riverside')
  })

  it('shows the pending state for an outstanding request', () => {
    render(
      <JoinOrganization
        organization={organization}
        status="pending_approval"
      />,
    )
    expect(screen.getByText(/An owner will review it/)).toBeInTheDocument()
  })

  it('shows a neutral message for a deactivated member', () => {
    render(
      <JoinOrganization organization={organization} status="deactivated" />,
    )
    expect(
      screen.getByText(/Contact an owner at Riverside Dental/),
    ).toBeInTheDocument()
  })
})
