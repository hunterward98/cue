import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { describe, expect, it, vi } from 'vitest'

import FormField from './FormField'
import Select from './Select'

const options = [
  { value: 'requester', label: 'Requester' },
  { value: 'board_owner', label: 'Board owner' },
]

describe('Select', () => {
  it('shows the placeholder until a value is chosen', () => {
    render(
      <Select options={options} value={null} onValueChange={() => undefined} />,
    )
    expect(screen.getByText('Pick one…')).toBeInTheDocument()
  })

  it('shows the selected option label', () => {
    render(
      <Select
        options={options}
        value="board_owner"
        onValueChange={() => undefined}
      />,
    )
    expect(screen.getByText('Board owner')).toBeInTheDocument()
  })

  it('is marked invalid when its field has errors', () => {
    render(
      <FormField label="Role" errors={['must be chosen']}>
        <Select
          options={options}
          value={null}
          onValueChange={() => undefined}
        />
      </FormField>,
    )
    expect(screen.getByLabelText('Role')).toHaveAttribute(
      'aria-invalid',
      'true',
    )
  })

  it('opens on click and reports the chosen value', async () => {
    const onValueChange = vi.fn()
    render(
      <FormField label="Role">
        <Select options={options} value={null} onValueChange={onValueChange} />
      </FormField>,
    )

    await userEvent.click(screen.getByLabelText('Role'))
    await userEvent.click(
      await screen.findByRole('option', { name: 'Requester' }),
    )
    expect(onValueChange).toHaveBeenCalledWith('requester', expect.anything())
  })
})
