import { cn } from '@/lib/cn'

interface Props {
  // Layout-only pass-through: size the bone where it's used.
  className?: string
}

export default function Skeleton({ className }: Props) {
  return (
    <span
      aria-hidden="true"
      className={cn(
        'block animate-pulse rounded-md bg-border',
        className ?? 'h-4 w-full',
      )}
    />
  )
}
