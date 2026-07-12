import type { InputHTMLAttributes } from 'react'

import { useFieldContext } from '@/components/FormField'

type Props = InputHTMLAttributes<HTMLInputElement>

export default function Input(props: Props) {
  const field = useFieldContext()

  return (
    <input
      id={field?.id}
      aria-describedby={field?.describedBy}
      aria-invalid={field?.invalid ? true : undefined}
      className="rounded-md border border-border-strong bg-surface-raised px-3 py-2 text-base text-ink focus:border-focus focus:outline-none"
      {...props}
    />
  )
}
