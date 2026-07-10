import js from '@eslint/js'
import prettier from 'eslint-config-prettier'
import reactHooks from 'eslint-plugin-react-hooks'
import { defineConfig } from 'eslint/config'
import tseslint from 'typescript-eslint'

export default defineConfig(
  { ignores: ['**/*.d.ts'] },
  js.configs.recommended,
  tseslint.configs.strictTypeChecked,
  tseslint.configs.stylisticTypeChecked,
  reactHooks.configs.flat['recommended-latest'],
  prettier,
  {
    languageOptions: {
      parserOptions: {
        projectService: true,
        tsconfigRootDir: import.meta.dirname,
      },
    },
    rules: {
      // Master plan: "We cannot afford poor design choices like the use of
      // 'any' types." Explicit in strictTypeChecked already; restated so a
      // preset upgrade can never silently drop it.
      '@typescript-eslint/no-explicit-any': 'error',

      // ts-expect-error comments only with a reason and a tracking link, so the
      // debt is findable: // @ts-expect-error: <why> (https://…)
      '@typescript-eslint/ban-ts-comment': [
        'error',
        {
          'ts-expect-error': { descriptionFormat: '^: .+ \\(https?://.+\\)$' },
          'ts-ignore': true,
          'ts-nocheck': true,
          'ts-check': false,
        },
      ],

      // Inertia props are the only data path (foundation plan_3). A
      // component that fetches on its own breaks the no-API simplification
      // this stack is built on.
      'no-restricted-globals': [
        'error',
        {
          name: 'fetch',
          message:
            'Data reaches pages as Inertia props; use router.visit/reload for updates. If you genuinely need fetch, raise it in an ADR first.',
        },
      ],
      'no-restricted-imports': [
        'error',
        {
          paths: [
            {
              name: 'axios',
              message:
                'Data reaches pages as Inertia props — no client HTTP layer.',
            },
          ],
        },
      ],
    },
  },
)
