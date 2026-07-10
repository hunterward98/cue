import { useForm } from '@inertiajs/react'

import AuthCard from '@/components/AuthCard'
import Button from '@/components/Button'
import TextField from '@/components/TextField'

export default function ForgotPassword() {
  const form = useForm({ email_address: '' })

  const submit = (event: { preventDefault: () => void }) => {
    event.preventDefault()
    form.post('/passwords')
  }

  return (
    <AuthCard
      title="Reset your password"
      subtitle="Tell us the email; if there's a password to reset, instructions follow."
    >
      <form onSubmit={submit} className="flex flex-col gap-4">
        <TextField
          label="Email"
          name="email_address"
          type="email"
          autoComplete="email"
          required
          value={form.data.email_address}
          onChange={(e) => {
            form.setData('email_address', e.target.value)
          }}
        />
        <Button type="submit" disabled={form.processing}>
          Send reset instructions
        </Button>
      </form>
    </AuthCard>
  )
}
