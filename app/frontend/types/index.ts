export interface FlashData {
  notice?: string
  alert?: string
}

// Grows as inertia_share props appear (e.g. the authenticated user).
// Record<string, never> = "nothing is shared yet", not "anything goes".
export type SharedProps = Record<string, never>
