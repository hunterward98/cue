import type { ReactNode } from 'react'
import {
  createContext,
  useCallback,
  useContext,
  useMemo,
  useState,
} from 'react'

import { cn } from '@/lib/cn'

// A deliberately small toast: success/danger, auto-dismiss, screen-reader
// polite. Flash messages from the server render via AppShell banners;
// toasts are for client-side moments (copied a link, etc.).
export interface ToastMessage {
  id: number
  tone: 'success' | 'danger'
  text: string
}

interface ToastContextValue {
  toast: (tone: ToastMessage['tone'], text: string) => void
}

const ToastContext = createContext<ToastContextValue | null>(null)

export function useToast(): ToastContextValue {
  const value = useContext(ToastContext)
  if (value === null) {
    throw new Error('useToast requires a ToastProvider above it')
  }
  return value
}

export function ToastProvider({
  children,
  dismissAfterMs = 4000,
}: {
  children: ReactNode
  dismissAfterMs?: number
}) {
  const [messages, setMessages] = useState<ToastMessage[]>([])

  const toast = useCallback(
    (tone: ToastMessage['tone'], text: string) => {
      const id = Date.now() + Math.random()
      setMessages((current) => [...current, { id, tone, text }])
      setTimeout(() => {
        setMessages((current) => current.filter((m) => m.id !== id))
      }, dismissAfterMs)
    },
    [dismissAfterMs],
  )

  const value = useMemo(() => ({ toast }), [toast])

  return (
    <ToastContext.Provider value={value}>
      {children}
      <div
        role="status"
        aria-live="polite"
        className="fixed right-4 bottom-4 flex flex-col gap-2"
      >
        {messages.map((message) => (
          <p
            key={message.id}
            className={cn(
              'rounded-md border p-3 text-sm',
              message.tone === 'success'
                ? 'border-success-ink/25 bg-success-surface text-success-ink'
                : 'border-danger-ink/25 bg-danger-surface text-danger-ink',
            )}
          >
            {message.text}
          </p>
        ))}
      </div>
    </ToastContext.Provider>
  )
}
