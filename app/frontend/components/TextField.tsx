import type { InputHTMLAttributes } from 'react'

import FormField from '@/components/FormField'
import Input from '@/components/Input'

interface Props extends InputHTMLAttributes<HTMLInputElement> {
  label: string
  name: string
  hint?: string | undefined
  // useForm types errors as string; the Rails adapter ships arrays.
  // Accept both so callers never cast.
  errors?: string | string[] | undefined
}

// The label+input convenience nearly every form wants — composed from
// FormField + Input so the aria wiring lives in one place.
export default function TextField({ label, hint, errors, ...input }: Props) {
  return (
    <FormField label={label} hint={hint} errors={errors}>
      <Input {...input} />
    </FormField>
  )
}
