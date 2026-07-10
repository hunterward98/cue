import { useForm } from '@inertiajs/react'

import AuthCard from '@/components/AuthCard'
import Button from '@/components/Button'
import TextField from '@/components/TextField'

interface Props {
  email: string
}

export default function CheckInbox({ email }: Props) {
  const form = useForm({ code: '' })

  const submit = (event: { preventDefault: () => void }) => {
    event.preventDefault()
    form.patch('/email_verification')
  }

  const resend = () => {
    form.post('/email_verification/resend', { preserveState: true })
  }

  return (
    <AuthCard
      title="Check your inbox"
      subtitle={`We sent a six-digit code to ${email}. The email has a one-tap link too, if typing isn't your thing.`}
    >
      <form onSubmit={submit} className="flex flex-col gap-4">
        <TextField
          label="Verification code"
          name="code"
          inputMode="numeric"
          autoComplete="one-time-code"
          pattern="\d{6}"
          required
          value={form.data.code}
          onChange={(e) => {
            form.setData('code', e.target.value)
          }}
        />
        <Button type="submit" disabled={form.processing}>
          Verify
        </Button>
        <Button variant="quiet" onClick={resend} disabled={form.processing}>
          Send a fresh code
        </Button>
      </form>
    </AuthCard>
  )
}
