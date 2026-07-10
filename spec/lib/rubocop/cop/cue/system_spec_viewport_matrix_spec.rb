# frozen_string_literal: true

require "spec_helper"
require "rubocop"
require "rubocop/rspec/support"
require_relative "../../../../../lib/rubocop/cop/cue/system_spec_viewport_matrix"

RSpec.describe RuboCop::Cop::Cue::SystemSpecViewportMatrix, :config do
  include RuboCop::RSpec::ExpectOffense

  it "flags a system example that skips the viewport matrix", :negative do
    expect_offense(<<~RUBY)
      it "shows the board" do
      ^^^^^^^^^^^^^^^^^^^^ #{RuboCop::Cop::Cue::SystemSpecViewportMatrix::MSG}
        visit board_path
      end
    RUBY
  end

  it "accepts an example that wraps the flow in with_each_viewport" do
    expect_no_offenses(<<~RUBY)
      it "shows the board" do
        with_each_viewport do |viewport|
          visit board_path
        end
      end
    RUBY
  end

  it "accepts a pending example with no block to inspect" do
    expect_no_offenses(<<~RUBY)
      it "will show the board eventually"
    RUBY
  end
end
