import type { ButtonHTMLAttributes } from 'react'

interface Props extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'quiet'
}

export default function Button({ variant = 'primary', ...button }: Props) {
  const styles =
    variant === 'primary'
      ? 'rounded-md bg-stone-900 px-4 py-2 text-sm font-medium text-white hover:bg-stone-700 disabled:opacity-50'
      : 'rounded-md px-4 py-2 text-sm font-medium text-stone-700 underline-offset-2 hover:underline disabled:opacity-50'

  return <button type="button" className={styles} {...button} />
}
