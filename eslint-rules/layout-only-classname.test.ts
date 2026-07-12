import { RuleTester } from 'eslint'
import { describe, it } from 'vitest'

import layoutOnlyClassname from './layout-only-classname'

const tester = new RuleTester({
  languageOptions: {
    ecmaVersion: 'latest',
    sourceType: 'module',
    parserOptions: { ecmaFeatures: { jsx: true } },
  },
})

describe('layout-only-classname', () => {
  it('restricts className on configured components to layout utilities', () => {
    tester.run('layout-only-classname', layoutOnlyClassname, {
      valid: [
        {
          code: '<Card className="p-4 flex flex-col gap-2" />',
          options: [['Card', 'Skeleton']],
        },
        {
          code: '<Skeleton className="h-4 w-40" />',
          options: [['Card', 'Skeleton']],
        },
        { code: '<Card title="x" />', options: [['Card', 'Skeleton']] },
        {
          code: '<Card className="sm:flex-row items-center" />',
          options: [['Card', 'Skeleton']],
        },
        // Not a configured component — untouched by this rule.
        { code: '<div className="bg-accent text-ink" />', options: [[]] },
        // No options at all: nothing is constrained, so nothing fires.
        { code: '<Card className="bg-accent" />' },
        // Dynamic expressions can't be checked statically; stays a
        // review flag rather than a false positive.
        {
          code: '<Card className={dynamicValue} />',
          options: [['Card', 'Skeleton']],
        },
        {
          code: '<Card className={`p-2 ${extra}`} />',
          options: [['Card', 'Skeleton']],
        },
        // JSXExpressionContainer wrapping a plain string literal or a
        // template with no interpolation is still checkable.
        {
          code: '<Card className={"p-2"} />',
          options: [['Card', 'Skeleton']],
        },
        {
          code: '<Card className={`p-2 flex`} />',
          options: [['Card', 'Skeleton']],
        },
        // Member-expression tags (Base UI's <Dialog.Root>, …) aren't
        // JSXIdentifiers — out of scope for this rule regardless of
        // className content.
        {
          code: '<Dialog.Root className="bg-accent" />',
          options: [['Card', 'Skeleton']],
        },
        // A boolean className attribute (no value) can't be read as a
        // string; skip rather than crash.
        { code: '<Card className />', options: [['Card', 'Skeleton']] },
      ],
      invalid: [
        {
          code: '<Card className="bg-accent" />',
          options: [['Card', 'Skeleton']],
          errors: [{ messageId: 'notLayoutOnly' }],
        },
        {
          code: '<Card className={"bg-accent"} />',
          options: [['Card', 'Skeleton']],
          errors: [{ messageId: 'notLayoutOnly' }],
        },
        {
          code: '<Card className={`bg-accent`} />',
          options: [['Card', 'Skeleton']],
          errors: [{ messageId: 'notLayoutOnly' }],
        },
        {
          code: '<Skeleton className="text-ink font-bold" />',
          options: [['Card', 'Skeleton']],
          errors: [
            { messageId: 'notLayoutOnly' },
            { messageId: 'notLayoutOnly' },
          ],
        },
        {
          code: '<Card className="h-4 rounded-full" />',
          options: [['Card', 'Skeleton']],
          errors: [{ messageId: 'notLayoutOnly' }],
        },
      ],
    })
  })
})
