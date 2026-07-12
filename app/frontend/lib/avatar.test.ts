import { describe, expect, it } from 'vitest'

import { hueFor, initialsFor } from './avatar'

describe('initialsFor', () => {
  it('takes first and last initials', () => {
    expect(initialsFor('Charlie Kelly')).toBe('CK')
    expect(initialsFor('Ana Maria de Souza')).toBe('AS')
  })

  it('handles single names and empty strings', () => {
    expect(initialsFor('Cher')).toBe('C')
    expect(initialsFor('   ')).toBe('?')
  })
})

describe('hueFor', () => {
  it('is deterministic', () => {
    expect(hueFor('Charlie Kelly')).toBe(hueFor('Charlie Kelly'))
  })

  it('covers the whole coding wheel', () => {
    // 'a'..'f' etc. walk hash % 6 through every branch; assert the set.
    const hues = new Set(
      ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'].map((name) => hueFor(name)),
    )
    expect(hues).toEqual(
      new Set(['scarlet', 'ochre', 'moss', 'teal', 'indigo', 'plum']),
    )
  })
})
