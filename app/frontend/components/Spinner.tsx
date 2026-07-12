// A quiet circular spinner. aria-label lets screen readers hear what
// sighted users infer.
export default function Spinner({ label = 'Loading' }: { label?: string }) {
  return (
    <span
      role="status"
      aria-label={label}
      className="inline-block size-5 animate-spin rounded-full border-2 border-border border-t-accent"
    />
  )
}
