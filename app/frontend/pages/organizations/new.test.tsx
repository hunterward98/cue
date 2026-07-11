import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { beforeEach, describe, expect, it } from 'vitest'

import {
  formErrors,
  mockInertia,
  resetInertiaMock,
  submitSpy,
} from '@/test/inertia-mock'

import OrganizationsNew from './new'

mockInertia()

const slugField = 'Slug (in your join links — permanent)'

describe('organizations/new', () => {
  beforeEach(resetInertiaMock)

  it('suggests a slug from the name as it is typed', async () => {
    render(<OrganizationsNew />)
    await userEvent.type(
      screen.getByLabelText('Organization name'),
      'Riverside Dental',
    )
    expect(screen.getByLabelText(slugField)).toHaveValue('riverside-dental')
  })

  it('stops suggesting once the slug is edited by hand', async () => {
    render(<OrganizationsNew />)
    await userEvent.type(screen.getByLabelText('Organization name'), 'One')
    await userEvent.clear(screen.getByLabelText(slugField))
    await userEvent.type(screen.getByLabelText(slugField), 'my-own')
    await userEvent.type(screen.getByLabelText('Organization name'), ' Two')

    expect(screen.getByLabelText(slugField)).toHaveValue('my-own')
  })

  it('posts the new organization', async () => {
    render(<OrganizationsNew />)
    await userEvent.type(screen.getByLabelText('Organization name'), 'Acme')
    await userEvent.click(
      screen.getByRole('button', { name: 'Create organization' }),
    )

    expect(submitSpy).toHaveBeenCalledWith(
      'post',
      '/organizations',
      expect.anything(),
    )
  })

  it('surfaces server-side errors', () => {
    formErrors.slug = ['has already been taken']
    render(<OrganizationsNew />)
    expect(screen.getByRole('alert')).toHaveTextContent(
      'has already been taken',
    )
  })
})
