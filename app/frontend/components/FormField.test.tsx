import { render, screen } from '@testing-library/react'
import { describe, expect, it } from 'vitest'

import FormField from './FormField'
import Input from './Input'
import Textarea from './Textarea'

describe('FormField', () => {
  it('wires label, hint, and control together', () => {
    render(
      <FormField label="Slug" hint="Lowercase, permanent">
        <Input name="slug" />
      </FormField>,
    )
    const input = screen.getByLabelText('Slug')
    expect(input).toHaveAccessibleDescription('Lowercase, permanent')
    expect(input).not.toHaveAttribute('aria-invalid')
  })

  it('marks the control invalid and announces errors', () => {
    render(
      <FormField label="Slug" errors={['has already been taken']}>
        <Input name="slug" />
      </FormField>,
    )
    expect(screen.getByLabelText('Slug')).toHaveAttribute(
      'aria-invalid',
      'true',
    )
    expect(screen.getByRole('alert')).toHaveTextContent(
      'has already been taken',
    )
  })

  it('accepts a single error string and wires textareas too', () => {
    render(
      <FormField label="Notes" errors="too long">
        <Textarea name="notes" />
      </FormField>,
    )
    expect(screen.getByLabelText('Notes').tagName).toBe('TEXTAREA')
    expect(screen.getByRole('alert')).toHaveTextContent('too long')
  })
})

describe('Input and Textarea outside a FormField', () => {
  it('render unwired but functional', () => {
    render(
      <>
        <Input name="bare" aria-label="Bare input" />
        <Textarea name="bare-text" aria-label="Bare textarea" />
      </>,
    )
    expect(screen.getByLabelText('Bare input')).not.toHaveAttribute('id')
    expect(screen.getByLabelText('Bare textarea')).not.toHaveAttribute('id')
  })
})
