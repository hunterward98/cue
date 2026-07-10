import { useForm } from '@inertiajs/react'

import AuthCard from '@/components/AuthCard'
import Button from '@/components/Button'
import TextField from '@/components/TextField'

interface Props {
  token: string
}

export default function ResetPassword({ token }: Props) {
  const form = useForm({ password: '' })

  const submit = (event: { preventDefault: () => void }) => {
    event.preventDefault()
    form.patch(`/passwords/${token}`)
  }

  return (
    <AuthCard
      title="Choose a new password"
      subtitle="Twelve characters minimum. Every other session gets signed out."
    >
      <form onSubmit={submit} className="flex flex-col gap-4">
        <TextField
          label="New password"
          name="password"
          type="password"
          autoComplete="new-password"
          required
          minLength={12}
          value={form.data.password}
          onChange={(e) => {
            form.setData('password', e.target.value)
          }}
          errors={form.errors.password}
        />
        <Button type="submit" disabled={form.processing}>
          Reset password
        </Button>
      </form>
    </AuthCard>
  )
}
