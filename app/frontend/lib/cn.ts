// Joins class fragments, dropping falsy ones. The layout-only className
// pass-through rule (docs/design/standards.md) is enforced by
// cue/no-style-literals + review, not by this helper.
export function cn(
  ...fragments: (string | false | null | undefined)[]
): string {
  return fragments.filter(Boolean).join(' ')
}
