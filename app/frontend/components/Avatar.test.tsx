import { render } from '@testing-library/react'
import { describe, expect, it } from 'vitest'

import Avatar from './Avatar'

describe('Avatar', () => {
  it('renders initials, keeps the name as a tooltip, hides from AT', () => {
    const { container } = render(<Avatar name="Charlie Kelly" />)
    const avatar = container.firstElementChild
    expect(avatar).toHaveTextContent('CK')
    expect(avatar).toHaveAttribute('title', 'Charlie Kelly')
    expect(avatar).toHaveAttribute('aria-hidden', 'true')
  })
})
