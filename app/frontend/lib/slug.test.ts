import { describe, expect, it } from 'vitest'

import { suggestSlug } from './slug'

describe('suggestSlug', () => {
  it('lowercases and hyphenates', () => {
    expect(suggestSlug('Riverside Dental')).toBe('riverside-dental')
  })

  it('collapses punctuation runs and strips edge hyphens', () => {
    expect(suggestSlug('  Café & Sons, LLC!  ')).toBe('cafe-sons-llc')
  })

  it('caps at the 40-character slug limit without a trailing hyphen', () => {
    const suggestion = suggestSlug('word '.repeat(12))
    expect(suggestion.length).toBeLessThanOrEqual(40)
    expect(suggestion.endsWith('-')).toBe(false)
  })

  it('returns an empty string when nothing survives', () => {
    expect(suggestSlug('!!!')).toBe('')
  })
})
