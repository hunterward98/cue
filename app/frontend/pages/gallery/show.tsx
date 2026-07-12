import type { ReactNode } from 'react'
import { useState } from 'react'

import Avatar from '@/components/Avatar'
import Badge from '@/components/Badge'
import Button from '@/components/Button'
import Card from '@/components/Card'
import Checkbox from '@/components/Checkbox'
import ConfirmDialog from '@/components/ConfirmDialog'
import Drawer from '@/components/Drawer'
import EmptyState from '@/components/EmptyState'
import FormField from '@/components/FormField'
import Modal from '@/components/Modal'
import PageHeader from '@/components/PageHeader'
import Radio from '@/components/Radio'
import Select from '@/components/Select'
import SideNav from '@/components/SideNav'
import Skeleton from '@/components/Skeleton'
import Spinner from '@/components/Spinner'
import Switch from '@/components/Switch'
import Table from '@/components/Table'
import Tabs from '@/components/Tabs'
import TextField from '@/components/TextField'
import Textarea from '@/components/Textarea'
import ThemeToggle from '@/components/ThemeToggle'
import { ToastProvider, useToast } from '@/components/Toast'
import Wordmark from '@/components/Wordmark'

function Section({ title, children }: { title: string; children: ReactNode }) {
  return (
    <section
      aria-label={title}
      data-gallery-section={title}
      className="flex flex-col gap-4 border-t border-border pt-6"
    >
      <h2 className="font-display text-xl font-semibold text-ink">{title}</h2>
      {children}
    </section>
  )
}

function ToastDemo() {
  const { toast } = useToast()
  return (
    <div className="flex gap-2">
      <Button
        variant="secondary"
        onClick={() => {
          toast('success', 'Copied. Go paste it somewhere nice.')
        }}
      >
        Success toast
      </Button>
      <Button
        variant="secondary"
        onClick={() => {
          toast('danger', 'That did not work. Try again?')
        }}
      >
        Danger toast
      </Button>
    </div>
  )
}

interface DemoRow {
  id: string
  name: string
  role: string
}

const demoRows: DemoRow[] = [
  { id: '1', name: 'Charlie Kelly', role: 'Owner' },
  { id: '2', name: 'Dee Reynolds', role: 'Board owner' },
  { id: '3', name: 'Cricket', role: 'Requester' },
]

export default function GalleryShow() {
  const [modalOpen, setModalOpen] = useState(false)
  const [confirmOpen, setConfirmOpen] = useState(false)
  const [drawerOpen, setDrawerOpen] = useState(false)
  const [switchOn, setSwitchOn] = useState(true)
  const [role, setRole] = useState<string | null>(null)

  return (
    <ToastProvider>
      <main
        id="gallery-root"
        className="mx-auto flex w-full max-w-3xl flex-col gap-6 px-4 py-8"
      >
        <div className="flex items-center justify-between">
          <Wordmark />
          <ThemeToggle />
        </div>
        <PageHeader
          title="Component gallery"
          subtitle="Every component, every variant, both themes. Product screens compose; they do not invent."
        />

        <Section title="Typography">
          <p className="font-display text-3xl font-semibold text-ink">
            Display: EB Garamond
          </p>
          <p className="text-base text-ink">
            Body: Inter — quick brown foxes, verified fixtures, forgotten
            passwords.
          </p>
          <p className="text-sm text-ink-muted">
            Muted: the second voice, for hints and subtitles.
          </p>
        </Section>

        <Section title="Buttons">
          <div className="flex flex-wrap items-center gap-2">
            <Button>Primary</Button>
            <Button variant="secondary">Secondary</Button>
            <Button variant="destructive">Destructive</Button>
            <Button variant="ghost">Ghost</Button>
            <Button disabled>Disabled</Button>
          </div>
        </Section>

        <Section title="Badges">
          <div className="flex flex-wrap gap-2">
            <Badge>Neutral</Badge>
            <Badge variant="scarlet">Scarlet</Badge>
            <Badge variant="ochre">Ochre</Badge>
            <Badge variant="moss">Moss</Badge>
            <Badge variant="teal">Teal</Badge>
            <Badge variant="indigo">Indigo</Badge>
            <Badge variant="plum">Plum</Badge>
          </div>
        </Section>

        <Section title="Forms">
          <div className="flex max-w-md flex-col gap-4">
            <TextField
              label="Organization name"
              name="demo-name"
              hint="What the door says."
            />
            <TextField
              label="Slug"
              name="demo-slug"
              errors={['has already been taken']}
              defaultValue="demo"
            />
            <FormField label="Notes">
              <Textarea name="demo-notes" defaultValue="Be nice." />
            </FormField>
            <FormField label="Default role">
              <Select
                options={[
                  { value: 'requester', label: 'Requester' },
                  { value: 'board_owner', label: 'Board owner' },
                ]}
                value={role}
                onValueChange={setRole}
              />
            </FormField>
            <Checkbox label="Email me when something happens" defaultChecked />
            <Radio name="demo-mode" label="Password" defaultChecked />
            <Radio name="demo-mode" label="Email codes" />
            <Switch
              label="Join link"
              checked={switchOn}
              onChange={setSwitchOn}
            />
          </div>
        </Section>

        <Section title="Cards and empty states">
          <Card title="A titled card">
            <p className="text-sm text-ink-muted">
              Cards hold everything that is not a page.
            </p>
          </Card>
          <EmptyState
            title="No cues yet"
            action={<Button>Raise the first one</Button>}
          >
            When someone needs something, it lands here.
          </EmptyState>
        </Section>

        <Section title="Table">
          <Table
            columns={[
              { header: 'Name', cell: (row: DemoRow) => row.name },
              { header: 'Role', cell: (row: DemoRow) => row.role },
            ]}
            rows={demoRows}
            rowKey={(row) => row.id}
          />
        </Section>

        <Section title="Tabs">
          <Tabs
            tabs={[
              {
                value: 'one',
                label: 'Profile',
                content: <p className="text-sm text-ink-muted">Tab one.</p>,
              },
              {
                value: 'two',
                label: 'Members',
                content: <p className="text-sm text-ink-muted">Tab two.</p>,
              },
            ]}
          />
        </Section>

        <Section title="Avatars">
          <div className="flex gap-2">
            {demoRows.map((row) => (
              <Avatar key={row.id} name={row.name} />
            ))}
          </div>
        </Section>

        <Section title="Feedback">
          <div className="flex items-center gap-4">
            <Spinner />
            <Skeleton className="h-4 w-40" />
          </div>
          <ToastDemo />
        </Section>

        <Section title="Navigation">
          <SideNav
            label="Settings"
            items={[
              { label: 'Profile', href: '#profile', current: true },
              { label: 'Members', href: '#members' },
            ]}
          />
        </Section>

        <Section title="Overlays">
          <div className="flex gap-2">
            <Button
              variant="secondary"
              onClick={() => {
                setModalOpen(true)
              }}
            >
              Open modal
            </Button>
            <Button
              variant="secondary"
              onClick={() => {
                setConfirmOpen(true)
              }}
            >
              Open confirm
            </Button>
            <Button
              variant="secondary"
              onClick={() => {
                setDrawerOpen(true)
              }}
            >
              Open drawer
            </Button>
          </div>
        </Section>

        <Modal open={modalOpen} onOpenChange={setModalOpen} title="A modal">
          <p className="text-sm text-ink-muted">Focus is trapped in here.</p>
        </Modal>
        <ConfirmDialog
          open={confirmOpen}
          onOpenChange={setConfirmOpen}
          title="Delete everything?"
          confirmLabel="Delete"
          onConfirm={() => {
            setConfirmOpen(false)
          }}
        >
          This is the dead-serious variant. No snark past this line.
        </ConfirmDialog>
        <Drawer open={drawerOpen} onOpenChange={setDrawerOpen} title="Menu">
          <p className="text-sm text-ink-muted">
            Mobile navigation lives here.
          </p>
        </Drawer>
      </main>
    </ToastProvider>
  )
}
