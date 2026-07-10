// Shared-prop and flash typings for Inertia. These grow as inertia_share
// props appear (e.g. the authenticated user). Local to this augmentation
// until app code needs them — then move to an imported module.
interface FlashData {
  notice?: string
  alert?: string
}

// "Nothing is shared yet", not "anything goes".
type SharedProps = Record<string, never>

declare module '@inertiajs/core' {
  export interface InertiaConfig {
    sharedPageProps: SharedProps
    flashDataType: FlashData
    errorValueType: string[]
  }
}

export {}
