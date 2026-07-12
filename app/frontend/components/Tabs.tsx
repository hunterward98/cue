import { Tabs as BaseTabs } from '@base-ui/react/tabs'
import type { ReactNode } from 'react'

// Base UI owns roving focus/aria (ADR 0014); we own the skin.
export interface TabDefinition {
  value: string
  label: string
  content: ReactNode
}

interface Props {
  tabs: TabDefinition[]
  defaultValue?: string
}

export default function Tabs({ tabs, defaultValue }: Props) {
  return (
    <BaseTabs.Root defaultValue={defaultValue ?? tabs[0]?.value}>
      <BaseTabs.List className="flex gap-1 border-b border-border">
        {tabs.map((tab) => (
          <BaseTabs.Tab
            key={tab.value}
            value={tab.value}
            className="rounded-t-md px-3 py-1.5 text-sm text-ink-muted hover:text-ink focus-visible:outline-2 focus-visible:outline-focus data-selected:border-b-2 data-selected:border-accent data-selected:text-ink"
          >
            {tab.label}
          </BaseTabs.Tab>
        ))}
      </BaseTabs.List>
      {tabs.map((tab) => (
        <BaseTabs.Panel key={tab.value} value={tab.value} className="pt-4">
          {tab.content}
        </BaseTabs.Panel>
      ))}
    </BaseTabs.Root>
  )
}
