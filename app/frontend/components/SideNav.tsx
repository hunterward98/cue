import { Link } from '@inertiajs/react'

import { cn } from '@/lib/cn'

// Section navigation: a side rail on desktop, an accordion on mobile
// (org settings and friends dock into this).
export interface NavItem {
  label: string
  href: string
  current?: boolean
}

interface Props {
  label: string
  items: NavItem[]
}

export default function SideNav({ label, items }: Props) {
  const list = (
    <ul className="flex flex-col gap-1">
      {items.map((item) => (
        <li key={item.href}>
          <Link
            href={item.href}
            aria-current={item.current ? 'page' : undefined}
            className={cn(
              'block rounded-md px-3 py-1.5 text-sm',
              item.current
                ? 'bg-surface-raised font-medium text-ink'
                : 'text-ink-muted hover:text-ink',
            )}
          >
            {item.label}
          </Link>
        </li>
      ))}
    </ul>
  )

  return (
    <nav aria-label={label}>
      {/* Mobile: accordion. */}
      <details className="rounded-md border border-border sm:hidden">
        <summary className="cursor-pointer px-3 py-2 text-sm font-medium text-ink">
          {label}
        </summary>
        <div className="border-t border-border p-2">{list}</div>
      </details>
      {/* Desktop: always-visible rail. */}
      <div className="hidden sm:block">{list}</div>
    </nav>
  )
}
