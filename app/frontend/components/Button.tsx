import type { ButtonHTMLAttributes } from 'react'

interface Props extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'quiet'
}

export default function Button({ variant = 'primary', ...button }: Props) {
  const styles =
    variant === 'primary'
      ? 'rounded-md bg-accent px-4 py-2 text-sm font-medium text-accent-ink hover:bg-accent-hover focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-focus disabled:opacity-50'
      : 'rounded-md px-4 py-2 text-sm font-medium text-ink-muted underline-offset-2 hover:underline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-focus disabled:opacity-50'

  return <button type="button" className={styles} {...button} />
}
