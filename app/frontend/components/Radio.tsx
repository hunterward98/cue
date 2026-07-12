import type { InputHTMLAttributes, ReactNode } from 'react'

interface Props extends InputHTMLAttributes<HTMLInputElement> {
  label: ReactNode
}

export default function Radio({ label, ...input }: Props) {
  return (
    <label className="flex items-start gap-2 text-sm text-ink">
      <input
        type="radio"
        className="mt-0.5 size-4 border-border-strong text-accent focus:ring-focus"
        {...input}
      />
      <span>{label}</span>
    </label>
  )
}
