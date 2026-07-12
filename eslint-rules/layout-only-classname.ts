import type { Rule } from 'eslint'

// Theming plan_3 critique: the constrained `className` pass-through on
// layout-only components (Card, Skeleton, …) was a review-vibe rule
// ("layout-only, promise"). This makes it mechanical: only
// spacing/flex/grid/width utilities are legal in that prop. Color and
// typography still come from `cue/no-style-literals` everywhere else —
// this rule is narrower and only fires on the configured component
// names' `className` attribute.
const ALLOWED_PATTERNS: RegExp[] = [
  /^-?(?:p|m)[trblxy]?-/, // padding/margin
  /^-?gap(?:-[xy])?-/,
  /^-?space-[xy]-/,
  /^-?(?:inline-)?flex(?:-.*)?$/,
  /^(?:items|justify|content|self|place-items|place-content|place-self)-/,
  /^order-/,
  /^basis-/,
  /^grow(?:-.*)?$/,
  /^shrink(?:-.*)?$/,
  /^-?(?:inline-)?grid(?:-.*)?$/,
  /^(?:col|row)-(?:span|start|end)-/,
  /^auto-(?:cols|rows)-/,
  /^(?:w|h|size|min-w|max-w|min-h|max-h)-/,
]

function isAllowedToken(token: string): boolean {
  // Strip responsive/state variants (`sm:`, `hover:`, `dark:` …) — a
  // no-op if there's no colon, the real utility if there is.
  const base = token.replace(/^.*:/, '')
  return ALLOWED_PATTERNS.some((pattern) => pattern.test(base))
}

function disallowedTokens(value: string): string[] {
  return value
    .split(/\s+/)
    .filter(Boolean)
    .filter((token) => !isAllowedToken(token))
}

interface JsxIdentifierNode {
  type: string
  name: string
}

// One loose shape covers Literal and JSXExpressionContainer — narrowing
// a real discriminated union across ESLint's untyped AST fights
// noUncheckedIndexedAccess more than it helps. `expression` is typed as
// always-present: only JSXExpressionContainer nodes are ever read
// through it, and that field is mandatory there (an empty `{}` is
// JSXEmptyExpression, never undefined).
interface JsxValueNode {
  type: string
  value?: unknown
  expression: JsxValueNode
}

// TemplateLiteral's own shape: in valid AST it always carries both
// arrays (no expressions ⇒ exactly one quasi), so — unlike JsxValueNode
// above — these fields are asserted, not optional.
interface TemplateLiteralNode {
  expressions: unknown[]
  quasis: { value: { raw: string } }[]
}

interface JsxAttributeNode {
  type: string
  name: { name?: string }
  value?: JsxValueNode | null
}

interface JsxOpeningElementNode {
  name: JsxIdentifierNode
  attributes: JsxAttributeNode[]
}

// Only plain literals are checked. A dynamic expression (a variable, a
// `cn(...)` call, a template with interpolation) can't be verified
// statically — it stays a review flag, same as before this rule existed.
function literalStringValue(value: JsxAttributeNode['value']): string | null {
  if (value == null) return null
  if (value.type === 'Literal' && typeof value.value === 'string') {
    return value.value
  }
  // Any other attribute value is a JSXExpressionContainer in valid JSX
  // — a bare `className=5` isn't legal syntax.
  const expression = value.expression
  if (expression.type === 'Literal' && typeof expression.value === 'string') {
    return expression.value
  }
  if (expression.type === 'TemplateLiteral') {
    const template = expression as unknown as TemplateLiteralNode
    if (template.expressions.length === 0) {
      return template.quasis.map((quasi) => quasi.value.raw).join('')
    }
  }
  return null
}

const layoutOnlyClassname: Rule.RuleModule = {
  meta: {
    type: 'problem',
    docs: {
      description:
        'The className pass-through on layout-only components accepts spacing/flex/grid/width utilities only.',
    },
    messages: {
      notLayoutOnly:
        '"{{token}}" is not a layout utility (spacing/flex/grid/width). {{component}}\'s className is layout-only — see docs/design/components.md.',
    },
    schema: [{ type: 'array', items: { type: 'string' } }],
  },
  create(context) {
    const constrained = new Set<string>(
      (context.options[0] as string[] | undefined) ?? [],
    )

    return {
      JSXOpeningElement(node: Rule.Node) {
        const element = node as unknown as JsxOpeningElementNode
        if (element.name.type !== 'JSXIdentifier') return
        const componentName = element.name.name
        if (!constrained.has(componentName)) return

        const classNameAttr = element.attributes.find(
          (attribute) =>
            attribute.type === 'JSXAttribute' &&
            attribute.name.name === 'className',
        )
        if (!classNameAttr) return

        const literal = literalStringValue(classNameAttr.value)
        if (literal === null) return

        for (const token of disallowedTokens(literal)) {
          context.report({
            node: classNameAttr as unknown as Rule.Node,
            messageId: 'notLayoutOnly',
            data: { token, component: componentName },
          })
        }
      },
    }
  },
}

export default layoutOnlyClassname
