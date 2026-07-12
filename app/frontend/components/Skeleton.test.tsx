import { render } from '@testing-library/react'
import { describe, expect, it } from 'vitest'

import Skeleton from './Skeleton'

describe('Skeleton', () => {
  it('is hidden from assistive tech with a default bone size', () => {
    const { container } = render(<Skeleton />)
    const bone = container.firstElementChild
    expect(bone).toHaveAttribute('aria-hidden', 'true')
    expect(bone).toHaveClass('h-4')
  })

  it('takes layout sizing from the caller', () => {
    const { container } = render(<Skeleton className="h-8 w-24" />)
    expect(container.firstElementChild).toHaveClass('h-8', 'w-24')
  })
})
