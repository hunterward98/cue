// Initials-only for now — logo/photo upload arrives with theming plan_4.
import { hueFor, initialsFor, type Hue } from '@/lib/avatar'
import { cn } from '@/lib/cn'

const HUE_STYLES: Record<Hue, string> = {
  scarlet: 'bg-coding-scarlet-surface text-coding-scarlet-ink',
  ochre: 'bg-coding-ochre-surface text-coding-ochre-ink',
  moss: 'bg-coding-moss-surface text-coding-moss-ink',
  teal: 'bg-coding-teal-surface text-coding-teal-ink',
  indigo: 'bg-coding-indigo-surface text-coding-indigo-ink',
  plum: 'bg-coding-plum-surface text-coding-plum-ink',
}

interface Props {
  name: string
}

export default function Avatar({ name }: Props) {
  return (
    <span
      aria-hidden="true"
      title={name}
      className={cn(
        'inline-flex size-8 items-center justify-center rounded-full text-xs font-semibold',
        HUE_STYLES[hueFor(name)],
      )}
    >
      {initialsFor(name)}
    </span>
  )
}
