export type Hue = 'scarlet' | 'ochre' | 'moss' | 'teal' | 'indigo' | 'plum'

export function initialsFor(name: string): string {
  const [first, ...rest] = name.trim().split(/\s+/).filter(Boolean)
  if (first === undefined) return '?'
  const last = rest[rest.length - 1]
  return (
    first.charAt(0) + (last === undefined ? '' : last.charAt(0))
  ).toUpperCase()
}

// Hue is derived from the name so the same person is always the same
// color, without storing anything.
export function hueFor(name: string): Hue {
  let hash = 0
  for (const char of name) hash = (hash * 31 + char.charCodeAt(0)) % 997
  switch (hash % 6) {
    case 0:
      return 'scarlet'
    case 1:
      return 'ochre'
    case 2:
      return 'moss'
    case 3:
      return 'teal'
    case 4:
      return 'indigo'
    default:
      return 'plum'
  }
}
