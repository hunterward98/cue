import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { describe, expect, it } from 'vitest'

import Tabs from './Tabs'

const tabs = [
  { value: 'profile', label: 'Profile', content: <p>profile body</p> },
  { value: 'members', label: 'Members', content: <p>members body</p> },
]

describe('Tabs', () => {
  it('shows the first tab by default and switches on click', async () => {
    render(<Tabs tabs={tabs} />)

    expect(screen.getByText('profile body')).toBeVisible()

    await userEvent.click(screen.getByRole('tab', { name: 'Members' }))
    expect(screen.getByText('members body')).toBeVisible()
  })

  it('honors an explicit default tab', () => {
    render(<Tabs tabs={tabs} defaultValue="members" />)
    expect(screen.getByRole('tab', { name: 'Members' })).toHaveAttribute(
      'aria-selected',
      'true',
    )
  })
})
