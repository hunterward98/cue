import { createInertiaApp } from '@inertiajs/react'

void createInertiaApp({
  pages: '../pages',

  strictMode: true,

  // Inertia's client-side head manager reconciles the SSR `<title
  // data-inertia>` on first mount against whatever the current page
  // declares — with no `title` callback, a page that never renders
  // `<Head title>` gets reconciled to nothing, wiping the title
  // (axe: document-title, caught building the gallery a11y check).
  // This runs on every visit and is the documented fix.
  title: (title) => (title ? `${title} · Cue` : 'Cue'),

  defaults: {
    form: {
      forceIndicesArrayFormatInFormData: false,
      withAllErrors: true,
    },
    visitOptions: () => {
      return { queryStringArrayFormat: 'brackets' }
    },
  },
}).catch((error: unknown) => {
  // This ensures this entrypoint is only loaded on Inertia pages
  // by checking for the presence of the root element (#app by default).
  // Feel free to remove this `catch` if you don't need it.
  if (document.getElementById('app')) {
    throw error
  } else {
    console.error(
      'Missing root element.\n\n' +
        'If you see this error, it probably means you loaded Inertia.js on non-Inertia pages.\n' +
        'Consider moving <%= vite_typescript_tag "inertia.tsx" %> to the Inertia-specific layout instead.',
    )
  }
})
