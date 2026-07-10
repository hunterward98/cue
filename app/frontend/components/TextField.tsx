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
    <label className="flex flex-col gap-1 text-sm font-medium text-stone-800">
      {label}
      <input
        name={name}
        aria-invalid={messages.length > 0 ? true : undefined}
        className="rounded-md border border-stone-300 px-3 py-2 text-base text-stone-900 focus:border-stone-500 focus:outline-none"
        {...input}
      />
      {messages.length > 0 ? (
        <span role="alert" className="font-normal text-red-700">
          {messages.join(', ')}
        </span>
      ) : null}
    </label>
  )
}
