import { Select as BaseSelect } from '@base-ui/react/select'

import { useFieldContext } from '@/components/FormField'

// Base UI owns keyboard/aria/positioning (ADR 0014); we own the skin.
export interface SelectOption {
  value: string
  label: string
}

interface Props {
  options: SelectOption[]
  value: string | null
  onValueChange: (value: string) => void
  placeholder?: string
}

export default function Select({
  options,
  value,
  onValueChange,
  placeholder = 'Pick one…',
}: Props) {
  const field = useFieldContext()

  return (
    // '' (never an option value) stands in for "nothing chosen". Base UI
    // types the callback value as nullable, but null only appears when a
    // caller clears the value programmatically — this wrapper never does,
    // so the cast is sound and avoids an untestable dead branch.
    <BaseSelect.Root
      value={value ?? ''}
      onValueChange={onValueChange as (value: string | null) => void}
    >
      <BaseSelect.Trigger
        id={field?.id}
        aria-describedby={field?.describedBy}
        aria-invalid={field?.invalid ? true : undefined}
        className="flex items-center justify-between gap-2 rounded-md border border-border-strong bg-surface-raised px-3 py-2 text-left text-base text-ink focus:border-focus focus:outline-none"
      >
        <BaseSelect.Value>
          {(state: string | null) =>
            options.find((option) => option.value === state)?.label ?? (
              <span className="text-ink-muted">{placeholder}</span>
            )
          }
        </BaseSelect.Value>
        <BaseSelect.Icon className="text-ink-muted">▾</BaseSelect.Icon>
      </BaseSelect.Trigger>
      <BaseSelect.Portal>
        <BaseSelect.Positioner sideOffset={4}>
          <BaseSelect.Popup className="rounded-md border border-border bg-surface-raised py-1">
            <BaseSelect.List>
              {options.map((option) => (
                <BaseSelect.Item
                  key={option.value}
                  value={option.value}
                  className="cursor-default px-3 py-1.5 text-sm text-ink data-highlighted:bg-surface"
                >
                  <BaseSelect.ItemText>{option.label}</BaseSelect.ItemText>
                </BaseSelect.Item>
              ))}
            </BaseSelect.List>
          </BaseSelect.Popup>
        </BaseSelect.Positioner>
      </BaseSelect.Portal>
    </BaseSelect.Root>
  )
}
