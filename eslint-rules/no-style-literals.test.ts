import { RuleTester } from 'eslint'
import { describe, it } from 'vitest'

import noStyleLiterals from './no-style-literals'

const tester = new RuleTester({
  languageOptions: {
    ecmaVersion: 'latest',
    sourceType: 'module',
    parserOptions: { ecmaFeatures: { jsx: true } },
  },
})

describe('no-style-literals', () => {
  it('rejects inline styles and color-shaped arbitrary values, allows tokens', () => {
    tester.run('no-style-literals', noStyleLiterals, {
      valid: [
        '<p className="bg-surface text-ink border-border" />',
        '<p className="bg-coding-scarlet-surface text-coding-scarlet-ink" />',
        '<p className={`p-4 ${wide ? "max-w-3xl" : "max-w-md"}`} />',
        // Arbitrary values that aren't colors stay legal (layout escape).
        '<p className="grid-cols-[1fr_2fr]" />',
        'const pattern = "\\\\d{6}"',
      ],
      invalid: [
        {
          code: '<p style={{ color: "#fff" }} />',
          errors: [{ messageId: 'inlineStyle' }],
        },
        {
          code: '<p className="bg-[#8c1f24]" />',
          errors: [{ messageId: 'arbitraryColor' }],
        },
        {
          code: '<p className="text-[rgb(140,31,36)]" />',
          errors: [{ messageId: 'arbitraryColor' }],
        },
        {
          code: '<p className="border-[oklch(0.5_0.1_20)]" />',
          errors: [{ messageId: 'arbitraryColor' }],
        },
        {
          code: '<p className="bg-(--sneaky-var)" />',
          errors: [{ messageId: 'arbitraryColor' }],
        },
        {
          code: '<p className={`p-2 text-[#292521]`} />',
          errors: [{ messageId: 'arbitraryColor' }],
        },
      ],
    })
  })
})
