import { render, screen } from '@testing-library/react'
import { describe, expect, it } from 'vitest'

import type { Column } from './Table'
import Table from './Table'

interface Row {
  id: string
  name: string
  role: string
}

const columns: Column<Row>[] = [
  { header: 'Name', cell: (row) => row.name },
  { header: 'Role', cell: (row) => row.role },
]

const rows: Row[] = [
  { id: '1', name: 'Charlie', role: 'Owner' },
  { id: '2', name: 'Dee', role: 'Requester' },
]

describe('Table', () => {
  it('renders a real table plus the mobile card list', () => {
    render(<Table columns={columns} rows={rows} rowKey={(row) => row.id} />)

    expect(screen.getByRole('table')).toBeInTheDocument()
    expect(
      screen.getByRole('columnheader', { name: 'Name' }),
    ).toBeInTheDocument()
    // Every value appears twice: once in the table, once in the cards.
    expect(screen.getAllByText('Charlie')).toHaveLength(2)
    expect(screen.getByRole('list')).toBeInTheDocument()
  })

  it('shows the empty message instead of empty chrome', () => {
    render(
      <Table
        columns={columns}
        rows={[]}
        rowKey={(row: Row) => row.id}
        emptyMessage="No members yet."
      />,
    )
    expect(screen.getByText('No members yet.')).toBeInTheDocument()
    expect(screen.queryByRole('table')).not.toBeInTheDocument()
  })

  it('falls back to a stock empty message', () => {
    render(<Table columns={columns} rows={[]} rowKey={(row: Row) => row.id} />)
    expect(screen.getByText('Nothing here yet.')).toBeInTheDocument()
  })
})
