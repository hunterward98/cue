import { useForm } from '@inertiajs/react'
import { useRef } from 'react'

import AppShell from '@/components/AppShell'
import Button from '@/components/Button'
import TextField from '@/components/TextField'
import { suggestSlug } from '@/lib/slug'

interface OrganizationForm {
  name: string
  slug: string
  [key: string]: string
}

export default function OrganizationsNew() {
  const form = useForm<OrganizationForm>({ name: '', slug: '' })
  // Auto-suggest the slug from the name until the user edits it by hand —
  // after that, their spelling wins. A ref, not state: it never renders.
  const slugTouched = useRef(false)

  const submit = (event: { preventDefault: () => void }) => {
    event.preventDefault()
    form.post('/organizations')
  }

  return (
    <AppShell
      title="New organization"
      subtitle="A name for the door, a slug for the address."
    >
      <form
        onSubmit={submit}
        className="flex flex-col gap-4 rounded-lg border border-stone-200 bg-white p-6"
      >
        <TextField
          label="Organization name"
          name="name"
          required
          value={form.data.name}
          onChange={(e) => {
            form.setData('name', e.target.value)
            if (!slugTouched.current) {
              form.setData('slug', suggestSlug(e.target.value))
            }
          }}
          errors={form.errors.name}
        />
        <TextField
          label="Slug (in your join links — permanent)"
          name="slug"
          required
          value={form.data.slug}
          onChange={(e) => {
            slugTouched.current = true
            form.setData('slug', e.target.value)
          }}
          errors={form.errors.slug}
        />
        <Button type="submit" disabled={form.processing}>
          Create organization
        </Button>
      </form>
    </AppShell>
  )
}
