import type { TextareaHTMLAttributes } from 'react'

import { useFieldContext } from '@/components/FormField'

type Props = TextareaHTMLAttributes<HTMLTextAreaElement>

export default function Textarea(props: Props) {
  const field = useFieldContext()

  return (
    <textarea
      id={field?.id}
      aria-describedby={field?.describedBy}
      aria-invalid={field?.invalid ? true : undefined}
      rows={4}
      className="rounded-md border border-border-strong bg-surface-raised px-3 py-2 text-base text-ink focus:border-focus focus:outline-none"
      {...props}
    />
  )
}
