import type { InputHTMLAttributes } from 'react'

interface Props extends InputHTMLAttributes<HTMLInputElement> {
  label: string
}

export default function Checkbox({ label, ...input }: Props) {
  return (
    <label className="flex items-start gap-2 text-sm text-ink">
      <input
        type="checkbox"
        className="mt-0.5 size-4 rounded border-border-strong text-accent focus:ring-focus"
        {...input}
      />
      <span>{label}</span>
    </label>
  )
}
