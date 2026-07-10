import { Link, useForm } from '@inertiajs/react'

import AuthCard from '@/components/AuthCard'
import Button from '@/components/Button'
import TextField from '@/components/TextField'

interface Props {
  code_sent?: string | null
}

// One screen, two proofs: password, or an emailed code (ratified A1).
export default function Login({ code_sent }: Props) {
  const passwordForm = useForm({ email_address: '', password: '' })
  const codeRequestForm = useForm({ email_address: '' })
  // The server pairs the code with its session-stored pending email.
  const codeForm = useForm({ code: '' })

  const submitPassword = (event: { preventDefault: () => void }) => {
    event.preventDefault()
    passwordForm.post('/session')
  }

  const requestCode = (event: { preventDefault: () => void }) => {
    event.preventDefault()
    codeRequestForm.transform((data) => ({
      email_address: data.email_address || passwordForm.data.email_address,
    }))
    codeRequestForm.post('/login_code')
  }

  const submitCode = (event: { preventDefault: () => void }) => {
    event.preventDefault()
    codeForm.post('/session')
  }

  if (code_sent) {
    return (
      <AuthCard
        title="Enter your sign-in code"
        subtitle={`We sent a six-digit code to ${code_sent} — if that address has an account.`}
      >
        <form onSubmit={submitCode} className="flex flex-col gap-4">
          <TextField
            label="Sign-in code"
            name="code"
            inputMode="numeric"
            autoComplete="one-time-code"
            pattern="\d{6}"
            required
            value={codeForm.data.code}
            onChange={(e) => {
              codeForm.setData('code', e.target.value)
            }}
          />
          <Button type="submit" disabled={codeForm.processing}>
            Sign in
          </Button>
        </form>
      </AuthCard>
    )
  }

  return (
    <AuthCard title="Sign in" subtitle="Your cues kept themselves warm.">
      <form onSubmit={submitPassword} className="flex flex-col gap-4">
        <TextField
          label="Email"
          name="email_address"
          type="email"
          autoComplete="email"
          required
          value={passwordForm.data.email_address}
          onChange={(e) => {
            passwordForm.setData('email_address', e.target.value)
          }}
        />
        <TextField
          label="Password"
          name="password"
          type="password"
          autoComplete="current-password"
          value={passwordForm.data.password}
          onChange={(e) => {
            passwordForm.setData('password', e.target.value)
          }}
        />
        <Button type="submit" disabled={passwordForm.processing}>
          Sign in
        </Button>
      </form>
      <form
        onSubmit={requestCode}
        className="mt-4 border-t border-stone-200 pt-4"
      >
        <Button
          variant="quiet"
          type="submit"
          disabled={codeRequestForm.processing}
        >
          Email me a sign-in code instead
        </Button>
      </form>
      <p className="mt-4 text-sm text-stone-600">
        <Link href="/passwords/new" className="underline underline-offset-2">
          Forgot your password?
        </Link>{' '}
        ·{' '}
        <Link href="/registration/new" className="underline underline-offset-2">
          Create an account
        </Link>
      </p>
    </AuthCard>
  )
}
