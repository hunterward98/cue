# frozen_string_literal: true

require "rails_helper"
require "tmpdir"

# Untested backups are decorative (database-architecture plan_4): this
# proves bin/db-backup yields an artifact that decrypts and pg_restores
# into a working database containing the seeded data.
RSpec.describe "bin/db-backup" do
  # pg_dump must see committed data from its own connection, so no
  # wrapping transaction; cleanup is manual.
  self.use_transactional_tests = false

  let(:database) { ActiveRecord::Base.connection_db_config.database }
  let(:container) { ENV.fetch("BACKUP_PG_CONTAINER", "cue-postgres") }
  let(:scratch_db) { "#{database}_restore_check" }
  let(:workdir) { Dir.mktmpdir }

  # Mirrors the script's two modes: docker exec into the DB container
  # (dev, prod accessory) or host client tools (CI service container).
  def pg_command(command)
    if container.empty?
      "PGPASSWORD=cue #{command} -h localhost -U cue"
    else
      "docker exec -i #{container} #{command} -U cue"
    end
  end


  after do
    FileUtils.remove_entry(workdir)
    User.where(email_address: "backup-probe@example.com").delete_all
    ActiveRecord::Base.connection.execute("DROP DATABASE IF EXISTS #{scratch_db}")
  end

  it "produces an encrypted artifact that restores with the seeded row intact" do
    create(:user, email_address: "backup-probe@example.com")

    key_file = File.join(workdir, "key.txt")
    system("age-keygen", "-o", key_file, exception: true, err: File::NULL)
    recipient = File.read(key_file)[/public key: (age1\w+)/, 1]

    output = IO.popen(
      { "AGE_RECIPIENT" => recipient, "BACKUP_PG_CONTAINER" => container },
      [ "bin/db-backup", database, workdir ], &:read
    )
    artifact = output.strip
    expect(File.size(artifact)).to be_positive

    # Ciphertext, not a plaintext dump lying around.
    expect(File.binread(artifact, 20)).to include("age-encryption.org")

    dump_file = File.join(workdir, "restored.dump")
    system("age -d -i #{key_file} -o #{dump_file} #{artifact}", exception: true)

    ActiveRecord::Base.connection.execute("DROP DATABASE IF EXISTS #{scratch_db}")
    ActiveRecord::Base.connection.execute("CREATE DATABASE #{scratch_db}")
    system("#{pg_command('pg_restore')} -d #{scratch_db} --no-owner < #{dump_file}", exception: true)

    count = `#{pg_command('psql')} -d #{scratch_db} -tAc "SELECT COUNT(*) FROM users WHERE email_address = 'backup-probe@example.com'"`.strip
    expect(count).to eq("1")
  end

  it "fails loudly rather than writing an empty artifact", :negative do
    key_file = File.join(workdir, "key.txt")
    system("age-keygen", "-o", key_file, exception: true, err: File::NULL)
    recipient = File.read(key_file)[/public key: (age1\w+)/, 1]

    ok = system(
      { "AGE_RECIPIENT" => recipient, "BACKUP_PG_CONTAINER" => container },
      "bin/db-backup", "no_such_database", workdir,
      out: File::NULL, err: File::NULL
    )

    expect(ok).to be(false)
    expect(Dir[File.join(workdir, "no_such_database-*.dump.age")].select { |f| File.size(f).positive? }).to be_empty
  end
end
