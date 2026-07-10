// Shared-prop and flash typings for Inertia. These grow as inertia_share
// props appear (e.g. the authenticated user). Names are Cue-prefixed:
// inside the declare-module block below, bare names resolve to
// @inertiajs/core's own exports first — FlashData would circularly
// reference itself and degrade to {}.
import '@inertiajs/core'

interface CueFlashData {
  notice?: string
  alert?: string
}

// "Nothing is shared yet", not "anything goes".
type CueSharedProps = Record<string, never>

declare module '@inertiajs/core' {
  export interface InertiaConfig {
    sharedPageProps: CueSharedProps
    flashDataType: CueFlashData
    errorValueType: string[]
  }
}
