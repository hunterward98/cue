import type { ReactNode } from 'react'

// Responsive by design (master plan: mobile-first): a real <table> from
// sm up, stacked label/value cards below — same column definitions.
export interface Column<Row> {
  header: string
  cell: (row: Row) => ReactNode
}

interface Props<Row> {
  columns: Column<Row>[]
  rows: Row[]
  rowKey: (row: Row) => string
  emptyMessage?: string
}

export default function Table<Row>({
  columns,
  rows,
  rowKey,
  emptyMessage = 'Nothing here yet.',
}: Props<Row>) {
  if (rows.length === 0) {
    return <p className="text-sm text-ink-muted">{emptyMessage}</p>
  }

  return (
    <>
      <table className="hidden w-full border-collapse text-sm sm:table">
        <thead>
          <tr className="border-b border-border text-left">
            {columns.map((column) => (
              <th
                key={column.header}
                className="py-2 pr-4 font-medium text-ink-muted"
              >
                {column.header}
              </th>
            ))}
          </tr>
        </thead>
        <tbody>
          {rows.map((row) => (
            <tr key={rowKey(row)} className="border-b border-border">
              {columns.map((column) => (
                <td key={column.header} className="py-2 pr-4 text-ink">
                  {column.cell(row)}
                </td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
      <ul className="flex flex-col gap-2 sm:hidden">
        {rows.map((row) => (
          <li
            key={rowKey(row)}
            className="rounded-lg border border-border bg-surface-raised p-4"
          >
            <dl className="flex flex-col gap-1">
              {columns.map((column) => (
                <div key={column.header} className="flex justify-between gap-2">
                  <dt className="text-xs text-ink-muted">{column.header}</dt>
                  <dd className="text-sm text-ink">{column.cell(row)}</dd>
                </div>
              ))}
            </dl>
          </li>
        ))}
      </ul>
    </>
  )
}
