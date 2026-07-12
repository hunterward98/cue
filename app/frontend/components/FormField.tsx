import type { ReactNode } from 'react'
import { createContext, useContext, useId, useMemo } from 'react'

// Label + hint + error composition. Children (Input/Textarea/Select)
// read the generated id and error state from context so aria wiring is
// impossible to forget.
interface FieldContextValue {
  id: string
  describedBy: string | undefined
  invalid: boolean
}

const FieldContext = createContext<FieldContextValue | null>(null)

export function useFieldContext(): FieldContextValue | null {
  return useContext(FieldContext)
}

interface Props {
  label: string
  hint?: string | undefined
  // useForm types errors as string; the Rails adapter ships arrays.
  errors?: string | string[] | undefined
  children: ReactNode
}

export default function FormField({ label, hint, errors, children }: Props) {
  const id = useId()
  const messages = errors == null ? [] : [errors].flat()
  const hintId = hint == null ? undefined : `${id}-hint`
  const invalid = messages.length > 0
  const fieldValue = useMemo(
    () => ({ id, describedBy: hintId, invalid }),
    [id, hintId, invalid],
  )

  return (
    <div className="flex flex-col gap-1">
      <label htmlFor={id} className="text-sm font-medium text-ink">
        {label}
      </label>
      {hint ? (
        <p id={hintId} className="text-xs text-ink-muted">
          {hint}
        </p>
      ) : null}
      <FieldContext.Provider value={fieldValue}>
        {children}
      </FieldContext.Provider>
      {messages.length > 0 ? (
        <span role="alert" className="text-sm text-destructive">
          {messages.join(', ')}
        </span>
      ) : null}
    </div>
  )
}
