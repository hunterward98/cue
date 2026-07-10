import '@testing-library/jest-dom/vitest'

import { cleanup } from '@testing-library/react'
import { afterEach } from 'vitest'

// RTL's automatic cleanup needs global afterEach; we keep vitest globals
// off, so register it explicitly.
afterEach(cleanup)
