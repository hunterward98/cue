import type { ReactNode } from 'react'
import { useState } from 'react'
import { vi } from 'vitest'

// Shared mock for @inertiajs/react: a miniature useForm built on real
// React state (so conditional rendering reacts to setData), spy-backed
// visits, and a usePage whose props tests can set.
export const submitSpy =
  vi.fn<(method: string, url: string, options?: unknown) => void>()

export const pageProps: Record<string, unknown> = {}

export const pageFlash: { notice?: string; alert?: string } = {}

export const formErrors: Record<string, string | string[]> = {}

export function resetInertiaMock() {
  submitSpy.mockReset()
  for (const key of Object.keys(pageProps)) {
    Reflect.deleteProperty(pageProps, key)
  }
  for (const key of Object.keys(formErrors)) {
    Reflect.deleteProperty(formErrors, key)
  }
  delete pageFlash.notice
  delete pageFlash.alert
}

interface MiniForm {
  data: Record<string, unknown>
  errors: Record<string, string | string[]>
  processing: boolean
  setData: (key: string, value: unknown) => void
  transform: (
    fn: (data: Record<string, unknown>) => Record<string, unknown>,
  ) => void
  post: (url: string, options?: unknown) => void
  patch: (url: string, options?: unknown) => void
}

export function mockInertia() {
  vi.mock('@inertiajs/react', () => ({
    router: {
      delete: (url: string) => {
        submitSpy('delete', url)
      },
      patch: (url: string, data?: unknown, options?: unknown) => {
        submitSpy('patch', url, data ?? options)
      },
    },
    Link: ({
      href,
      children,
      ...rest
    }: {
      href: string
      children: ReactNode
    }) => (
      <a href={href} {...rest}>
        {children}
      </a>
    ),
    usePage: () => ({ props: pageProps, flash: pageFlash }),
    useForm: (initial: Record<string, unknown>): MiniForm => {
      const [data, setDataState] = useState(initial)
      let transformed = data
      return {
        data,
        errors: formErrors,
        processing: false,
        setData: (key, value) => {
          setDataState((current) => ({ ...current, [key]: value }))
        },
        transform: (fn) => {
          transformed = fn(data)
        },
        post: (url, options) => {
          submitSpy('post', url, options ?? transformed)
        },
        patch: (url, options) => {
          submitSpy('patch', url, options ?? transformed)
        },
      }
    },
  }))
}
