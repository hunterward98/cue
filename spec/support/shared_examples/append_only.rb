# frozen_string_literal: true

# For *_events tables (database-architecture plan_3): history doesn't get
# edited. Include with a persisted `record` let and an attribute/value the
# update would tamper with:
#
#   it_behaves_like "an append-only table", attribute: :action, value: "edited"
RSpec.shared_examples "an append-only table" do |attribute:, value:|
  it "forbids updates", :negative do
    expect { record.update!(attribute => value) }
      .to raise_error(ActiveRecord::ReadOnlyRecord)
  end

  it "forbids destroys", :negative do
    expect { record.destroy! }.to raise_error(ActiveRecord::ReadOnlyRecord)
  end
end
