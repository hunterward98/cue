import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { describe, expect, it, vi } from 'vitest'

import Checkbox from './Checkbox'
import Radio from './Radio'

describe('Checkbox', () => {
  it('toggles through its label', async () => {
    const onChange = vi.fn()
    render(<Checkbox label="Email me" onChange={onChange} />)
    await userEvent.click(screen.getByLabelText('Email me'))
    expect(onChange).toHaveBeenCalled()
  })
})

describe('Radio', () => {
  it('selects through its label', async () => {
    const onChange = vi.fn()
    render(
      <>
        <Radio name="mode" label="Password" onChange={onChange} />
        <Radio name="mode" label="Email codes" onChange={onChange} />
      </>,
    )
    await userEvent.click(screen.getByLabelText('Email codes'))
    expect(onChange).toHaveBeenCalledTimes(1)
  })
})
