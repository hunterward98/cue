import type { Rule } from 'eslint'

// The two escape hatches left open once the raw Tailwind palette is
// deleted (ADR 0013): arbitrary values that smuggle a color into a
// utility, and inline style attributes that bypass utilities entirely.
// `text-red-500` needs no rule — it no longer compiles.
const COLOR_ARBITRARY = /-\[(?:#|rgb|hsl|oklch|oklab|lab\(|lch\(|color\()|-\(--/

interface JsxAttributeName {
  name?: string
}

interface JsxAttributeNode {
  name: JsxAttributeName
}

const noStyleLiterals: Rule.RuleModule = {
  meta: {
    type: 'problem',
    docs: {
      description:
        'Colors come from semantic tokens only: no inline style attributes, no color-shaped arbitrary values.',
    },
    messages: {
      inlineStyle:
        'Inline styles bypass the theme tokens. Use semantic utilities (bg-surface, text-ink, …) — see docs/design/standards.md.',
      arbitraryColor:
        'Arbitrary color values bypass the theme tokens. Use semantic utilities (bg-surface, text-ink, …) — see docs/design/standards.md.',
    },
    schema: [],
  },
  create(context) {
    return {
      JSXAttribute(node: Rule.Node) {
        const attribute = node as unknown as JsxAttributeNode
        if (attribute.name.name === 'style') {
          context.report({ node, messageId: 'inlineStyle' })
        }
      },
      Literal(node) {
        if (
          typeof node.value === 'string' &&
          COLOR_ARBITRARY.test(node.value)
        ) {
          context.report({ node, messageId: 'arbitraryColor' })
        }
      },
      TemplateElement(node) {
        if (COLOR_ARBITRARY.test(node.value.raw)) {
          context.report({ node, messageId: 'arbitraryColor' })
        }
      },
    }
  },
}

export default noStyleLiterals
