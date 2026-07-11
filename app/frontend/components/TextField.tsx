import type { InputHTMLAttributes } from 'react'

interface Props extends InputHTMLAttributes<HTMLInputElement> {
  label: string
  name: string
  // useForm types errors as string; the Rails adapter ships arrays.
  // Accept both so callers never cast.
  errors?: string | string[] | undefined
}

export default function TextField({ label, name, errors, ...input }: Props) {
  const messages = errors == null ? [] : [errors].flat()

  return (
    <label className="flex flex-col gap-1 text-sm font-medium text-ink">
      {label}
      <input
        name={name}
        aria-invalid={messages.length > 0 ? true : undefined}
        className="rounded-md border border-border-strong bg-surface-raised px-3 py-2 text-base text-ink focus:border-focus focus:outline-none"
        {...input}
      />
      {messages.length > 0 ? (
        <span role="alert" className="font-normal text-destructive">
          {messages.join(', ')}
        </span>
      ) : null}
    </label>
  )
}
