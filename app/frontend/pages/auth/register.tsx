import { Link, useForm } from '@inertiajs/react'

import AuthCard from '@/components/AuthCard'
import Button from '@/components/Button'
import TextField from '@/components/TextField'

interface RegisterForm {
  email_address: string
  login_mode: 'password' | 'passwordless'
  password: string
  [key: string]: string
}

export default function Register() {
  const form = useForm<RegisterForm>({
    email_address: '',
    login_mode: 'password',
    password: '',
  })

  const submit = (event: { preventDefault: () => void }) => {
    event.preventDefault()
    form.post('/registration')
  }

  return (
    <AuthCard
      title="Create your account"
      subtitle="Most people arrive here from an invitation email — that's the idea."
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
          errors={form.errors.email_address}
        />

        <fieldset className="flex flex-col gap-2 text-sm text-ink">
          <legend className="font-medium">How do you want to sign in?</legend>
          <label className="flex items-start gap-2">
            <input
              type="radio"
              name="login_mode"
              value="password"
              checked={form.data.login_mode === 'password'}
              onChange={() => {
                form.setData('login_mode', 'password')
              }}
            />
            <span>
              <strong>Password</strong> — the classic. Required later if you run
              boards.
            </span>
          </label>
          <label className="flex items-start gap-2">
            <input
              type="radio"
              name="login_mode"
              value="passwordless"
              checked={form.data.login_mode === 'passwordless'}
              onChange={() => {
                form.setData('login_mode', 'passwordless')
              }}
            />
            <span>
              <strong>Email codes</strong> — we email you a six-digit code each
              time. Nothing to remember, nothing to leak.
            </span>
          </label>
        </fieldset>

        {form.data.login_mode === 'password' ? (
          <TextField
            label="Password (12+ characters)"
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
        ) : null}

        <Button type="submit" disabled={form.processing}>
          Create account
        </Button>
        <p className="text-sm text-ink-muted">
          Already have one?{' '}
          <Link href="/session/new" className="underline underline-offset-2">
            Sign in
          </Link>
        </p>
      </form>
    </AuthCard>
  )
}
