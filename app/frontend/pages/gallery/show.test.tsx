import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { beforeEach, describe, expect, it } from 'vitest'

import { mockInertia, resetInertiaMock } from '@/test/inertia-mock'

import GalleryShow from './show'

mockInertia()

describe('gallery/show', () => {
  beforeEach(resetInertiaMock)

  it('renders every catalog section', () => {
    render(<GalleryShow />)
    expect(
      screen.getByRole('heading', { name: 'Component gallery' }),
    ).toBeInTheDocument()
    for (const section of [
      'Typography',
      'Buttons',
      'Badges',
      'Forms',
      'Cards and empty states',
      'Table',
      'Tabs',
      'Avatars',
      'Feedback',
      'Navigation',
      'Overlays',
    ]) {
      expect(screen.getByRole('region', { name: section })).toBeInTheDocument()
    }
  })

  it('raises and auto-clears toasts', async () => {
    render(<GalleryShow />)
    await userEvent.click(screen.getByRole('button', { name: 'Success toast' }))
    expect(
      screen.getByText('Copied. Go paste it somewhere nice.'),
    ).toBeInTheDocument()

    await userEvent.click(screen.getByRole('button', { name: 'Danger toast' }))
    expect(
      screen.getByText('That did not work. Try again?'),
    ).toBeInTheDocument()
  })

  it('opens the modal, confirm dialog, and drawer from their triggers', async () => {
    render(<GalleryShow />)

    await userEvent.click(screen.getByRole('button', { name: 'Open modal' }))
    expect(screen.getByRole('dialog', { name: 'A modal' })).toBeInTheDocument()
    await userEvent.keyboard('{Escape}')

    await userEvent.click(screen.getByRole('button', { name: 'Open confirm' }))
    expect(
      screen.getByRole('dialog', { name: 'Delete everything?' }),
    ).toBeInTheDocument()
    await userEvent.click(screen.getByRole('button', { name: 'Delete' }))
    expect(
      screen.queryByRole('dialog', { name: 'Delete everything?' }),
    ).not.toBeInTheDocument()

    await userEvent.click(screen.getByRole('button', { name: 'Open drawer' }))
    expect(screen.getByRole('dialog', { name: 'Menu' })).toBeInTheDocument()
  })

  it('picks a default role from the select', async () => {
    render(<GalleryShow />)
    await userEvent.click(screen.getByLabelText('Default role'))
    await userEvent.click(
      await screen.findByRole('option', { name: 'Board owner' }),
    )
    expect(screen.getByLabelText('Default role')).toHaveTextContent(
      'Board owner',
    )
  })

  it('switches tabs', async () => {
    render(<GalleryShow />)
    expect(screen.getByText('Tab one.')).toBeVisible()
    await userEvent.click(screen.getByRole('tab', { name: 'Members' }))
    expect(screen.getByText('Tab two.')).toBeVisible()
  })
})
