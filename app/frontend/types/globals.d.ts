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

interface CueSharedProps {
  // Account theme preference; null pre-login (theming plan_2).
  theme: 'system' | 'light' | 'dark' | null
}

declare module '@inertiajs/core' {
  export interface InertiaConfig {
    sharedPageProps: CueSharedProps
    flashDataType: CueFlashData
    errorValueType: string[]
  }
}
